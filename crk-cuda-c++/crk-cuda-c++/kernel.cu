
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "cuda_runtime.h"
#include <cuda.h>
#include <time.h>
#include "device_launch_parameters.h"
#include <iostream>
#include <io.h>
#include <stdlib.h>



// includes CUDA
#include <cuda_profiler_api.h>

// includes, project


// d is the number of float in the input alphabet 

#define MOD 1000000007
#define M  3
#define N  13

__global__ void STRING(int *txt_d, int *pat_d, int *f_d, int hp, int ht, int val, int random)
{

	int id = blockIdx.x*blockDim.x + threadIdx.x;


	int j, i;

	if (id <= N - M){


		if (hp == ht){
			int j;

			for (j = 0; j < M; j++){
				if (txt_d[id + j] != pat_d[j])
					break;
			}

			if (j == M)
				f_d[id] = id;
			//found in text
		}
		
	}
}
/* Driver program to test above function */
	int main(int argc, int ** argv)
	{


		int *txt;
		int *pat;

		clock_t start, end;
		float run_time;
		//float txt[], pat[]; // pointers to host memory; (CPU)
		int *txt_d, *pat_d, number; // pointers to device memory; (GPU)
		int i, j, index;
		int  *f_d, *f;
		txt = (int *)malloc(sizeof(int)*N);
		pat = (int *)malloc(sizeof(int)*M);
		f = (int *)malloc(sizeof(int)*(N - M));

		FILE *fp;
		fp = fopen("text.txt", "rt");
		if (fp == NULL)
		{
			printf("cannot open file \ n");
			getchar();
			exit(1);
		}
		int temp4;
		for (i = 0; i < N; i++)
		{
			fscanf(fp, "%d", &temp4);
			txt[i] = temp4;
		}
		fclose(fp);
		//FILE *fp;
		fp = fopen("pat.txt", "rt");
		if (fp == NULL)
		{
			printf("cannot open file \ n");
			getchar();
			exit(1);
		}
		int temp5;
		for (i = 0; i < M; i++)

		{
			fscanf(fp, "%d", &temp5);
			pat[i] = temp5;
		}
		fclose(fp);
		
	

		// allocate arrays on device
		cudaMalloc((void **)&txt_d, N*sizeof(int));
		cudaMalloc((void **)&pat_d, M*sizeof(int));
		cudaMalloc((void **)&f_d, (N - M)*sizeof(int));

		//dim3 dimBlock(blocksize, blocksize);
		//dim3 dimGrid(ceil(float(n) / float(dimBlock.x)), ceil(float(n) / float(dimBlock.y)));
		//////// copy and run the code on the device


		int hp = 0, ht = 0, val = 1;

		//srand(time(0));
		int random = rand() % (MOD - 1) + 1; // generating random value x

		for (int i = 0; i < M; i++){
			hp = (random*hp) % MOD; // calculating hash of pattern
			ht = (random*ht) % MOD; // calculating hash of first sub-string
			// of text
			hp += pat[i];
			ht += txt[i];

			hp %= MOD;
			ht %= MOD;
			val = (val*random) % MOD;
		}




		cudaMemcpy(txt_d, txt, N*sizeof(int), cudaMemcpyHostToDevice);

		cudaMemcpy(pat_d, pat, M*sizeof(int), cudaMemcpyHostToDevice);

		/*dim3 dimGrid((N-M,1));
		dim3 dimBlock(M,1);*/
		start = clock();


		STRING << <1,10 >> >(txt_d, pat_d, f_d, hp, ht, val, random);
		cudaThreadSynchronize();
		end = clock();

		cudaMemcpy(f, f_d, (N - M)*sizeof(int), cudaMemcpyDeviceToHost);

		for (int j = 0; j < N; j++){
			printf("txt[%d]=%d \n", j, txt[j]);
		}
		for (int j = 0; j < M; j++){
			printf("pat[%d]=%d \n", j, pat[j]);
		}
		for (int j = 0; j < N - M; j++){
			printf("Pattern found at index f[%d]=%d \n", j, f[j]);
		}
		//printf("%s \n", txt);
		run_time = (float(end - start)) / CLOCKS_PER_SEC;
		printf("\n\ntime=%f", run_time);
		free(txt);
		free(pat);
		free(f);
		cudaFree(txt_d);
		cudaFree(pat_d);
		cudaFree(f_d);

		getchar();
		return 0;
	}
