#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <math.h>

int readContent(short *tab, char *filename, long nb);
void createContent(short *tab, long nb, int DATA_SIZE);
void genHeader(FILE *fd, char *filename, int data_size, int addr_size);
void genContent(FILE *fd, short *content, long nb, int data_size);
void genFooter(FILE *fd);

int main(void)
{
	int ADDR_SIZE = 12;
	int DATA_SIZE = 16;
	int nb = pow(2, ADDR_SIZE);
	char filename[256];
	char entity_name[256];
	sprintf(entity_name, "nco_counter_cos_rom_a%d_d%d", ADDR_SIZE, DATA_SIZE);
	sprintf(filename, "%s.vhd", entity_name);
	FILE *fd = fopen(filename, "w+");
	if (fd == NULL) {
		printf("erreur d'ouverture\n");
		return EXIT_FAILURE;
	}

	short *tabCos = (short *)malloc(sizeof(short) * nb);
	createContent(tabCos, nb, DATA_SIZE);
	//readContent(tabCos, "dds_cos.dat", pow(2,ADDR_SIZE));
	genHeader(fd, entity_name, DATA_SIZE, ADDR_SIZE);
	genContent(fd, tabCos, pow(2, ADDR_SIZE), DATA_SIZE);
	genFooter(fd);
	free(tabCos);

	return EXIT_SUCCESS;
}

#define printBin(_fd, _res, _size) { \
	int __i__;\
	for (__i__=_size-1; __i__>=0; __i__--) \
	fprintf(_fd,"%d",(int)((_res>>__i__)&0x01));}

void genContent(FILE *fd, short *content, long nb, int data_size)
{
	int i;
	for (i=0; i<nb; i++) {
		//printf("%hd\n", content[i]);
		fprintf(fd, "\t\t\"");
		printBin(fd, content[i], data_size);
		//printf("%d\n", content[i]);
		if (i == nb-1) 
		fprintf(fd, "\");\n");
		else
		fprintf(fd, "\",\n");
	}
}

void genHeader(FILE *fd, char *filename, int data_size, int addr_size)
{
	fprintf(fd, "library ieee;\n");
	fprintf(fd, "use ieee.std_logic_1164.all;\n");
	fprintf(fd, "use IEEE.numeric_std.ALL;\n\n");
	fprintf(fd, "entity %s is\n", filename);
	fprintf(fd, "port (\n");
	fprintf(fd, "\tclk : in std_logic;\n");
	fprintf(fd, "\taddr_a : in std_logic_vector(%d downto 0);\n", addr_size-1);
	fprintf(fd, "\taddr_b : in std_logic_vector(%d downto 0);\n", addr_size-1);
	fprintf(fd, "\tdata_a : out std_logic_vector(%d downto 0);\n", data_size-1);
	fprintf(fd, "\tdata_b : out std_logic_vector(%d downto 0));\n", data_size-1);
	fprintf(fd, "end entity %s;\n\n", filename);
	fprintf(fd, "architecture behavioral of %s is\n\n", filename);
	fprintf(fd, "\tsignal i: integer range 0 to 2**%d-1 :=0;\n", addr_size);
	fprintf(fd, "\ttype mem is array ( 0 to 2**%d-1) of \n", addr_size);
	fprintf(fd, "\t\t\tstd_logic_vector(%d downto 0);\n", data_size-1);
	fprintf(fd, "\n");
	fprintf(fd, "\tconstant my_Rom : mem := (\n");
}

void genFooter(FILE *fd)
{
	fprintf(fd, "begin\n\n");
	fprintf(fd, "\tprocess(clk)\n");
	fprintf(fd, "\tbegin\n");
	fprintf(fd, "\t\tif rising_edge(clk) then\n");
	fprintf(fd, "\t\t\tdata_a<=my_rom(to_integer(unsigned(addr_a)));\n");
	fprintf(fd, "\t\tend if;\n");
	fprintf(fd, "\tend process;\n");
	fprintf(fd, "\tprocess(clk)\n");
	fprintf(fd, "\tbegin\n");
	fprintf(fd, "\t\tif rising_edge(clk) then\n");
	fprintf(fd, "\t\t\tdata_b<=my_rom(to_integer(unsigned(addr_b)));\n");
	fprintf(fd, "\t\tend if;\n");
	fprintf(fd, "\tend process;\n");
	fprintf(fd, "end architecture behavioral;");
}
void createContent(short *tab, long nb, int DATA_SIZE)
{
	double step = 2*M_PI/nb;
	double i;
	int ii;
	double cos_v;
	FILE *fd = fopen("toto.dat", "w+");
	for (ii=0, i=0.0f; ii < nb; ii++,i+=step)
	{
		cos_v = cos(i);	
		tab[ii] = (short)(cos_v * (pow(2,DATA_SIZE-1)-1));
		fprintf(fd, "%d %lf\n", tab[ii], cos_v);
		//if (ii<10)
		//printf("%d\n", tab[ii]);
	}
	fclose(fd);

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
