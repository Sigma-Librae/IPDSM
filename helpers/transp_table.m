function Tnew = transp_table(T)
arguments
  T (:,:) table % input table that will be transposed
end
%Function to transpose a table

%Get the rownames and column names of the table
Rownames = T.Properties.RowNames;
ColNames = T.Properties.VariableNames;

%Create alternative rownames if there were no rownames before
if isempty(Rownames)
  Rownames = "string" + (1:height(T))';
end

%Get the content of the table as cell array
content = table2cell(T);

% Transpose the cell array containing the content of the table
Tnew = cell2table(content');

%Use the former column names as rownames and vice versa
Tnew.Properties.RowNames = ColNames;
Tnew.Properties.VariableNames = Rownames';

end
