#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include "fft.h"

#define DUMP_FD

int bit_rev(int a, int n_bits);
#if 0
int64_t m_x_n_re[N_FFT];
int64_t m_x_n_im[N_FFT];
#endif

void fft_compute_coeff(int64_t *coeffReal, int64_t *coeffImag,
	int scaleFactor, int nb_elem)
{
	double valR, valI;
	int i;
	for (i = 0; i <= nb_elem/2; i++) {
		valR = cos(2*M_PI*i/nb_elem);
		valI = -sin(2*M_PI*i/nb_elem);
		coeffReal[i] = (int64_t) (valR * (double)scaleFactor);
		coeffImag[i] = (int64_t) (valI * (double)scaleFactor);
	}
}

void fft_accum(int nb_elem, int64_t *x_re, int64_t *x_im,
		int64_t *m_x_n_re, int64_t *m_x_n_im, int16_t LOG_2_N_FFT)
{
	printf("%d\n", LOG_2_N_FFT);
	int reverse_index;
	int i; 
	for (i = 0; i < nb_elem; i++) {
		reverse_index = bit_rev(i, LOG_2_N_FFT);
		m_x_n_re[reverse_index] = x_re[i];
		m_x_n_im[reverse_index] = x_im[i];
	}

}

void fft_compute(int64_t *x_re, int64_t *x_im, 
	int64_t *out_re, int64_t *out_im, int n_fft, 
	int64_t * cosLUT, int64_t * sinLUT, int SCALE_FACTOR, int nb_elem)
{
	//uint16_t i;		// Misc index
	int16_t N_FFT_DIV_2 = n_fft/2;
	int16_t LOG_2_N_FFT = (int16_t)log2f((float)n_fft);
	//int16_t N_FFT_DIV_2_PLUS_1 = N_FFT_DIV_2+1;//n_fft+1;
	int16_t N_FFT_MINUS_1 = n_fft-1;
	int64_t m_x_n_re[n_fft];
	int64_t m_x_n_im[n_fft];

	int16_t n_of_b = N_FFT_DIV_2;	// Number of butterflies
	int16_t s_of_b = 1;				// Size of butterflies
	int16_t a_index = 0;			// FFT data index
	int16_t a_index_ref = 0;		// FFT data index reference
	uint8_t stage = 0;				// Stage of the fft, 0 to log2(N_FFT) - 1

	int16_t nb_index;				// Number of butterflies index
	int16_t sb_index;				// Size of butterflies index
#ifdef DUMP_FD
	char filename[256];
	FILE *fd;
#endif
	/* reverse order */
	fft_accum(nb_elem, x_re, x_im, m_x_n_re, m_x_n_im, LOG_2_N_FFT);

#ifdef DUMP_FD
		sprintf(filename, "tmp_res_%d.txt", stage);
		fd = fopen(filename, "w+");
		if (fd == NULL) {
			printf("problem\n");
			return;
		}
#endif
	// FFT loop (in place ? = yes)
	/*loop_stage:*/ for (stage = 0; stage < LOG_2_N_FFT; ++stage) {
 		/*loop_radix:*/ for (nb_index = 0; nb_index < n_of_b; nb_index++) {
			int64_t tf_index = 0;	// The twiddle factor index
			/*loop_butterfly:*/	for (sb_index = 0; sb_index < s_of_b; ++sb_index) {
				int64_t resultMulReCos, resultMulImCos, resultMulReSin, resultMulImSin;
				//int64_t tresultMulReCos, tresultMulImCos, tresultMulReSin, tresultMulImSin;

				int64_t b_index = a_index + s_of_b;	// 2nd FFT data index

				resultMulReCos = ((int64_t) cosLUT[tf_index] * (int64_t) m_x_n_re[b_index]) >> SCALE_FACTOR;	// Why >> 7 ? = remove the SCALE
				resultMulReSin = ((int64_t) sinLUT[tf_index] * (int64_t) m_x_n_re[b_index]) >> SCALE_FACTOR;
				resultMulImCos = ((int64_t) cosLUT[tf_index] * (int64_t) m_x_n_im[b_index]) >> SCALE_FACTOR;
				resultMulImSin = ((int64_t) sinLUT[tf_index] * (int64_t) m_x_n_im[b_index]) >> SCALE_FACTOR;

				/*tresultMulReCos = ((int64_t) cosLUT[tf_index] * (int64_t) m_x_n_re[b_index]);	// Why >> 7 ? = remove the SCALE
				tresultMulReSin = ((int64_t) sinLUT[tf_index] * (int64_t) m_x_n_re[b_index]);
				tresultMulImCos = ((int64_t) cosLUT[tf_index] * (int64_t) m_x_n_im[b_index]);
				tresultMulImSin = ((int64_t) sinLUT[tf_index] * (int64_t) m_x_n_im[b_index]); */

#ifdef DUMP_FD
				fprintf(fd, "stage%Ld nb_index%d sb_index%Ld a_index%Ld b_index%Ld ", (long long int)stage, nb_index, (long long int)sb_index, 
					(long long int)a_index, (long long int)b_index);
				fprintf(fd, "%Ld %Ld %Ld %Ld ", (long long int)cosLUT[tf_index], (long long int)sinLUT[tf_index],
					(long long int)m_x_n_re[b_index], (long long int)m_x_n_im[b_index]);
#endif
				m_x_n_re[b_index] = m_x_n_re[a_index] - (int64_t) resultMulReCos + (int64_t) resultMulImSin;
				m_x_n_im[b_index] = m_x_n_im[a_index] - (int64_t) resultMulReSin - (int64_t) resultMulImCos;
				m_x_n_re[a_index] = m_x_n_re[a_index] + (int64_t) resultMulReCos - (int64_t) resultMulImSin;
				m_x_n_im[a_index] = m_x_n_im[a_index] + (int64_t) resultMulReSin + (int64_t) resultMulImCos;

#ifdef DUMP_FD
				//fprintf(fd, "%Ld %Ld %Ld %Ld ", (long long int)tresultMulReCos, (long long int) tresultMulReSin,
				//	(long long int) tresultMulImCos, (long long int)tresultMulImSin);
				fprintf(fd, "%Ld %Ld %Ld %Ld ", (long long int)resultMulReCos, (long long int) resultMulReSin,
					(long long int) resultMulImCos, (long long int)resultMulImSin);
				fprintf(fd, "%Ld %Ld %Ld %Ld\n", (long long int)m_x_n_re[a_index], (long long int)m_x_n_im[a_index],
					(long long int)m_x_n_re[b_index], (long long int)m_x_n_im[b_index]);
#endif

				if (((sb_index + 1) & (s_of_b - 1)) == 0)
					a_index = a_index_ref;
				else
					++a_index;

				tf_index += n_of_b;
			}
			a_index = ((s_of_b << 1) + a_index) & N_FFT_MINUS_1;
			a_index_ref = a_index;
		}
		n_of_b >>= 1;
		s_of_b <<= 1;
	}
#ifdef DUMP_FD
		fclose(fd);
#endif
	int i;
	for (i = 0; i < n_fft; i++) {
		out_re[i] = m_x_n_re[i];
		out_im[i] = m_x_n_im[i];
	}
}

#if 0
int64_t getValRe(int m_index)
{
	return m_x_n_re[m_index];
}

int64_t getValIm(int m_index)
{
	return m_x_n_im[m_index];
}
#endif
int bit_rev(int a, int n_bits)
{
	int i, rev_a = 0;
	for (i = 0; i < n_bits; ++i) {
		rev_a = (rev_a << 1) | (a & 1);
		a = a >> 1;
	}

	return rev_a;
}

#if 0
void FFTrearrange_data(int32_t data[N_FFT])
{
	int32_t tmp;
	int16_t i;
	for (i = 0; i < N_FFT; ++i) {
		if (bit_rev(i, LOG_2_N_FFT) > i) {
			tmp = data[i];
			data[i] = data[bit_rev(i, LOG_2_N_FFT)];
			data[bit_rev(i, LOG_2_N_FFT)] = tmp;
		}
	}
}
#endif
