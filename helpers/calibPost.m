function pFitted = calibPost(solNorm,P)
%Post-processing for the calibration. It calculates the absolute values of
%the solution and brings it in the required form of a table

%Put the initial values in a table and label the table
pFitted = array2table(reshape(P.InitValue,1,[]));
pFitted.Properties.VariableNames = P.Properties.RowNames';

% Get only the names of parameters that are fitted
namesParamf = P.Properties.RowNames(P.fitting);

%Switch the dimensions put it in a table and label the table
solNorm = array2table(reshape(solNorm,1,[]));
solNorm.Properties.VariableNames = namesParamf;
sol = norm2abs(solNorm,P);

%Overwrite the fitted parameters in the original table
for i = 1:width(sol)
  pFitted(1,namesParamf{i}) = sol(1,namesParamf{i});
end