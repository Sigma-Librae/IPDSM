function [filenames,fullFiles] = my_dir(path)
% Converts the struct array from dir to a string array, only containing the
% filenames in the given directory
arguments
  path (1,1) string
end

fullFiles = dir(path);

% Delete the "." and ".."
fullFiles = fullFiles(3:end);

% Create an empty array with strings
filenames = strings(length(fullFiles),1);

% Loop over the structs to extract the strings
for idx = 1:length(fullFiles)
  filenames(idx) = fullFiles(idx).name;
end

end