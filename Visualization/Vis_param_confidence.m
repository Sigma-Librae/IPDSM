clc
clear
close all

% Organises confidence intervalls of multiple datasets into one table

idxFiles = [2,4,5,7:2:13];
resultPath = "C:\Users\Matthias\Desktop\Program\Git\Programs_PhD\Results\Manuscript\";
dirs.home = "C:\Users\Matthias\Desktop\Program\Git\Programs_PhD\";
addpath(dirs.home)
[a,b,c,d] = load_Dalk(idxFiles);
% fileNames = ["special_cases\24_0412_MDomWNER_BEZ_ns_Dalk_boot",...
%   "MDomWNER_BEZ_s_Dalk_boot",...
%   "special_cases\24_0413_MDomWNER_CAR_ns_Dalk_boot",...
%   "MDomWNER_CAR_s_Dalk_boot",...
%   "special_cases\23_121_MDomWNER_CIP_ns_Dalk",...
%   "special_cases\24_0413_MDomWNER_DIC_ns_Dalk_boot",...
%   "MDomWNER_DIC_s_Dalk_boot",...
%   "special_cases\24_0414_MDomWNER_NAP_ns_Dalk_boot",...
%   "MDomWNER_NAP_s_Dalk_boot",...
%   "special_cases\24_0414_MDomWNER_SMX_ns_Dalk_boot",...
%   "MDomWNER_SMX_s_Dalk_boot",...
%   "special_cases\24_0415_MDomWNER_TRI_ns_dalk_boot",...
%   "special_cases\24_0322_MDomWNER_TRI_s_dalk_boot"];

fileNames = ["special_cases\24_0412_MDomWNER_BEZ_ns_Dalk_boot",...
  "special_cases\24_0413_MDomWNER_CAR_ns_Dalk_boot",...
  "special_cases\24_0413_MDomWNER_DIC_ns_Dalk_boot",...
  "special_cases\24_0414_MDomWNER_NAP_ns_Dalk_boot",...
  "special_cases\24_0414_MDomWNER_SMX_ns_Dalk_boot",...
  "special_cases\24_0415_MDomWNER_TRI_ns_dalk_boot"];

% Load the first file to prepare the final table
l = load(resultPath + fileNames(1));

% Get the names of all parameters that are fitted
paramNames = l.P.Properties.RowNames(l.P.fitting);

% Create an empty array for the final table
finalTable = array2table(NaN(length(fileNames), length(paramNames)*3));

% Take a table from the results as a template
bootTable = l.bootTable(:,[2,1,3]);
groupNames = string(bootTable.Properties.VariableNames);


VarNames = paramNames + " " + groupNames;
VarNames = reshape(VarNames',[],1);
finalTable.Properties.VariableNames = VarNames;
RowNames = strings(length(fileNames),1);

for idx = 1:length(fileNames)
  l = load(resultPath + fileNames(idx));
end

for idx = 1:length(fileNames)
  l = load(resultPath + fileNames(idx));
  bootTable = l.bootTable(:,[2,1,3]);
  groupNames = string(bootTable.Properties.VariableNames);
  paramNames = l.P.Properties.RowNames(l.P.fitting);
  counterLoop = 1;
  RowNames(idx) = l.optMaster.data;

  for idxParam = 1:length(paramNames)
    for idxGroup = 1:width(bootTable)
      if idxGroup == 2
        medianBoot = median(l.bootparam.(string(paramNames(idxParam))));
        finalTable{idx,counterLoop} = medianBoot;
      else

        finalTable{idx,counterLoop} = bootTable{idxParam,idxGroup};

      end
      counterLoop = counterLoop + 1;
    end
  end


end
finalTable.Properties.RowNames = RowNames;