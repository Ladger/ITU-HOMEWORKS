#include <stdlib.h>
#include "../include/scheduler.h"

/*
 * Creates and initializes a new scheduler instance.
 * The capacity parameter determines the maximum number of processes that can be managed.
 * Returns a pointer to the new scheduler, or NULL if allocation fails.
 */
Scheduler* create_scheduler(int capacity) {
    Scheduler* scheduler = (Scheduler*)malloc(sizeof(Scheduler));
    if (!scheduler) return NULL;

    scheduler->process_queue = heap_create(capacity, sizeof(Process), compare_vruntime);
    if (!scheduler->process_queue) {free(scheduler); return NULL;}

    scheduler->current_process = NULL;
    scheduler->time_slice = 100;

    return scheduler;
}

/*
 * Deallocates all resources associated with the scheduler.
 * This includes freeing the process queue, current process, and scheduler structure itself.
 * Should be called when the scheduler is no longer needed to prevent memory leaks.
 */
void destroy_scheduler(Scheduler* scheduler) {
    if (!scheduler) return;

    if (scheduler->current_process) {
        free(scheduler->current_process);
    }

    heap_destroy(scheduler->process_queue);
    free(scheduler);
}

/*
 * Adds a new process to the scheduler's queue.
 * The process is inserted into the min-heap based on its virtual runtime,
 * maintaining the scheduling order where processes with lower virtual runtime
 * have higher priority for execution.
 */
void schedule_process(Scheduler* scheduler, Process process) {
    if (!scheduler) return;

    heap_insert(scheduler->process_queue, &process);
}

/*
 * Retrieves the next process to be executed based on virtual runtime.
 * Returns the process with the lowest virtual runtime from the queue.
 * If a process is currently running, it is placed back in the queue.
 * Returns NULL if no processes are available for execution.
 */
Process* get_next_process(Scheduler* scheduler) {
    if (!scheduler || heap_size(scheduler->process_queue) == 0) return NULL;

    if (scheduler->current_process) {
        scheduler->current_process->is_running = false;
        schedule_process(scheduler, *scheduler->current_process);
    }

    if (!scheduler->current_process) {
        scheduler->current_process = (Process*)malloc(sizeof(Process));
        if (!scheduler->current_process) return NULL;
    }

    heap_extract_min(scheduler->process_queue, scheduler->current_process);
    scheduler->current_process->is_running = true;

    return scheduler->current_process;
}


/*
 * Updates the scheduler state for one time slice unit.
 * Increments the virtual runtime of the currently executing process
 */
void tick(Scheduler* scheduler) {
    if (!scheduler || !scheduler->current_process) return;

    update_vruntime(scheduler->current_process, scheduler->time_slice);
}

int compare_vruntime(const void* a, const void* b) {
    const Process* p1 = (const Process*)a;
    const Process* p2 = (const Process*)b;

    return p1->vruntime - p2->vruntime;
}