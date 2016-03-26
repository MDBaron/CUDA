/*
 * 
 * Matthew Baron
 * Homework #4
 * 3/16/2015
 * CSCI 4150
 * CUDA Version #1
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <math.h>
#include <ctime>
#include <iomanip>
#include <cuda.h>
#define BLOCK_SIZE 16

using namespace std;

//Row-Major Matrix struct 
typedef struct {
	int width;
	int height;
	int* elements;
} Matrix;

__global__ void MatrixMultiplyKernel(Matrix A, Matrix B, Matrix C);

 
void MatrixMultiply(Matrix matA, Matrix matB, Matrix matC){

  Matrix d_A, d_B, d_C;

  int value = 16384;//Multiple of 16
  d_A.height = value;
  d_A.width = value;
  
  std::cout << "Matrix d_A Values Set" << std::endl;  
  
  d_B.height = value;
  d_B.width = value;
  
  std::cout << "Matrix d_B Values Set" << std::endl;

  d_C.height = value;
  d_C.width = value;
  
  std::cout << "Matrix d_C Values Set" << std::endl;

  /* Allocate and copy memory to DEVICE */
  size_t size = value * value * sizeof(int);
  cudaMalloc(&d_A.elements, size);
  cudaMemcpy(d_A.elements, matA.elements, size, cudaMemcpyHostToDevice);
  cudaMalloc(&d_B.elements, size);
  cudaMemcpy(d_B.elements, matB.elements, size, cudaMemcpyHostToDevice);
  cudaMalloc(&d_C.elements, size);

  std::cout << "Memory Allocation on DEVICE Complete" << std::endl;
  
  /* Get dem thread blocks allocated */
  dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
  dim3 dimGrid((value + dimBlock.x -1) / dimBlock.x, (value + dimBlock.y - 1) / dimBlock.y);

  std::cout << "Begin Call to Kernel for Matrix Multiplication.... " << std::endl;
  MatrixMultiplyKernel<<<dimGrid, dimBlock>>>(d_A, d_B, d_C);
  cudaThreadSynchronize();
  
  std::cout << "Matrix Multiplication Complete" << std::endl;
  std::cout << "Copying Device Matrix d_C back to Host C..." << std::endl;  

   /* Copy results from DEVICE to HOST */
  cudaMemcpy(matC.elements, d_C.elements, size, cudaMemcpyDeviceToHost);
  
  std::cout << "Matrix Copy Complete" << std::endl;

  /*  Deallocate Memory on DEVICE */
  cudaFree(d_A.elements);
  cudaFree(d_B.elements);
  
  std::cout << "Absolving Memory Allocations..." << std::endl;

}//MatrixMultiplyKernel 
 
__global__ void MatrixMultiplyKernel(Matrix A, Matrix B, Matrix C){
	int sumValue = 0;
	int col = blockIdx.x * blockDim.x + threadIdx.x;//Thread association for columns
	int row = blockIdx.y * blockDim.y + threadIdx.y;//Thread association for rows
	if(col > B.width || row > A.height){
		return;
	}//Bounds Checking
	for(int i = 0; i < A.width; i++){
		sumValue += A.elements[(row * A.width) + i] * B.elements[(i * B.width) + col];
	}
	C.elements[(row * C.width) + col] = sumValue;//Store summation in new matrix
}//global Kernel


int main(void){

  int value = 16384;//Multiple of 16
  
  Matrix matA, matB, matC;
  matA.height = value;
  matA.width = value;
  matA.elements = (int*)malloc(matA.width * matA.height * sizeof(int)); //String of elements that represent Row-Major Matrix
  
  std::cout << "Matrix A Allocations Complete" << std::endl;  

  matB.height = value;
  matB.width = value;
  matB.elements = (int*)malloc(matB.width * matB.height * sizeof(int)); //String of elements that represent Row-Major Matrix
  
  std::cout << "Matrix B Allocations Complete" << std::endl;  

  matC.height = value;
  matC.width = value;
  matC.elements = (int*)malloc(matC.width * matC.height * sizeof(int)); //String of elements that represent Row-Major Matrix
  
  std::cout << "Matrix C Allocations Complete" << std::endl;
  std::cout << "Current Value: " << value << std::endl;
   
  //Fill matrices with random data
  srand(time(NULL));
  
  for(int p = 0; p < value; ++p){
    for(int q = 0; q < value; ++q){
      matA.elements[(p * value) + q] = rand();
      matB.elements[(p * value) + q] = rand();
      //std::cout << p << " " << q << std::endl;
    }//Q
  }//P

  std::cout << "Random Data Fill for Matrices Complete " << std::endl;

  //Declare Time Events
  cudaEvent_t start, stop; 
  float time; 
  
  //Create CUDA Time Events
  cudaEventCreate(&start); 
  cudaEventCreate(&stop); 
  
  std::cout << "Begin Matrix Multiply:.... " << std::endl;

  //Begin Recording
  cudaEventRecord( start, 0 );   

  //Perform Kernel Operations
  MatrixMultiply(matA, matB, matC);

  //Halt Time Event Recording
  cudaEventRecord( stop, 0 ); 
  cudaEventSynchronize( stop ); 
  
  std::cout << "Job Complete: " << std::endl;  

  //Calculate and Store Time in CUDA Elapsed Time
  cudaEventElapsedTime( &time, start, stop ); 
  
  //Free Event Memory
  cudaEventDestroy( start ); 
  cudaEventDestroy( stop );

  printf("Elapsed Time : %.*e ms/n"  , time);
  std::cout << std::endl;

  /* 

  C Program Average time elapsed is ~30secs on 1000 x 1000 matrix
  CUDA Program is returning 0.0000000000000000000e+00 ms on maximum decimal (Unknown Reasons)
  * Execution for 10,000+ is easily less than 2secs for CUDA which would mean substantial performance increase  

*/

  return 0;

}//main
