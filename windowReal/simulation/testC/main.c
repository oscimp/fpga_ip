#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <math.h>

int writeDataDoubleFromFile(char *filename, double *data, int nb_elem);
int writeDataLongLongFromFile(char *filename, long long *data, int nb_elem);
int readDataFromFile(char *filename, int32_t *data, int nb_elem);

#define NB_ITER 6

void computeHanningWindow(double *windowReal_out, int N)
{
	int i;
	for (i = 0; i < N ; i++)
		windowReal_out[i] = 0.5*(1-cos((2.0*(double)i*M_PI)/((double)N-1.0f)));
}

int main(void)
{
	int nb_coeff = (int)pow(2,11);
	double scale = (double)pow(2,15)-1;
	double *windowReal = (double *)malloc(nb_coeff * sizeof(double));
	long long *win = (long long *)malloc(nb_coeff * sizeof(long long));
	long long *res = (long long *)malloc(NB_ITER * nb_coeff * sizeof(long long));

	int32_t data_in[nb_coeff];
	if (readDataFromFile("../datai.dat", data_in, nb_coeff) == EXIT_FAILURE)
		return EXIT_FAILURE;

	computeHanningWindow(windowReal, nb_coeff);
	int i, ii;
	for (i=0; i < nb_coeff; i++)
		win[i] = (long long)(windowReal[i] * scale);
	writeDataLongLongFromFile("coeff.dat", win, nb_coeff);

	for (ii = 0; ii < NB_ITER; ii++) {
		for (i = 0; i < nb_coeff; i++){
			res[i+nb_coeff*ii] = (data_in[i] * win[i]) >> 15;
			if (i < 20) {
				printf("%d %Ld x %Ld = %Ld => %Ld\n", i, (long int)data_in[i], win[i], data_in[i] * win[i],
					(long long int)res[i]);
			}
		}
	}
		//res[i] = ((i * win[i])/(long long)scale);
	//writeDataDoubleFromFile("resDouble.dat", res, nb_coeff);
	writeDataLongLongFromFile("res.dat", res, NB_ITER * nb_coeff);

	free(res);
	free(windowReal);
	return EXIT_SUCCESS;
}

int writeDataLongLongFromFile(char *filename, long long *data, int nb_elem)
{
	int i;
	FILE *fd = fopen(filename, "w+");
	if (fd == NULL) {
		printf("erreur d'ouverture en ecriture du fichier %s\n", filename);
		return EXIT_FAILURE;
	}

	for (i = 0; i < nb_elem; i++)
		fprintf(fd, "%Ld\n", (long long int)data[i]);

	fflush(fd);
	fclose(fd);
	return EXIT_SUCCESS;
}
int writeDataDoubleFromFile(char *filename, double *data, int nb_elem)
{
	int i;
	FILE *fd = fopen(filename, "w+");
	if (fd == NULL) {
		printf("erreur d'ouverture en ecriture du fichier %s\n", filename);
		return EXIT_FAILURE;
	}

	for (i = 0; i < nb_elem; i++)
		fprintf(fd, "%lf\n", data[i]);

	fflush(fd);
	fclose(fd);
	return EXIT_SUCCESS;
}

int readDataFromFile(char *filename, int32_t *data, int nb_elem)
{
    int32_t tmp_dat;
    int i;
    FILE * fd = fopen(filename, "r");
    if (fd == NULL) {
        printf("erreur d'ouverture du fichier %s\n", filename);
        return EXIT_FAILURE;
    }

    for (i = 0; i < nb_elem; i++) {
        fscanf(fd, "%d\n", &tmp_dat);
        data[i] = tmp_dat;
    }
    fclose(fd);
    return EXIT_SUCCESS;
}

