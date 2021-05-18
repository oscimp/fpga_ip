#ifndef _FFT_H
#define _FFT_H

#include <stdint.h>

//#define SCALE_FACTOR 14
//#define SCALE_FACTOR 15
//#define SCALE_FACTOR 16
//#define SCALE_FACTOR 7

/*#define N_FFT 4096
#define LOG_2_N_FFT 12
*/

/*#define N_FFT 128
#define LOG_2_N_FFT 7
*/
/*#define N_FFT 2048
#define LOG_2_N_FFT 11
*/
#if 0
#define N_FFT 2048
#define LOG_2_N_FFT 11

#define N_FFT_DIV_2 (N_FFT/2)
#define N_FFT_DIV_2_PLUS_1 (N_FFT+1)
#define N_FFT_MINUS_1 (N_FFT-1)
#endif

//void fft_accum(int m_index, int64_t x_re, int64_t x_im);
void fft_compute(int64_t *x_re, int64_t *x_im, 
	int64_t *out_re, int64_t *out_im, int n_fft, 
	int64_t * cosLUT, int64_t * sinLUT, int scale_factor, int nb_elem);
void fft_compute_coeff(int64_t *coeffReal, int64_t *coeffImag,
	int scaleFactor, int nb_elem);
//int64_t getValRe(int m_index);
//int64_t getValIm(int m_index);
#endif // _FFT_H
