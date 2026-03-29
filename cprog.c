#include <stdlib.h> 
#include <string.h>
extern void my_printf(const char* string, ...);

int main() {
    char m = 'm';
    char e = 'e';
    char o = 'o';
    char w = 'w';
    char* meow = "meow";
    int h = strlen(meow);
    my_printf("%s%ddfgj", meow, h);
    return 0;
}