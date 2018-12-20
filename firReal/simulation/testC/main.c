#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include "fir.h"

//#define DECIM 16
//#define DECIM 10
//#define DECIM 1
//#define DECIM 2
//#define DECIM 3
//#define DECIM 10
//#define DECIM 10
#define DECIM 1
#define COEFFSIZE 128
//#define NB_DECADE 1
//#define NB_DECADE 5
int readContent(short *tab, char *filename, long nb);

int fullGen(short *coeff, int coeff_size, short *data, int data_size)
{
	long initSize = data_size;
	long int *accumi, *accumq;
	long nextSize;
	char filenameI[512];
	FILE *resi_fd;
	int i;

	accumi = (long int *)malloc(initSize*sizeof(long int));
	if (accumi == NULL) {
		perror("erreur d'initialisation");
		return EXIT_FAILURE;
	}
	accumq = (long int *)malloc(initSize*sizeof(long int));
	if (accumq == NULL) {
		perror("erreur d'initialisation");
		return EXIT_FAILURE;
	}

	int decim;
	for (decim = 1; decim <= 128; decim ++) {
		sprintf(filenameI, "dump_resI%d.txt",decim);
		resi_fd = fopen(filenameI, "w");

		fir16(coeff, data, data, coeff_size, initSize, decim, accumi, accumq);

		nextSize = (initSize-COEFFSIZE)/DECIM;
		for (i = 0; i < nextSize; i++) {
			fprintf(resi_fd, "%ld\n", accumi[i]);
		}
		fflush(resi_fd);
		fclose(resi_fd);
	}
	free(accumi);
	free(accumq);
	return EXIT_SUCCESS;
}

int main(void)
{
	int i=0, decade;
	char filenameI[512], filenameQ[512];
	long initSize = 2048;//1024;
	long nextSize = initSize;
	FILE *resi_fd, *resq_fd, *result;

	long int *accumi, *accumq;

	accumi = (long int *)malloc(initSize*sizeof(long int));
	if (accumi == NULL) {
		perror("erreur d'initialisation");
		return EXIT_FAILURE;
	}

	accumq = (long int *)malloc(initSize*sizeof(long int));
	if (accumq == NULL) {
		perror("erreur d'initialisation");
		return EXIT_FAILURE;
	}

	short coeffTab[COEFFSIZE], *valITab, *valQTab;
	valITab = (short *)malloc(initSize*sizeof(short));
	valQTab = (short *)malloc(initSize*sizeof(short));
	if (valITab == NULL || valQTab == NULL) {
		perror("encore une autre erreur d'init\n");
		return EXIT_FAILURE;
	}

	i += readContent(coeffTab, "../coeff16.dat", COEFFSIZE);
	i += readContent(valITab, "../dataq.dat", initSize);
	i += readContent(valQTab, "../dataq.dat", initSize);

	if (i != 0) {
		printf("erreur d'ouverture %d\n", i);
		return EXIT_FAILURE;
	}

	FILE *fake_coeff = fopen("../fake_coeff.dat", "w+");
	for (i = 0; i < COEFFSIZE; i++) {
		coeffTab[i] = i+128;
		fprintf(fake_coeff, "%d\n",coeffTab[i]);
	}
	fclose(fake_coeff);
	
	
	/* lecture donnees */

	char decal = 28;	
	char dec;
	sprintf(filenameQ, "result.dat");
	result = fopen(filenameQ, "w");
	decade = 0;

	dec = decal-1;
	sprintf(filenameI, "resI%d.dat",decade);
	sprintf(filenameQ, "resQ%d.dat",decade);

	resi_fd = fopen(filenameI, "w");
	resq_fd = fopen(filenameQ, "w");
		
	fir16(coeffTab, valITab, valQTab, COEFFSIZE, nextSize, DECIM, accumi, accumq);
	nextSize = (nextSize-COEFFSIZE)/DECIM;
	printf("toto   : %ld %ld\n", accumq[1], accumi[1]);
	for (i = 0; i < nextSize; i++) {
		valITab[i] =  (short)(0x7fFF&accumi[i]) | ((0x01&(accumi[i] >> dec))<<15);
		valQTab[i] =  (short)(0x7fFF&accumq[i]) | ((0x01&(accumq[i] >> dec))<<15);

		if (i < 2048) {
			//fprintf(resi_fd, "%d %ld\n", valITab[i], accumi[i]);
			fprintf(resi_fd, "%ld\n", accumi[i]);
			fprintf(resq_fd, "%ld\n", accumq[i]);
			//fprintf(resq_fd, "%d %ld\n", valQTab[i], accumq[i]);
			fprintf(result, "%ld %ld\n", accumi[i], accumq[i]);
		}
	}

	fflush(resi_fd);
	fflush(resq_fd);
	fflush(result);
	fclose(resi_fd);
	fclose(resq_fd);
	fclose(result);
	
	free(accumi);
	free(accumq);

	i += readContent(valITab, "../dataq.dat", initSize);
	i += readContent(valQTab, "../dataq.dat", initSize);
	fullGen(coeffTab, COEFFSIZE, valITab, initSize);

	free(valITab);
	free(valQTab);
	return EXIT_SUCCESS;
}

int readContent(short *tab, char *filename, long nb)
{
	int i, tmp;
	FILE *fd = fopen(filename, "r");
	if (fd == NULL) {
		printf("erreur d'ouverture de %s\n", filename);
		return -1;
	}

	for (i = 0; i < nb; i++) {
		fscanf(fd, "%d", &tmp);
		tab[i] = (short)tmp;
	}
	fclose(fd);
	return 0;
}
