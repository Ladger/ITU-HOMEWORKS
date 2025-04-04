#include "tree.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

TreeNode *init_node(GameState *gs) {
    TreeNode* node = (TreeNode*)malloc(sizeof(TreeNode));

    node->children = NULL;
    node->game_state = gs;
    node->num_children = -1;

    return node;
}

TreeNode *init_tree(GameState *gs, int depth) {
    TreeNode* root = init_node(gs);

    for (int i = 0; i < depth - 1; i++) {
        expand_tree(root);
    }

    return root;
}

void free_tree(TreeNode *root) {
    if (root == NULL) return;

    for (int i = 0; i < root->num_children; i++) {
        free_tree(root->children[i]);
    }

    free_game_state(root->game_state);
    free(root->children);
    free(root);
}

void expand_tree(TreeNode *root) {
    if (root == NULL) return;
    if (get_game_status(root->game_state) != IN_PROGRESS) return;

    bool moves[root->game_state->width];
    memset(moves, 0, sizeof(bool) * root->game_state->width);
    int availables = available_moves(root->game_state, moves);

    for (int i = 0; i < root->num_children; i++) {
        expand_tree(root->children[i]);
    }

    if (root->num_children == -1) {
        if (availables > 0) {
            root->num_children = availables;
            root->children = (TreeNode**)malloc(sizeof(TreeNode*) * availables);

            int index = 0;
            for (int i = 0; i < root->game_state->width; i++) {
                if (moves[i]) {
                    GameState* next = make_move(root->game_state, i);
                    root->children[index] = init_node(next);
                    index++;
                }
            }
        }
        else {
            root->num_children = 0;
        }
    }
}

int node_count(TreeNode *root) {
    if (root == NULL) return 0;

    int count = 1;
    for (int i = 0; i < root->num_children; i++) {
        count += node_count(root->children[i]);
    }

    return count;
}

void print_tree(TreeNode *root, int level) {
    if (root == NULL) return;
    if (root->game_state == NULL) return;

    printf("Level %d\n", level);
    for (int i = 0; i < root->game_state->height; i++) {
        for (int j = 0; j < root->game_state->width; j++) {
            printf("%c ", root->game_state->board[i * root->game_state->width + j]);
        }
        printf("\n");
    }

    for (int i = 0; i < root->num_children; i++) {
        print_tree(root->children[i], level + 1);
    }
}
