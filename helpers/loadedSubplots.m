function loadedSubplots(filenames,x,y)
% Function to load figures and put them into subplots

% This was created without a deeper understanding of matlabs plotting
% mechanisms and is quite problematic but works for now. However, 
% it produces a lot of unnecessary plots

% Initialize arrays
files = cell(length(filenames),1);
axes = files;
s = files;
figs = files;

xlabelStr = strings(size(files));
ylabelStr = xlabelStr;

% Loop over all files specified in filenames and get the information from
% it
for idx = 1:length(filenames)
  
  % Get the .fig-file
  files{idx} = openfig(filenames(idx));

  % Get labels and titles from the current .fig file and copy them
  ax = get(files{idx}, 'CurrentAxes');
  
  % Get the axes labels
  xlabelStr(idx) = get(get(ax, 'XLabel'), 'String');
  ylabelStr(idx) = get(get(ax, 'YLabel'), 'String');
  axes{idx} = gca;
end

% Create a figure for the subplots
fig = figure; %#ok<NASGU>
for idx = 1:length(filenames)
  % Create a subplot and name it
  s{idx} = subplot(x,y,idx);

  % Get the figures
  figs{idx} = get(axes{idx},'children');

  % Copy the figures into the subplots and add the labels on the axes
  copyobj(figs{idx},s{idx})
  xlabel(xlabelStr(idx))
  ylabel(ylabelStr(idx))
end

end
