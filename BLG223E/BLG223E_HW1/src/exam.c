#include "exam.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Function to create a new exam and link it properly in the day
struct Exam* CreateExam(int startTime, int endTime, const char* courseCode) {
	struct Exam* newExam = (struct Exam*)malloc(sizeof(struct Exam));
	
	strcpy(newExam->courseCode, courseCode);
	newExam->startTime = startTime;
	newExam->endTime = endTime;
	newExam->next = NULL;

	return newExam;
}

void PrintExam(struct Exam* exam) {
	printf("----------\n");
	printf("Course Code: %s\n", exam->courseCode);
	printf("Start Time: %d:00\n", exam->startTime);
	printf("End Time: %d:00\n", exam->endTime);
	printf("----------\n");
}