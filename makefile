all: matrix

squares: matrix.cu
	nvcc matrix.cu -o matrix.x

clean:
	rm -f matrix.x results