clc
clear
close all

load("../dirs.mat")
dirs.scenarios = dirs.home + "Scenarios/";

Ftexts = ["F1e4/","F1e5/"];

pathInput = dirs.results + Ftexts;

alphas = NaN(13,length(pathInput));

for idxOuter = 1:length(pathInput)

  allInputFiles = dir(pathInput(idxOuter) + "*");

  nFiles = length(allInputFiles) - 2;



  for idxInner = 1:nFiles
    l = load(pathInput(idxOuter) + allInputFiles(idxInner+2).name);
    alphas(idxInner,idxOuter) = l.pFitted.alpha;

  end

end

boxplot(alphas,'Labels',"F0 = " + ["1e4","1e5"])
ylabel("alpha")

% Save the plot into the clipboard
hgexport(gcf,'-clipboard')