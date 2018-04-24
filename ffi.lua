local ffi = require 'ffi'

local libpath = package.searchpath('libwriteparam',package.cpath)
if not libpath then return end

require 'cunn'

ffi.cdef[[
        void appenIntParam(
                THCState *state,

                THCudaIntTensor *weight);

        void appendFloatParam(
                THCState *state, 

                THCudaTensor *weight);

]]

return ffi.load(libpath)
