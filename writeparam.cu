// ------------------------------------------------------------------
// Spatial Binary Convolution
// Adrian Bulat,2017
// ------------------------------------------------------------------

#include "THC.h"
#include "common.h"
#include "THCNumerics.cuh"
#include "THCDeviceTensor.cuh"

#include <iostream>
#include <fstream>

// Based on the torch SpatialConvolutionMM_updateOutput
extern "C"
void appenIntParam(
           THCState *state,
//           string fileName,
		   THCudaIntTensor *weight) 
{
/*
    THCUNN_assertSameGPU(state, 2, fileName, weight); 

    int weight_size = 1;
    for(int i = 0; i < weight-> nDimension; i ++)
    {
        weight_size *= weight->size[i];
    }

    weight_data = (unsigned int*)THCudaIntTensor_data(state, weight);

    FILE *bp = fopen(fileName, "ab");

    fwrite(weight_data, sizeof(unsigned int)*weight_size, 1, bp);
*/
}

extern "C"
void appenFloatParam(
           THCState *state,
//           string fileName,
		   THCudaTensor *weight) 
{
/*
    THCUNN_assertSameGPU(state, 2, fileName, weight); 

    int weight_size = 1;
    for(int i = 0; i < weight-> nDimension; i ++)
    {
        weight_size *= weight->size[i];
    }

    weight_data = (float*)THCudaTensor_data(state, weight);

    FILE *bp = fopen(fileName, "ab");

    fwrite(weight_data, sizeof(float)*weight_size, 1, bp);
*/
}
