function result = norm2abs(inputNorm,P)
% Function to transform a normalized parameter value (between 0 and 1) to
% the absolute parameter that is used for the model, using the probability
% distribution (pd) and the transformation
arguments
  inputNorm  table      %table containing the normalized parameter values
  P  table              %table containing the transformation and pd
end

%Get the number of parameters
nPar = width(inputNorm);

%create an empty array for the result
result = NaN(size(inputNorm));

for i = 1:nPar
  %Get the name of the parameter that will be transformed
  varName = inputNorm.Properties.VariableNames{i};

  %Get the pd that corresponds to the parameter name
  pd = P{varName,'dist'};

  %Get the transformation that corresponds to the parameter name
  transObject = P{varName,'trans'};

  %Transform the value based on the parameter distribution and the
  %transformation
  result(:,i) = transObject.toAbs(pd.icdf(inputNorm{:,i}));
end

%Put it in a table and label the table
result = array2table(result);
result.Properties.VariableNames = inputNorm.Properties.VariableNames;              