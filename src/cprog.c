#include <stdlib.h> 
#include <string.h>
extern void my_printf(const char* string, ...);

int main() {
    int h = 987;
    my_printf("%o\n%d %s %x %d%%%c%b\n%d %s %x %d%%%c%b", -1, -1, "love", 3802, 100, 33, 127,
                                                                 -1, "love", 3802, 100, 33, 127);
                                                                 
    //Expected Output:
    //0o377777777777
    //-1 love 0x430 100%!0b1111111
    //-1 love 0x430 100%!0b1111111
    return 0;
}
