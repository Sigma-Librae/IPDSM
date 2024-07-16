function result = abs2norm(input,T)
arguments
  input  table
  T      table
end

%Get the number of parameters
nPar = width(input);

%Create an empty array for the results
result = NaN(size(input));

for i = 1:nPar
  %Get the name of the parameter that will be transformed
  varName = input.Properties.VariableNames{i};

  %Get the pd that corresponds to the parameter name
  pd = T{varName,'dist'};

  %Get the transformation that corresponds to the parameter name
  transObject = T{varName,'trans'};

  %Transform the value based on the parameter distribution and the
  %transformation
  result(:,i) =  pd.cdf(transObject.toNorm(input{:,i}));
end

%Put the result in a table and label the table
result = array2table(result);
result.Properties.VariableNames = input.Properties.VariableNames;