# PRINTF
This is a try to write printf on assembler. It handles specificators, %b, %c, %d, %o, %s, %x. Call of the function is happening from C: <img width="788" height="437" alt="image" src="https://github.com/user-attachments/assets/1c8c869e-bf92-4fee-a54c-bb2d1bfa84af" />

Maximum amount of output is 256, the programm handles overflow by cutting everything, that is out of range. After user runs the programm, the output : <img width="1303" height="43" alt="image" src="https://github.com/user-attachments/assets/3522a953-614c-4db1-880c-e494f6504bb1" />

You can use my printf as the standart one (extern void my_printf(const char* string, ...); is needed)
