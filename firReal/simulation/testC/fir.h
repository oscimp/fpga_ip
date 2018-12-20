#ifndef __FIR_H__
#define __FIR_H__
void fir16_In8(short *coeff, int8_t *vali, int8_t *valq, int coeff_size, long data_size, 
		int decim, int32_t *accumi, int32_t *accumq);
void fir16(short *coeff, short *vali, short *valq, int coeff_size, long data_size, 
		int decim, int64_t *accumi, int64_t *accumq);
void mixer_square(short *data_input, long data_size, int period, short *vali, short *valq);
#endif /*__FIR_H__*/
