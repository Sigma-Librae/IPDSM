clc
clear
close all

%Define all directories
load(pwd + "/../dirs.mat","dirs")

addpath(dirs.home)

% Define the datasets that are used
[a,b,c] = load_Dalk([3,4]);

% a = [a1, a2, a3];
% b = [b1, b2, b3];
% c = [c1, c2, c3];

plotPath = "C:\Users\Matthias\OneDrive\Desktop\Arbeit\Writing\support_files\Plots\";

resultsFolder = ["Results\Manuscript/",... 1
                 "Results\Manuscript/",... 2
                 ];


resultPath = dirs.home + resultsFolder;

resultNames = [
  "MDomWNER_CAR_ns_Dalk",...
  "MDomWNER_CAR_s_dalk_boot"
  ] + ".mat";

source = ["Dalk",...
  "Dalk"];

saveFlag = 1;

titles = ["Non-sterile", "Sterile"];

%Create a specific directory name for this model
%savePath = "C:\Users\Matthias\OneDrive\Desktop\Arbeit\Writing\support_files\Plots";

%Create the directory if it doesn't exist yet
% if ~exist(savePath,"dir")
%   mkdir(savePath)
% end

%saveNames = modelName + "_" + DIS  + "_" + b;

legendTexts.Dalk = ["EAS","","RES","","NER","TM"];

% Number of mass fractions in the respective source
nMassFractions.Dalk = 4;
nMassFractions.Foe = 5;

f = figure;
%f.Position = [522   245   833   590];
for idx = 1:length(a)
  idxLogicalPlotting = true(nMassFractions.(source(idx)),1);
  if any(strsplit(resultNames(idx),'_')=="s")
    idxLogicalPlotting(end) = false;
  end
  subplot(1,2,idx)
  vis_time(resultPath(idx),resultNames(idx), "","", titles(idx), false, dirs, false, false,idxLogicalPlotting);
  xlegendTexts = legendTexts.(source(idx));
  legend(xlegendTexts,location="best")

end
exportgraphics(f,plotPath + "multiplePlotsCar.jpg","Resolution",1200)

%titles = strings(size(a));