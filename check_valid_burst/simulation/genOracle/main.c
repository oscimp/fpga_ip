#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <math.h>

void createContent(short *tabCos, short *tabSin, long length, int gain);
int createFile(char *filename, long length, int gain, int start_offset);

int main(void)
{
	int ADDR_SIZE = 10;
	int length = pow(2, ADDR_SIZE);
	int start_offset = 500;
	
	if (createFile("data_good1", length, 5, start_offset) != EXIT_SUCCESS)
		return EXIT_FAILURE;
	if (createFile("data_good2", length, 7, start_offset) != EXIT_SUCCESS)
		return EXIT_FAILURE;
	if (createFile("data_bad3", length, 9, start_offset) != EXIT_SUCCESS)
		return EXIT_FAILURE;
	if (createFile("data_good4", length, 3, start_offset) != EXIT_SUCCESS)
		return EXIT_FAILURE;


	return EXIT_SUCCESS;
}

int createFile(char *filename, long length, int gain, int start_offset)
{
	int i;
	char file_name[256];
	long accumCos = 0, accumSin = 0;

	sprintf(file_name, "%s_cos.dat", filename);
	FILE *fd_cos = fopen(file_name, "w+");
	if (fd_cos == NULL) {
		printf("erreur d'ouverture de %s\n", file_name);
		return EXIT_FAILURE;
	}

	sprintf(file_name, "%s_sin.dat", filename);
	FILE *fd_sin = fopen(file_name, "w+");
	if (fd_sin == NULL) {
		printf("erreur d'ouverture de %s\n", file_name);
		fclose(fd_cos);
		return EXIT_FAILURE;
	}

	sprintf(file_name, "oracle_%s.dat", filename);
	FILE *fd_oracle = fopen(file_name, "w+");
	if (fd_oracle == NULL) {
		printf("erreur d'ouverture de %s\n", file_name);
		fclose(fd_cos);
		fclose(fd_sin);
		return EXIT_FAILURE;
	}

	short tabCos[length], tabSin[length];
	createContent(tabCos, tabSin, length, gain);
	
	for (i=0; i < length; i++) {
		fprintf(fd_cos, "%d\n", tabCos[i]);
		fprintf(fd_sin, "%d\n", tabSin[i]);
		fprintf(fd_oracle, "%d %d\n", tabSin[i], tabCos[i]);
		if (i >= start_offset) {
			accumCos += abs(tabCos[i]);
			accumSin += abs(tabSin[i]);
		}
	}
	printf("max pour %s : \t %ld pour cos et %ld pour sin\n", filename, accumCos, accumSin);
	fclose(fd_cos);
	fclose(fd_sin);
	fclose(fd_oracle);

	return EXIT_SUCCESS;
}

void createContent(short *tabCos, short *tabSin, long length, int gain)
{
	double step = 2*M_PI/length;
	double i;
	int ii;
	double cos_v, sin_v;
	for (ii=0, i=0.0f; ii < length; ii++,i+=step)
	{
		cos_v = cos(i);	
		sin_v = sin(i);	
		tabCos[ii] = (short)(cos_v * (pow(2,gain-1)-1));
		tabSin[ii] = (short)(sin_v * (pow(2,gain-1)-1));
	}
}
