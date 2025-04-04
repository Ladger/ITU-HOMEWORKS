#include <stddef.h>
#include "../include/min_heap.h"

// Creates a new heap with initial capacity
// Element_size specifies the size of stored elements in bytes
// Compare function must return negative if first argument is smaller
MinHeap* heap_create(size_t capacity, size_t element_size, int (*compare)(const void*, const void*)) {
    MinHeap* heap = (MinHeap*)malloc(sizeof(MinHeap));
    if (!heap) {
        return NULL;
    }

    heap->data = malloc(capacity * element_size);
    if (!heap->data) {
        free(heap);
        return NULL;
    }

    heap->element_size = element_size;
    heap->capacity = capacity;
    heap->size = 0;
    heap->compare = compare;

    return heap;
}

// Deallocates all memory used by the heap
void heap_destroy(MinHeap* heap) {
    free(heap->data);
    free(heap);
}

// Adds new element to heap
// Element is added at the end and bubbled up to maintain heap property
// If heap is full, capacity is doubled automatically
// Returns 1 if successful, 0 if memory allocation fails
int heap_insert(MinHeap* heap, const void* element) {
    if (heap->capacity == heap->size) {
        size_t new_capacity = heap->capacity * 2;
        void* new_data = realloc(heap->data, new_capacity * heap->element_size);
        if (!new_data) {return 0;}

        heap->data = new_data;
        heap->capacity = new_capacity;
    }

    void* target = (char*)heap->data + heap->size * heap->element_size;
    memcpy(target, element, heap->element_size);

    heapify_up(heap, heap->size);
    heap->size++;
    
    return 1;
}

// Removes and returns the minimum element (root)
// Last element is moved to root and bubbled down
// Returns 1 if successful, 0 if heap is empty
int heap_extract_min(MinHeap* heap, void* result) {
    if (!heap || heap->size == 0) return 0;
    if (!result) return 0;

    memcpy(result, heap->data, heap->element_size);

    void* last = (char*)heap->data + heap->element_size * (heap->size-1);
    memcpy(heap->data, last, heap->element_size);
    heap->size--;

    heapify_down(heap, 0);
    return 1;
}

// Returns the minimum element without removing it
// Returns 1 if successful, 0 if heap is empty
int heap_peek(const MinHeap* heap, void* result) {
    if (heap->size == 0) { return 0; }

    memcpy(result, heap->data, heap->element_size);
    return 1;
}

// Returns current number of elements in heap
size_t heap_size(const MinHeap* heap) {
    return heap->size;
}

// Merges heap2 into heap1
// Grows capacity of heap1 if needed
// Returns 1 if successful, 0 if memory allocation fails or heaps are incompatible
int heap_merge(MinHeap* heap1, const MinHeap* heap2) {
    if (!heap1 || !heap2 || heap1->element_size != heap2->element_size || heap1->compare != heap2->compare) {
        return 0;
    }

    MinHeap* original_heap = heap_create(heap1->capacity, heap1->element_size, heap1->compare);
    if (!original_heap) return 0;

    memcpy(original_heap->data, heap1->data, heap1->size * heap1->element_size);
    original_heap->size = heap1->size;

    for (size_t i = 0; i < heap2->size; i++) {
        void* element = (char*)heap2->data + i * heap2->element_size;
        if (!heap_insert(heap1, element)) {
            // Restore original heap
            memcpy(heap1->data, original_heap->data, original_heap->size * original_heap->element_size);
            heap1->size = original_heap->size;
            heap1->capacity = original_heap->capacity;

            heap_destroy(original_heap);
            return 0;
        }
    }

    heap_destroy(original_heap);
    return 1;
}

void heapify_up(MinHeap* heap, size_t index) {
    if (index == 0) return;

    size_t parent_index = (index - 1) / 2;

    void* parent = (char*)heap->data + heap->element_size * parent_index;
    void* current = (char*)heap->data + heap->element_size * index;

    if (heap->compare(current, parent) < 0) {
        heap_element_swap(heap, current, parent);

        heapify_up(heap, parent_index);
    }
}

void heapify_down(MinHeap* heap, size_t index) {
    size_t left_index = index * 2 + 1;
    size_t right_index = index * 2 + 2;
    size_t smallest = index;

    void* current = (char*)heap->data + index * heap->element_size;

    if (left_index < heap->size) {
        void* left = (char*)heap->data + left_index * heap->element_size;
        if (heap->compare(left, current) < 0) {
            smallest = left_index;
        }
    }

    if (right_index < heap->size) {
        void* right = (char*)heap->data + right_index * heap->element_size;
        if (heap->compare(right, (char*)heap->data + smallest * heap->element_size) < 0) {
            smallest = right_index;
        }
    }

    if (index != smallest) {
        void* smallest_element = (char*)heap->data + smallest * heap->element_size;
        heap_element_swap(heap, current, smallest_element);

        heapify_down(heap, smallest);
    }
}

void heap_element_swap(MinHeap* heap, void* a, void* b) {
    char temp[heap->element_size];
    memcpy(temp, a, heap->element_size);
    memcpy(a, b, heap->element_size);
    memcpy(b, temp, heap->element_size);
}