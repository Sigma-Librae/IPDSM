function result = countElements(x)
%Function to count the number of integers of an array. The result will
%contain the number of ones as the first element, the number of twos as the
%second element and so on. This function is intended to be used by the
%bootstrapping function

arguments
  x (1,:) {mustBeNumeric}
end

%Create an empty array for the result
result = NaN(size(x));

%Count the number of integers that correspond to i
for idx = 1:length(x)
  result(idx) = sum(x==idx);
end