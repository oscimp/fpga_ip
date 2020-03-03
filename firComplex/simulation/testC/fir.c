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
	//FILE* fd;
	//int sec_store=1+coeff_size/decim;
	//char filename[255];
	//FILE *fd_conv;

	/* convolution loop */
	//printf("%ld\n", data_size-coeff_size);
	for (i=0, offset=0; i< data_size-coeff_size; i+=decim, offset++) {
		accumi[offset] = 0;
		accumq[offset] = 0;
		/*sprintf(filename, "result_%03d.dat", offset);
		fd_conv = fopen(filename, "w");
		if (offset == 1) {
			fd = fopen("test_off.txt", "w");
		}else if (offset == sec_store) {
			printf("plop\n");
			fd = fopen("test_off2.txt", "w");
		}*/

		/* for each conv */
		for (ii=0; ii<coeff_size; ii++) {

			tmp_vali = (int)coeff[ii] * (int)vali[i+ii];
			accumi[offset] += (int64_t)tmp_vali; 
			tmp_valq = (int)coeff[ii] * (int)valq[i+ii];
			accumq[offset] += (int64_t)tmp_valq; 
			//if (4==offset) 
			/*if (offset==1 && ii <20)
				printf("accumq : %d (%d %d %d) %ld %ld\n", ii, coeff[ii], vali[i+ii], valq[i+ii],
				(long int )accumq[offset], accumi[offset]);
			if (offset == sec_store && ii == 0)
				printf("%d x %d\n", vali[i+ii], coeff[ii]);*/
			/*if (offset == 1 || offset == sec_store) {
				fprintf(fd, "%d x %d => %ld %ld\n", vali[i+ii], coeff[ii], accumi[offset], accumq[offset]);
				//fprintf(fd2, "%d %d\n", tmp_vali, tmp_valq);
			}*/
			/*if (ii == 0) {
				printf("ii=%d %d %d %d\n", ii, coeff[ii], vali[i+ii], valq[i+ii]);
			}*/

			//fprintf(fd_conv, "%d %d x %d => %ld %ld\n", i, vali[i+ii], coeff[ii], accumi[offset], accumq[offset]);

		}
		/*if (offset == 1 || offset == sec_store) {
			fclose(fd);
			//fclose(fd2);
		}*/
		//fclose(fd_conv);
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
