#include "schedule.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    struct Schedule* schedule = CreateSchedule(&schedule);

    ReadScheduleFromFile(schedule, "exam_schedule_input.txt");

    AddExamToSchedule(schedule, "Tuesday", 15, 17, "BLG411E");
    AddExamToSchedule(schedule, "Monday", 16, 18, "BLG439E");
    AddExamToSchedule(schedule, "Sunday", 20, 23, "BLG439E");
    RemoveExamFromSchedule(schedule, "Thursday", 11);
    RemoveExamFromSchedule(schedule, "Tuesday", 9);
    UpdateExam(schedule, "Monday", 9, "Monday", 10, 11);
    UpdateExam(schedule, "Tuesday", 10, "Wednesday", 12, 13);
    UpdateExam(schedule, "Wednesday", 15, "Wednesday", 12, 14);
    UpdateExam(schedule, "Sunday", 10, "Sunday", 20, 23);
    ClearDay(schedule, "Wednesday");
    ClearDay(schedule, "Wednesday");

    WriteScheduleToFile(schedule, "exam_schedule_output.txt");

    DeleteSchedule(schedule);
    return 0;
}


//// Create an initial schedule for testing
//struct Schedule* schedule = CreateSchedule();

//// Reading and writing schedule from/to a file
//const char* inputFile = "exam_schedule_input.txt";
//const char* outputFile = "exam_schedule_output.txt";

//// Uncomment to read schedule from file (assuming the input file exists and is correctly formatted)
//// ReadScheduleFromFile(schedule, inputFile);

//// Example: Add exams to the schedule
//AddExamToSchedule(schedule, "Monday", 8, 9, "BLG113E");
//AddExamToSchedule(schedule, "Monday", 9, 10, "BLG223E");
//AddExamToSchedule(schedule, "Sunday", 11, 13, "BLG102E");
//AddExamToSchedule(schedule, "Wednesday", 9, 10, "BLG223E");

//// Example: Remove an exam from the schedule
//RemoveExamFromSchedule(schedule, "Wednesday", 9);

//// Example: Update an exam in the schedule
//UpdateExam(schedule, "Sunday", 11, "Wednesday", 13, 14);  // Corrected time in the example

//// Example: Clear a day in the schedule
//ClearDay(schedule, "Monday");

//// Write schedule to file
//WriteScheduleToFile(schedule, outputFile);

//// Example: Delete the entire schedule
//DeleteSchedule(schedule);