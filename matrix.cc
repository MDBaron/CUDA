/*
 * 
 * Matthew Baron
 * Homework #4
 * 3/16/2015
 * CSCI 4150
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <math.h>
#include <vector>
#include <ctime>
#include <iomanip>

using namespace std;


int main(){

  std::vector<std::vector<int> > matrixA;//Matrix A
  std::vector<std::vector<int> > matrixB;//Matrix B
  std::vector<std::vector<int> > matrixC;//Matrix C

  //Summation for matrix multiplication
  int positionSum = 0; //

  clock_t startTime1, endTime1;
  clock_t opTime1;

  double opSecs1;
  int value = 1000;
  
  //set first dimensions to size of value
  matrixA.resize(value);
  matrixB.resize(value);
  matrixC.resize(value);
  
  //set second dimension to size of value
  for(int r = 0; r < value; r++){
    matrixA[r].resize(value);
    matrixB[r].resize(value);
    matrixC[r].resize(value);
  }

  //Fill matrices with random data
  srand(time(NULL));
  for(int p = 0; p < value; p++){
    for(int q = 0; q < value; q++){
      matrixA[p][q] = rand();
      matrixB[p][q] = rand();
    }//Q
  }//P



  //C = A*B
  startTime1 = clock();
  for(int i = 0; i < value; i++){
    for(int j = 0; j < value; j++){
		for(int k = 0; k < value; k++){
			matrixC[i][j] = matrixC[i][j] + (matrixA[i][k] * matrixB[k][j]);
	  }//K
    }//J
  }//I
  endTime1 = clock();
  opTime1 = endTime1 - startTime1;
  opSecs1 = opTime1 / (double) CLOCKS_PER_SEC;
  std::cout << "Time elapsed in seconds for operation 1:      " << opSecs1 << std::endl;

  return 0;

}//main
