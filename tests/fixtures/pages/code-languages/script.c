/* TEST: .c entry — exercises the 'code' render mode (highlight.js, language: c) */

#include <stdio.h>

int main(void) {
    int seq[10] = {0, 1};
    for (int i = 2; i < 10; i++) {
        seq[i] = seq[i - 1] + seq[i - 2];
    }
    for (int i = 0; i < 10; i++) {
        printf("%d ", seq[i]);
    }
    printf("\n");
    return 0;
}
