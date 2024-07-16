function A = FDMatrix(n)
arguments
  n (1,1) int16
end

%Function to create a sparse matrix to calculate finite differences
%diffusion via a matrix multiplication

u = [];
v = [];
w = [];

%Create the ones below the diagonal
a = 2:n;
b = 1:n-1;
c = ones(1,length(b));

u = [u,a];
v = [v,b];
w = [w,c];

%Create the negative values on the diagonal
a = 1:n;
b = 1:n;
c = ones(1,length(b))*-2;
c([1,end]) = -1;

u = [u,a];
v = [v,b];
w = [w,c];

%Create the values above of the diagonal
a = 1:n-1;
b = 2:n;
c = ones(1,length(b));

u = [u,a];
v = [v,b];
w = [w,c];

%Bring everything together
A = sparse(u,v,w);