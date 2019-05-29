#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define SHIFT_AND_MASK(__val, __shift)  ((0x01) & (__val >> __shift))

int main(void)
{

	uint32_t start = 4005;
	uint32_t a = start;
	int i;
	uint16_t g1 = 0xffff, g2 = 0xffff;
	uint8_t xor;
	uint8_t s1;

	for(i = 0; i < start; i++) {
		s1 = (0x01 & (g1 >> 9));
		xor = (0x01 & (g2 >> 1)) ^
			(0x01 & (g2 >> 5)); 
		xor = xor ^ s1;
		printf("%d\n", xor&0x01);

		/* g1 */
		xor = (0x01 & (g1 >> 9)) ^ (0x01 & (g1 >> 2));
		g1 = (g1 << 1) | xor;
		s1 = (0x01 & (g1 >> 9));
		//printf("%u ", 0x3ff & g1);

		/* g2 */
		xor = (0x01 & (g2 >> 9)) ^
			(0x01 & (g2 >> 8)) ^
			(0x01 & (g2 >> 7)) ^
			(0x01 & (g2 >> 5)) ^
			(0x01 & (g2 >> 2)) ^
			(0x01 & (g2 >> 1));
		g2 = (g2 << 1) | xor;
		//printf("%u ", 0x3ff&g2);

		

	}
}
