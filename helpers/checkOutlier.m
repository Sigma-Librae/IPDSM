function [row,col] = checkOutlier(input,devNum)
% CURRENTLY NOT IN USE

%This function is currently not in use, because there is already a MATLAB
%function for this. I keep it in case I still need it.
arguments
  input {mustBeNumeric}
  devNum (1,1) {mustBeNumeric} = 2;
end

dev = std(input);
range = devNum*dev;
meanValue = mean(input);
upperLimit = ((meanValue + range)'*ones(1,size(input,1)))';
lowerLimit = ((meanValue - range)'*ones(1,size(input,1)))';
logical = input>=upperLimit | input<=lowerLimit;
[row,col] = find(logical);
