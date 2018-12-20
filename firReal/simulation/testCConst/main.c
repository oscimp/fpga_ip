#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include "fir.h"

//#define DECIM 16
#define DECIM 10
#define COEFFSIZE 128
#define NB_DECADE 1
//#define NB_DECADE 5
/*#define SHIFT 1 */
int readContent(short *tab, char *filename, long nb);

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

	short coeffTab[COEFFSIZE]/*, *valTab*/, *valITab, *valQTab;
	//valTab = (short *)malloc(initSize*sizeof(short));
	valITab = (short *)malloc(initSize*sizeof(short));
	valQTab = (short *)malloc(initSize*sizeof(short));
	if (/*valTab == NULL ||*/ valITab == NULL || valQTab == NULL) {
		perror("encore une autre erreur d'init\n");
		return EXIT_FAILURE;
	}

	i += readContent(coeffTab, "../coeff16.dat", COEFFSIZE);
	i += readContent(valITab, "./datai.dat", initSize);
	i += readContent(valQTab, "./dataq.dat", initSize);
	//i += readContent(valTab, "../dataI.dat", initSize);

	if (i != 0) {
		printf("erreur d'ouverture %d\n", i);
		return EXIT_FAILURE;
	}
	
	for (i = 0; i < initSize; i++) {
		valITab[i] = 2048;
		valQTab[i] = 4096;
	}
	
	/*for (i = 0; i< initSize; i++)
		valTab[i]-=128;*/

	//mixer_square(valTab, initSize, 50, valITab, valQTab);
	//resi_fd = fopen("after_nco.dat", "w");
	/*for (i = 0; i < initSize;i++) {
		fprintf(resi_fd, "%d %d\n", valITab[i], valQTab[i]);
	}
	fflush(resi_fd);
	fclose(resi_fd);*/
	//free(valTab);
	
	/* lecture donnees */

	char decal = 28;//-16;	
	char dec;
	sprintf(filenameQ, "result.dat");
	result = fopen(filenameQ, "w");
	decade = 0;
	/*for (decade = 0; decade < NB_DECADE; decade++) */{
#ifdef SHIFT
		dec = decal -16;
#else
		dec = decal-1;
#endif
		sprintf(filenameI, "resI%d.dat",decade);
		sprintf(filenameQ, "resQ%d.dat",decade);

		resi_fd = fopen(filenameI, "w");
		resq_fd = fopen(filenameQ, "w");
		
		fir16(coeffTab, valITab, valQTab, COEFFSIZE, nextSize, DECIM, accumi, accumq);
		nextSize = (nextSize-COEFFSIZE)/DECIM;
		printf("toto   : %ld %ld\n", accumq[1], accumi[1]);
		for (i = 0; i < nextSize; i++) {
#ifdef SHIFT
			valITab[i] = ((accumi[i] >> dec) & 0xffff);
			valQTab[i] = ((accumq[i] >> dec) & 0xffff);
#else
			valITab[i] =  (short)(0x7fFF&accumi[i]) | ((0x01&(accumi[i] >> dec))<<15);
			valQTab[i] =  (short)(0x7fFF&accumq[i]) | ((0x01&(accumq[i] >> dec))<<15);
#endif
			if (i < 2048) {
				fprintf(resi_fd, "%d %ld\n", valITab[i], accumi[i]);
				fprintf(resq_fd, "%d %ld\n", valQTab[i], accumq[i]);
				fprintf(result, "%ld %ld\n", accumi[i]>>2, accumq[i]>>2);
			}
		}

		fflush(resi_fd);
		fflush(resq_fd);
		fflush(result);
		fclose(resi_fd);
		fclose(resq_fd);
		fclose(result);
		decal = 36;
	}
	free(accumi);
	free(accumq);
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
