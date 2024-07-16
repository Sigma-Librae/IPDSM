function [r,dr,A] = detR(n,r1)
%Function to split a sphere into n shales with the same volume, the result
%r is a vector describing the outer radius of the respective shales
arguments
  n (1,1) {mustBeNumeric} %Number of shales
  r1 (1,1) {mustBeNumeric} %radius of the whole sphere (equal to the radius of the outermost shell)
end

%Determine the total volume of the sphere
Vtot = 4/3*pi*r1^3;

%Create an anonymus function that already contains all parameters for radii
%except for r
fun = @(r)radii(n,r1,Vtot,r);

%solve the anonymus function so the radii of all shells are determined in a
%way that all shales have the same volume
fsolveOpt = optimoptions('fsolve','Display','none','FunctionTolerance',1e-15); %Create options for fsolve
[r,val] = fsolve(fun,ones(n-1,1)*0.5*1e-6,fsolveOpt); %#ok<*ASGLU> 

%Append the radius of the outermost shell to the determined inner radii
r = [r1;r];

%Create an empty array for the "centers" of the shales and the distance
%between them
centers = NaN(n,1);
dr = NaN(n-1,1);

%Loop over dr and determine its values
for i = 1:length(centers)-1
  centers(i) = r(i+1) + 0.5*(r(i)-r(i+1));
end
centers(end) = r(end)/2;

for i = 1:length(dr)
  dr(i) = centers(i) - centers(i+1);
end

%Determine the surface area of all shales
A = 4*pi*r.^2;


function result = radii(n,r1,V,r)
%Function to minimize the residuals so that all determined radii
% lead to shells with the same volume

%Create an empty array for the results
result = NaN(n-1,1);

%Create the first equation separately, as it depends on r1
result(1) = r1^3 - 2*r(1)^3 + r(2)^3;

%Create all consecutive equations except the last one
for j = 2:n-2
  result(j) = r(j-1)^3 - 2*r(j)^3 + r(j+1)^3;
end

%Create the last equation, this differs since it does not describe a
%shale but the innermost sphere
result(end) = 4/3*pi*r(end)^3-V/n;

%Multiply the result of the minimzation problem with a very high number
%to compensate the very low order of magnitude
result = result*1e15;
end
  
end