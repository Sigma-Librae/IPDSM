clc
clear
close all

resultPath = "C:\Users\Matthias\Desktop\Program\Git\Programs_PhD\Results\MDomWNER_NO\";

filenames = resultPath + [...
  "24_0411_MDomWNER_BEZ_s_Dalk";...
  "24_0411_MDomWNER_CAR_s_Dalk";...
  "24_0412_MDomWNER_CIP_ns_Dalk";...
  "24_0411_MDomWNER_DIC_s_Dalk";...
  "24_0411_MDomWNER_NAP_s_Dalk";...
  "24_0411_MDomWNER_SMX_s_Dalk";...
  "24_0411_MDomWNER_TRI_s_dalk"] + ".mat";

l = load(filenames(1));
sizeTableActScore = size(l.activityScore);
allSen = NaN(sizeTableActScore(1),sizeTableActScore(2),length(filenames));
allSen(:,:,1) = l.activityScore{:,:};
for idxFiles = 2:length(filenames)
  l = load(filenames(idxFiles));
  allSen(:,:,idxFiles) = l.activityScore{:,:};
end

meanActScore = round(mean(allSen,3));
meanActScoreTable = l.activityScore;
meanActScoreTable{:,:} = meanActScore;
