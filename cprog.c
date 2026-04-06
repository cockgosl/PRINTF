#include <stdlib.h> 
#include <string.h>
extern void my_printf(const char* string, ...);

int main() {
    int h = 987;
    my_printf("%x\n", h); //output will be : 3DB
    return 0;
}
