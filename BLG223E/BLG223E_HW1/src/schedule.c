#include "schedule.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>


// Create a new schedule with 7 days
struct Schedule* CreateSchedule() {
	struct Schedule* newSchedule = (struct Schedule*)malloc(sizeof(struct Schedule));
	newSchedule->head = CreateDay("Monday");

	struct Day* tempDay = newSchedule->head;
	tempDay->nextDay = CreateDay("Tuesday");
	tempDay = tempDay->nextDay;

	tempDay->nextDay = CreateDay("Wednesday");
	tempDay = tempDay->nextDay;

	tempDay->nextDay = CreateDay("Thursday");
	tempDay = tempDay->nextDay;

	tempDay->nextDay = CreateDay("Friday");
	tempDay = tempDay->nextDay;

	tempDay->nextDay = CreateDay("Saturday");
	tempDay = tempDay->nextDay;

	tempDay->nextDay = CreateDay("Sunday");
	tempDay = tempDay->nextDay;

	tempDay->nextDay = newSchedule->head;

	printf("Schedule creation complete.\n");
	return newSchedule;
}

// Add an exam to a day in the schedule
int AddExamToSchedule(struct Schedule* schedule, const char* day, int startTime, int endTime, const char* courseCode) {
	if (startTime < 8 || startTime > 17 || endTime < 9 || endTime > 20 || (endTime - startTime <= 0) || (endTime - startTime > 3)) {
		printf("Invalid exam.\n");
		return 3;
	}

	struct Day* dayCursor = schedule->head;
	for (int i = 0; i < 8; i++) {
		if (i == 7) {
			printf("Invalid exam.\n");
			return 3;
		}

		if (strcmp(dayCursor->dayName, day) == 0) {
			break;
		}

		dayCursor = dayCursor->nextDay;
	}

	if (IsValidTime(dayCursor, startTime, endTime)) {
		struct Exam* newExam = CreateExam(startTime, endTime, courseCode);
		AddExamToDay(dayCursor, newExam);
		printf("%s exam added to %s at time %d to %d without conflict.\n",
			newExam->courseCode, dayCursor->dayName, newExam->startTime, newExam->endTime);
		return 0;
	}
	else {
		int newStartTime = startTime + 1;
		int examTime = endTime - startTime;

		for (int i = 0; i < 7; i++) {
			for (int j = newStartTime; j <= 17; j++) {
				if (IsValidTime(dayCursor, j, j + examTime)) {
					struct Exam* newExam = CreateExam(j, j + examTime, courseCode);
					AddExamToDay(dayCursor, newExam);
					printf("%s exam added to %s at time %d to %d due to conflict.\n",
						newExam->courseCode, dayCursor->dayName, newExam->startTime, newExam->endTime);
					return 1;
				}
			}

			newStartTime = 8;
			dayCursor = dayCursor->nextDay;
		}

		printf("Schedule full. Exam cannot be added.\n");
		return 2;
	}
}

// Remove an exam from a specific day in the schedule
int RemoveExamFromSchedule(struct Schedule* schedule, const char* day, int startTime) {
	struct Day* tempDay = schedule->head;
	for (int i = 0; i < 7; i++) {
		if (strcmp(tempDay->dayName, day) == 0) {

			struct Exam* prevExam = NULL;
			struct Exam* tempExam = tempDay->examList;
			while (tempExam != NULL) {
				if (tempExam->startTime == startTime) {
					if (prevExam != NULL) {
						prevExam->next = tempExam->next;
					}
					else {
						tempDay->examList = tempExam->next;
					}

					free(tempExam);
					printf("Exam removed successfully.\n");
					return 0;
				}

				prevExam = tempExam;
				tempExam = tempExam->next;
			}
		}

		tempDay = tempDay->nextDay;
	}

	printf("Exam could not be found.");
	return 1;
}

