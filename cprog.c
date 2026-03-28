#include <stdlib.h>
extern void my_printf(const char* string, ...);

int main() {
    char m = 'm';
    char e = 'e';
    char o = 'o';
    char w = 'w';
    int h = 257;
    my_printf("meow = %c %x ", h, h);
    return 0;
}