#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main(void)
{

	uint32_t start = 0xffffffff;
	uint32_t a = start;
	int i;
	for(i = 1; i < start; i++) {
		//int newbit = (((a >> 19) ^ (a >> 2)) & 1);
		int newbit = (((a >> 0) ^ (a >> 3)) & 1);
		a = ((a >> 1) | (newbit << 19)) & 0x0fffff;
		//printf("%d ", a&1);
		printf("%d\n", a);
		if (a == start) {
			printf("repetition period is %d\n", i);
			break;
		}
	}
}
