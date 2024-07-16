function [resultData,resultName, titleNames] = load_Foe(idx)

% If idx does not exist, create it as a vector that covers all Datasets
if ~exist("idx","var")
  idx = 1:3;
end

resultData = ["data_SDZ_1_foe", "data_SDZ_2_foe", "data_SDZ_3_foe"];
resultData = resultData(idx);

resultName = ["SDZ_1_foe", "SDZ_2_foe", "SDZ_3_foe"];
resultName = resultName(idx);

titleNames = ["Sulfadiazine Luvisol Fresh",...
              "Sulfadiazine Cambisol Fresh",...
              "Sulfadiazine Cambisol Aged"];
titleNames = titleNames(idx);
