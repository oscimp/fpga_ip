#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int writeShortVal(char *file_re, char *file_im, int *real, int *imag, int size);
void computeCoeff(int N, double *coeffReal, double *coeffImag)
{
	int i;
	for (i = 0; i <= N/2; i++) {
		coeffReal[i] = cos(2*M_PI*i/N);
		coeffImag[i] = -sin(2*M_PI*i/N);
	}
}

int writeVal(char *file_re, char *file_im, double *real, double *imag, int size)
{
	int i;
	FILE *fd_re = fopen(file_re, "w+");
	FILE *fd_im = fopen(file_im, "w+");
	if (fd_re == NULL || fd_im == NULL) {
		printf("erreur d'ouverture des coefficients\n");
		return EXIT_FAILURE;
	}
	for (i = 0; i < size; i++) {
		fprintf(fd_re, "%lf\n", real[i]);
		fprintf(fd_im, "%lf\n", imag[i]);
	}
	fclose(fd_re);
	fclose(fd_im);
	return size;
}

int main(void)
{
	int N = 2048;
	int SCALE_FACTOR = 16;
	int i;
	double coeffImag[N], coeffReal[N];
	int coeffImS[N], coeffReS[N];

	computeCoeff(N, coeffReal, coeffImag);
	int scaleFactor = pow(2, SCALE_FACTOR)-1;
	scaleFactor = pow(2, SCALE_FACTOR);
	for (i=0; i<N; i++) {
		coeffImS[i] = (int)(coeffImag[i] * scaleFactor);
		coeffReS[i] = (int)(coeffReal[i] * scaleFactor);
	}
	writeShortVal("coeff_re.dat", "coeff_im.dat", coeffReS, coeffImS, N); 
	writeVal("coeffF_re.dat", "coeffF_im.dat", coeffReal, coeffImag, N); 

	return EXIT_SUCCESS;
}

int writeShortVal(char *file_re, char *file_im, int *real, int *imag, int size)
{
	int i;
	FILE *fd_re = fopen(file_re, "w+");
	FILE *fd_im = fopen(file_im, "w+");
	if (fd_re == NULL || fd_im == NULL) {
		printf("erreur d'ouverture des coefficients\n");
		return EXIT_FAILURE;
	}
	for (i = 0; i < size; i++) {
		fprintf(fd_re, "%d\n", real[i]);
		fprintf(fd_im, "%d\n", imag[i]);
	}
	fclose(fd_re);
	fclose(fd_im);
	return size;
}
