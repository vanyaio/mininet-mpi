#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFF_SIZE 1024

int main(int argc,char **argv)
{
	MPI_Init(&argc, &argv);
	int world_rank;
	MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
	int world_size;
	MPI_Comm_size(MPI_COMM_WORLD, &world_size);

	char *buff = malloc(BUFF_SIZE), msg[] = "Hello";

	if (world_rank == 0)
		memcpy(buff, msg, sizeof(msg));

	MPI_Bcast(buff, BUFF_SIZE, MPI_CHAR, 0, MPI_COMM_WORLD);

	if (world_rank != 0)
		printf("Process %d received msg '%s' from process 0\n",
				world_rank, buff);

	MPI_Finalize();
}
