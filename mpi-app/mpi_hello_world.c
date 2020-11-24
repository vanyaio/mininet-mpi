#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFF_SIZE 1024
#define MSG_NUM 3

void write_exec_time(double exec_time)
{
	FILE *fp;
	fp = fopen("/data/exec_time", "w");
	fprintf(fp, "%f\n", exec_time);
	fclose(fp);
}

int main(int argc,char **argv)
{
	double exec_time = 0.0;
	int world_rank;
	char *buff = malloc(BUFF_SIZE), msg[] = "Hello";

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);


	if (world_rank == 0)
		memcpy(buff, msg, sizeof(msg));

	MPI_Barrier(MPI_COMM_WORLD);
	exec_time -= MPI_Wtime();
	for (int i = 0; i < MSG_NUM; i++)
		MPI_Bcast(buff, BUFF_SIZE, MPI_CHAR, 0, MPI_COMM_WORLD);
	MPI_Barrier(MPI_COMM_WORLD);
	exec_time += MPI_Wtime();

	if (world_rank == 0)
		write_exec_time(exec_time);

	if (world_rank != 0)
		printf("Process %d received msg '%s' from process 0\n",
				world_rank, buff);

	MPI_Finalize();
}
