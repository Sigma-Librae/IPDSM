function result = finishBoot(optMaster,P,p)
% Function to calculate the confidence intervalls as a result of
% bootstrapping and bring them into a single result table
arguments
  optMaster struct  %option structure belonging to the model
  P table           %Table that describes the parameters
  p table           % Table with all parameter values that were determined by bootstrapping
end

%Get the names of all parameters that are fitted
namesf = P.Properties.RowNames(P.fitting);

%Create an empty table t for the results
result = array2table(NaN(length(namesf),3));

%create the column names for t
colNames = {'mean',...
  sprintf('%0.1f%%',optMaster.boot.bound/2*100),...
  sprintf('%0.1f%%',(1-optMaster.boot.bound/2)*100)};

%Add the row and column names to the table
result.Properties.VariableNames = colNames;
result.Properties.RowNames = namesf;

%Determine the bootstrapping confidence intervalls and add them to the table
%t
for i = 1:height(result)
  %Mean value
  result(namesf{i},colNames{1}) = array2table(mean(p.(namesf{i})));

  %Lower confidence bound
  result(namesf{i},colNames{2}) = array2table(prctile(p.(namesf{i}),optMaster.boot.bound/2*100));

  %Upper confidence bound
  result(namesf{i},colNames{3}) = array2table(prctile(p.(namesf{i}),(1-optMaster.boot.bound/2)*100));
end
