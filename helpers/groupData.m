function groups = groupData(data,t)

arguments
  data (:,1) {mustBeNumeric}
  t (:,1) {mustBeNumeric}
end

% Intended for datasets with multiple datapoints for one timepoint
% The function groups the data, based on the time vector

% Get all unique timepoints
uniqueT = unique(t);

% Create as many groups as there are unique timepoints
groups = cell(length(uniqueT),1);

for idxLoop = 1:length(uniqueT)
  idxLogical = t==uniqueT(idxLoop);
  groups{idxLoop} = data(idxLogical);
end