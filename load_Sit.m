function [resultData,resultName, titleNames] = load_Sit(idx)

% If idx does not exist, create it as a vector that covers all Datasets
if ~exist("idx","var")
  idx = 1:3;
end

resultData = ["data_SDZ_1_sit", "data_SDZ_2_sit", "data_SDZ_3_sit"];
resultData = resultData(idx);

resultName = ["SDZ_1_sit", "SDZ_2_sit", "SDZ_3_sit"];
resultName = resultName(idx);

titleNames = ["Sulfadiazine 1", "Sulfadiazine 2", "Sulfadiazine 3"];
titleNames = titleNames(idx);
end