// Update an exam in the schedule
int UpdateExam(struct Schedule* schedule, const char* oldDay, int oldStartTime, const char* newDay, int newStartTime, int newEndTime) {
	if (newStartTime < 8 || newStartTime > 17 || newEndTime < 9 || newEndTime > 20 || (newEndTime - newStartTime <= 0) || (newEndTime - newStartTime > 3)) {
		printf("Invalid exam.\n");
		return 3;
	}


	bool isFound = false;
	struct Day* tempDay = schedule->head;
	struct Exam* tempExam = NULL;

	for (int i = 0; i < 7; i++) {
		if (strcmp(tempDay->dayName, oldDay) == 0) {

			tempExam = tempDay->examList;
			while (tempExam != NULL) {
				if (tempExam->startTime == oldStartTime) {
					isFound = true;
					break;
				}

				tempExam = tempExam->next;
			}

			if (isFound) { break; }
		}

		tempDay = tempDay->nextDay;
	}

	if (isFound) {
		tempDay = schedule->head;
		for (int i = 0; i < 7; i++) {
			if (strcmp(tempDay->dayName, newDay) == 0) {
				if (IsValidTime(tempDay, newStartTime, newEndTime)) {
					AddExamToDay(tempDay, CreateExam(newStartTime, newEndTime, tempExam->courseCode));
					RemoveExamFromSchedule(schedule, oldDay, oldStartTime);
					printf("Update successful.\n");
					return 0;
				}
				else {
					printf("Update unsuccessful.\n");
					return 1;
				}
			}

			tempDay = tempDay->nextDay;
		}
	}

	printf("Exam could not be found.\n");
	return 2;
}

/*
While implementing ClearDay function,
I got confused by the explanation in the homework file
So I assume that, i should relocate the exams as possible as
If there is not any space left for the leftover exams on the day
They will got postponed for upcoming weeks.
*/

// Clear all exams from a specific day and relocate them to other days
int ClearDay(struct Schedule* schedule, const char* day) {
	struct Day* targetDay = NULL;
	struct Exam* tempExam = NULL;
	struct Day* tempDay = schedule->head;
	for (int i = 0; i < 7; i++) {
		if (strcmp(tempDay->dayName, day) == 0) {
			targetDay = tempDay;
			if (tempDay->examList != NULL) {
				tempExam = tempDay->examList;
				break;
			}
			else {
				printf("%s is already clear.\n", tempDay->dayName);
				return 1;
			}
		}
		tempDay = tempDay->nextDay;
	}

	
	while (tempExam != NULL) {
		struct Exam* nextExam = tempExam->next;
		tempDay = targetDay;

		bool isRelocated = false;
		for (int i = 0; i < 7; i++) {
			if (strcmp(tempDay->dayName, day) != 0) {
				for (int j = 8; j <= 17; j++) {
					int endTime = j + (tempExam->endTime - tempExam->startTime);
					if (IsValidTime(tempDay, j, endTime)) {
						AddExamToDay(tempDay, CreateExam(j, endTime, tempExam->courseCode));
						isRelocated = true;
						break;
					}
				}
			}
			if (isRelocated) { break; }
			tempDay = tempDay->nextDay;
		}

		if (isRelocated) {
			RemoveExamFromSchedule(schedule, day, tempExam->startTime);
			tempExam = nextExam;
		}
		else {
			while (tempExam != NULL) {
				printf("Since the schedule is full, exam %s is postponed for later weeks.\n", tempExam->courseCode);
				struct Exam* next = tempExam->next;
				RemoveExamFromSchedule(schedule, day, tempExam->startTime);
				tempExam = next;
			}

			printf("Schedule full.Exams from %s could not be relocated.\n", day);
			return 2;
		}
	}

	printf("%s is cleared, exams relocated.\n", day);
	return 0;
}

