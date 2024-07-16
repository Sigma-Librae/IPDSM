function my_writetable(T,filename)
%Function to create a table that also contains Rownames in the first
%column an shifts all other columns accordingly
arguments
  T table %The table that should be written in a file
  filename string %name of the resulting file
end

% If any rownames exist
if ~isempty(T.Properties.RowNames)

  %Get the rownames and put them in a table
  T_new = table(T.Properties.RowNames);
  T_new.Properties.VariableNames = {'Name'};

  % Merge the two tables
  T_new = [T_new,T];
else
  T_new = T;
end

writetable(T_new,filename)