#include <stdint.h>
#include <stdio.h>

#include "fir.h"

void fir16_In8(short *coeff, int8_t *vali, int8_t *valq, int coeff_size, long data_size, 
		int decim, int32_t *accumi, int32_t *accumq)
{
	int i, ii, offset; 
	int tmp_vali, tmp_valq;

	/* convolution loop */
	for (i=0, offset=0; i< data_size-coeff_size; i+=decim, offset++) {
		/* for each conv */
		for (ii=0; ii<coeff_size; ii++) {
			tmp_vali = (int)(coeff[ii] * vali[i+ii]);
			accumi[offset] += (int32_t)tmp_vali; 
			tmp_valq = (int)(coeff[ii] * valq[i+ii]);
			accumq[offset] += (int32_t)tmp_valq; 
		}
	}
}
void fir16(short *coeff, short *vali, short *valq, int coeff_size, long data_size, 
		int decim, int64_t *accumi, int64_t *accumq)
{
	int i, ii, offset; 
	int tmp_vali, tmp_valq;
	FILE* fd, *fd2;

	/* convolution loop */
	for (i=0, offset=0; i< data_size-coeff_size; i+=decim, offset++) {
		if (offset == 1) {
			fd = fopen("test.txt", "w");
			fd2 = fopen("test2.txt", "w");
		}
		/* for each conv */
		for (ii=0; ii<coeff_size; ii++) {

			tmp_vali = (int)coeff[ii] * (int)vali[i+ii];
			accumi[offset] += (int64_t)tmp_vali; 
			tmp_valq = (int)coeff[ii] * (int)valq[i+ii];
			accumq[offset] += (int64_t)tmp_valq; 
			//if (4==offset) 
			if (offset==1 && ii <20)
				printf("accumq : %d (%d %d %d) %ld %ld\n", ii, coeff[ii], vali[i+ii], valq[i+ii],
				(long int )accumq[offset], accumi[offset]);
			if (offset == 1) {
				fprintf(fd, "%ld %ld\n", accumi[offset], accumq[offset]);
				fprintf(fd2, "%d %d\n", tmp_vali, tmp_valq);
			}
		}
		if (offset == 1) {
			fclose(fd);
			fclose(fd2);
		}
	//	if (offset == 4)
	//			printf("accumq : %ld %ld\n", (long int )accumq[offset], accumi[offset]);
	}
}

void mixer_square(short *data_input, long data_size, int period,
		short *vali, short *valq)
{
	int pos;
	int i;

	for (i=0, pos = 0; i< data_size; i++) {
		if (pos < period/2)
			vali[i] = (data_input[i]);
		else
			vali[i] = -(data_input[i]);

		if (pos == period -1)
			pos = 0;
		else 
			pos++;
	}

	for (i=0, pos = period/4; i< data_size; i++) {
		if (pos < period/2)
			valq[i] = (data_input[i]);
		else
			valq[i] = -(data_input[i]);

		if (pos == period -1)
			pos = 0;
		else 
			pos++;
	}
}
