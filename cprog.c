#include <stdlib.h> 
extern void my_printf(const char* string, ...);

int main() {
    char m = 'm';
    char e = 'e';
    char o = 'o';
    char w = 'w';
    int h = 257;
    my_printf("meow = %c , %d  ,%x\n", m, h, h);
    return 0;
}