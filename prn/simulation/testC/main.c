#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main(void)
{
    uint8_t start = 0xff;
    uint8_t a = start;
	uint8_t period = 2;
	uint8_t ii;
    int i;    
    for(i = 1; i < 1005/period; i++) {
        int newbit = (((a >> 6) ^ (a & 0x01)) & 1);
		for (ii = 0; ii < period; ii++)
        	printf("%d\n", (unsigned char)(a & 0x01));
        a = ((a << 1) | newbit) & 0x7f;
    }

	return EXIT_SUCCESS;
}
