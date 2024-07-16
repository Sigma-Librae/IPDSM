function [W,lambda,a] = eigenActSS(df,dirs)
% active subspace decomposition of a gradient matrix df, which has the
% size nRealizations x nParameters; The gradient describes the gradient of 
% a scalar target quantity with respect to all input parameters
% respectively. Every realization describes the gradient for a different
% set of parameter values
% The first output is the matrix of eigenvectors, the second output 
% argument is the vector of eigenvalues, the third output are the activity scores

arguments
  df
  dirs
end

%Save the workspace into the log-folder to make debugging easier in case
%something crashes
save(dirs.log + "controlEigen.mat");

nPar = width(df);

% determine number of realizations
M           = size(df,1);

%Create array from table
df          = df{:,:};

% construct the matrix
C           = 1/M * (df' * df);

% eigen decomposition
[W,lambda]  = eig(C,'vector');

% make sure all eigenvalues are positive (taken directly from Paul Constantines codes)
lambda      = abs(lambda);

% sort everything according to eigenvalues
[lambda,B]  = sort(lambda,'descend');
W           = W(:,B);

% make sure that the sign of the first entries in the vectors is
% positive, which is also a convention of Paul Constantine
s           = sign(W(1,:));
s(s==0)     = 1;
W           = W.*s;

%Create an empty array for a
a = zeros(nPar,1);

for i = 1:nPar
  for j= 1:nPar
    a(i) = a(i)+lambda(j)*W(i,j)^2;
  end
end

%Normalize a between zero and one
a = abs(a)./sqrt(sum(a.^2));

end