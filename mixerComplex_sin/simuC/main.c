#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <math.h>

int main(void)
{
	int data_size = 16;
	int nco_size = 16;
	int mult_size = data_size + nco_size;
	int shift = mult_size - data_size;

	int nco_i = 32767;
	int nco_q = -32768;

	int data_i = 1;
	int data_q = 10;

	int result_i = 0;
	int result_q = 0;

	int i;
	for (i=0; i < 10; i++) {
		printf("%d : ", i);
		printf("\t%d %d\n", data_i * nco_i, data_q * nco_q);
		printf("\t%d %d\n", data_q * nco_i, data_i * nco_q);
		result_i = data_i * nco_i - data_q * nco_q;
		result_q = data_i * nco_q + data_q * nco_i;
		printf("\t%d %d %d(%d) %d(%d)\n", data_i, data_q,
		result_i >> shift, result_i, result_q >> shift, result_q);

		data_q = data_i + 10;
		data_i = data_i + 1;
	}

	return EXIT_SUCCESS;
}
