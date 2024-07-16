function result = initDist(ndomains,factor,meanVal)
arguments
  ndomains  (1,1) {mustBeNumeric} %Number of values created
  factor    (1,1) {mustBeNumeric} %Factor between values
  meanVal   (1,1) {mustBeNumeric} %Mean value of the created values
end
%Function to create an array of values that have a fixed mean value (total)
%and differ by a given factor

%Initialize the arrays for the sparse matrix
u = [];
v = [];
w = [];

%Initialize the first line of the system of linear equations
u = [u;ones(ndomains,1)];
v = [v;(1:ndomains)'];
w = [w;ones(ndomains,1)/(ndomains)];

for i = 2:ndomains
  u = [u;i;i]; %#ok<*AGROW> 
  v = [v;i-1;i];
  w = [w;1;-factor];
end

r = [meanVal;zeros(ndomains-1,1)];

B = sparse(u,v,w);
warning('off','MATLAB:singularMatrix')
result = B\r;

end