#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <strings.h>
#include <math.h>
#include "fft.h"

#define SCALE_FACTOR 16
int readVal(char *filename, int64_t *data, int size);
//int writeVal(char *filename, int size);
int writeDataComplexFromFile(char *filename, int64_t *data_i, int64_t *data_q, int nb_elem);

#define FFT_SIZE 2048
#define FILE_SIZE 892928
int main()
{
	int i;
	int64_t *data_re = (int64_t *)malloc(sizeof(int64_t) *FILE_SIZE);
	int64_t *data_im = (int64_t *)malloc(sizeof(int64_t)*FILE_SIZE);
	bzero(data_im, FILE_SIZE * sizeof(int64_t));
	int64_t coeff_re[FFT_SIZE], coeff_im[FFT_SIZE];
	int64_t *resFFT1_re = (int64_t *)malloc(sizeof(int64_t) *FILE_SIZE);
	int64_t *resFFT1_im = (int64_t *)malloc(sizeof(int64_t)*FILE_SIZE);

	/*if (readVal("../gen_data/coeff_re.dat", coeff_re, FFT_SIZE) == EXIT_FAILURE)
		return EXIT_FAILURE;
	if (readVal("../gen_data/coeff_im.dat", coeff_im, FFT_SIZE) == EXIT_FAILURE)
		return EXIT_FAILURE;*/
	if (readVal("/nfs/zc706/share/coeff_fft16_re.dat", coeff_re, FFT_SIZE) == EXIT_FAILURE)
		return EXIT_FAILURE;
	if (readVal("/nfs/zc706/share/coeff_fft16_im.dat", coeff_im, FFT_SIZE) == EXIT_FAILURE)
		return EXIT_FAILURE;
	if (readVal("../out_hanning2p20.dat", data_re, FILE_SIZE) == EXIT_FAILURE)
		return EXIT_FAILURE;

	for (i=0; i < FILE_SIZE; i+=FFT_SIZE) {
		fft_compute((data_re+i), (data_im+i), (resFFT1_re+i), (resFFT1_im+i), FFT_SIZE, 
			coeff_re, coeff_im, SCALE_FACTOR, FFT_SIZE);
	}
	
	writeDataComplexFromFile("result.dat", resFFT1_re, resFFT1_im, FILE_SIZE);
		
	return EXIT_SUCCESS;
}

int writeDataComplexFromFile(char *filename, int64_t *data_i, int64_t *data_q, int nb_elem)
{
	int i;
	FILE *fd = fopen(filename, "w+");
	if (fd == NULL) {
		printf("erreur d'ouverture en ecriture du fichier %s\n", filename);
		return EXIT_FAILURE;
	}

	for (i = 0; i < nb_elem; i++)
		fprintf(fd, "%Ld %Ld\n", (long long int)data_i[i], (long long int)data_q[i]);

	fflush(fd);
	fclose(fd);
	return EXIT_SUCCESS;
}

int readVal(char *filename, int64_t *data, int size)
{
    int i;
    long long int aa;

    FILE *fd = fopen(filename, "r");
    if (fd == NULL) {
        printf("erreur d'ouverture des coefficients\n");
        return EXIT_FAILURE;
    }

    for (i = 0; i < size; i++) {
        fscanf(fd, "%Ld", &aa);
        data[i] = (int64_t)aa;
    }
    fclose(fd);

    return size;
}

