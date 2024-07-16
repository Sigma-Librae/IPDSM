function [maxVal,maxIdx] = max2D(matrix)
arguments
  matrix (:,:) {mustBeNumeric}
end
% Determines the minimum of a 2-dimensional array. The index of them
% minimum consists of two values


[maxValDim1,maxIdxDim1] = max(matrix,[],1);
[maxVal,maxIdxDim2] = max(maxValDim1);

maxIdx = [maxIdxDim1(maxIdxDim2),maxIdxDim2];