// Clear all exams and days from the schedule and deallocate memory
void DeleteSchedule(struct Schedule* schedule) {
	printf("################\n");
	struct Day* temp = schedule->head;
	for (int i = 0; i < 7; i++) {

		struct Exam* tempExam = temp->examList;
		while (tempExam != NULL) {
			struct Exam* nextExam = tempExam->next;
			printf("%s exam is freed\n", tempExam->courseCode);
			free(tempExam);
			tempExam = nextExam;
		}

		struct Day* next = temp->nextDay;
		printf("%s is freed.\n", temp->dayName);
		free(temp);
		temp = next;
	}

	printf("Schedule freed.");
	free(schedule);
}

// Read schedule from file
int ReadScheduleFromFile(struct Schedule* schedule, const char* filename) {
	FILE* file;
	char line[256];
	char day[16];
	int start, end;
	char course[16];

	file = fopen(filename, "r");
	if (file == NULL) {
		printf("File could not be open.\n");
		return 1;
	}

	struct Day* tempDay = schedule->head;
	while (fgets(line, sizeof(line), file)) {
		if (line[0] == '\n') {
			continue;
		}

		if (sscanf(line, "%15s", day) == 1 && day[0] >= 'A' && day[0] <= 'Z') {
			for (int i = 0; i < 7; i++) {
				if (strcmp(tempDay->dayName, day) == 0) { break; }
				else { tempDay = tempDay->nextDay; }
			}
		}
		else if (sscanf(line, "%d %d %15s", &start, &end, course) == 3) {
			AddExamToSchedule(schedule, tempDay->dayName, start, end, course);
		}
	}

	fclose(file);

	return 0;
}


// Write schedule to file
int WriteScheduleToFile(struct Schedule* schedule, const char* filename) {
	FILE* file;
	file = fopen(filename, "w");

	if (file == NULL) {
		printf("File could not be open.\n");
		return 1;
	}

	struct Day* dayCursor = schedule->head;
	for (int i = 0; i < 7; i++) {
		fprintf(file, "%s\n", dayCursor->dayName);

		struct Exam* examCursor = dayCursor->examList;
		while (examCursor != NULL) {
			fprintf(file, "%d %d %s\n", examCursor->startTime, examCursor->endTime, examCursor->courseCode);
			examCursor = examCursor->next;
		}
		fprintf(file, "\n");

		dayCursor = dayCursor->nextDay;
	}
}

//Helper Functions
struct Day* CreateDay(char* day) {
	struct Day* newDay = (struct Day*)malloc(sizeof(struct Day));

	strcpy(newDay->dayName, day);
	newDay->nextDay = NULL;
	newDay->examList = NULL;

	return newDay;
}

void PrintDay(struct Day* day) {
	printf("************\n");
	printf("Day: %s\n", day->dayName);
	
	struct Exam* examCursor = day->examList;
	while (examCursor != NULL) {
		PrintExam(examCursor);
		examCursor = examCursor->next;
	}

	printf("************\n");
}

void PrintSchedule(struct Schedule* schedule) {
	struct Day* temp = schedule->head;
	for (int i = 0; i < 7; i++) {
		PrintDay(temp);
		temp = temp->nextDay;
	}
}

void AddExamToDay(struct Day* day, struct Exam* newExam) {
	if (day->examList == NULL) {
		day->examList = newExam;
		return;
	}

	if (day->examList->startTime > newExam->startTime) {
		newExam->next = day->examList;
		day->examList = newExam;
		return;
	}

	struct Exam* prev = NULL;
	struct Exam* temp = day->examList;
	while (temp != NULL) {

		if (temp->next != NULL) {
			if (temp->next->startTime > newExam->startTime) {
				newExam->next = temp->next;
				temp->next = newExam;
				return;
			}
		}
		else {
			temp->next = newExam;
			return;
		}

		prev = temp;
		temp = temp->next;
	}

	printf("Exam %s could not add to the day. (Probably an logic error)\n", newExam->courseCode);
	return;
}

bool IsValidTime(struct Day* day, int startTime, int endTime) {
	bool isValid = true;

	struct Exam* temp = day->examList;
	while (temp != NULL) {
		if (startTime < temp->endTime && endTime > temp->startTime) {
			isValid = false;
			break;
		}

		temp = temp->next;
	}

	return isValid;
}