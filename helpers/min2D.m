function [minVal,minIdx] = min2D(matrix)
arguments
  matrix (:,:) {mustBeNumeric}
end
% Determines the minimum of a 2-dimensional array. The index of them
% minimum consists of two values


[minValDim1,minIdxDim1] = min(matrix,[],1);
[minVal,minIdxDim2] = min(minValDim1);

minIdx = [minIdxDim1(minIdxDim2),minIdxDim2];