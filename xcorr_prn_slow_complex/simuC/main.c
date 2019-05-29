#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define SHIFT_AND_MASK(__val, __shift)  ((0x01) & (__val >> __shift))

void genCacode(uint8_t *cacode, uint16_t length)
{
	int i;
	uint16_t g1 = 0xffff, g2 = 0xffff;
	uint8_t xor;
	uint8_t s1;

	for(i = 0; i < length; i++) {
		s1 = (0x01 & (g1 >> 9));
		xor = (0x01 & (g2 >> 1)) ^
			(0x01 & (g2 >> 5)); 
		xor = xor ^ s1;
		cacode[i] = xor;
		//printf("%d\n", xor&0x01);

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

int main(void)
{
	uint8_t cacode[4096];
	int16_t val;
	genCacode(cacode, 4096);
	int32_t sum;
	char filename[64];
	FILE *toto;
	FILE *res_fd = fopen("result.txt", "w+");
	if (!res_fd) {
		printf("erreur d'ouverture de result.txt\n");
		return EXIT_FAILURE;
	}

	int cpt=0;
	int i, ii;
	for (ii=0; ii < 4201/*2101*//*3664*/; ii++) {
		sprintf(filename, "cross%d.txt", ii);
		toto = fopen(filename, "w+");
		sum = 0;
		for (i = 0; i < 1023; i++) {
			val = i+ii;
			//val = cacode[ii+i];
			//val = cpt;
			if (cacode[i] == 1)
				sum += val;
			else
				sum -= val;
			fprintf(toto, "prn: %d val: %d sum %d\n", cacode[i], val, sum);
			cpt = (cpt+1)%65536;
		}
		fclose(toto);
		fprintf(res_fd, "%d\n", sum);
	}
#if 0
	uint32_t start = 4000;
	uint32_t a = start;
	int i;
	uint16_t g1 = 0xffff, g2 = 0xffff;
	uint8_t xor;
	uint8_t s1;

	for(i = 1; i < start; i++) {
		/* g1 */
		xor = (0x01 & (g1 >> 9)) ^ (0x01 & (g1 >> 2));
		g1 = (g1 << 1) | xor;
		s1 = (0x01 & (g1 >> 9));
		printf("%u ", 0x3ff & g1);

		/* g2 */
		xor = (0x01 & (g2 >> 9)) ^
			(0x01 & (g2 >> 8)) ^
			(0x01 & (g2 >> 7)) ^
			(0x01 & (g2 >> 5)) ^
			(0x01 & (g2 >> 2)) ^
			(0x01 & (g2 >> 1));
		g2 = (g2 << 1) | xor;
		printf("%u ", 0x3ff&g2);
		
		xor = (0x01 & (g2 >> 1)) ^
			(0x01 & (g2 >> 5)); 
		xor = xor ^ s1;

		printf("%d\n", xor&0x01);
	}
#endif
}
