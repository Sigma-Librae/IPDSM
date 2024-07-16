function [plotName, actTableName, paramTableName] = ...
  vis_time(resultPath, resultName,savePath,saveName,titleName,saveFlag,dirs, flagTextbox, flagLegend,logicalIndexPlotting)
% Core function for the visualization of the model results

arguments
  resultPath (1,1) string
  resultName (1,1) string
  savePath (1,1) string
  saveName (1,1) string
  titleName  string
  saveFlag (1,1) logical
  dirs (1,1) struct
  flagTextbox (1,1) logical = true
  flagLegend (1,1) logical = true
  logicalIndexPlotting = NaN
end

% Set the save flag to false is either savePath or saveName is "empty"
if strlength(savePath) == 0 || strlength(saveName) == 0
  saveFlag = false;
end

load(resultPath + resultName, '-regexp', '^(?!dirs)\w') %#ok<LOAD>

if ~isfield(modelMeta,"nS")
  modelMeta.nS = S{"RES","domains"} + S{"NER_shale","domains"} + S{"EAS","domains"} - 1;
end
%load(sprintf('%s\\%s\\MDom_Result_1_C.mat',dirs.home,'Results'))


addpath(dirs.home)
addpath(dirs.helpers)

% Overwrite the internal names for the state variables to comply with
% naming conventions
stateVarNamesString = string(stateVarNames);
stateVarNamesString(stateVarNamesString=="NER") = "NER_deg";
stateVarNamesString(stateVarNamesString=="DIS") = "TM";
stateVarNamesString(stateVarNamesString=="NER_shale") = "NER";
stateVarNamesString(stateVarNamesString=="DIS-OH") = "OH-SDZ";
stateVarNamesString(stateVarNamesString=="DIS-AC") = "Ac-SDZ";
%plotDist(P)
%exportgraphics(gcf,dirs.graphs + "paramDist.png")

legendEntries = [];

%Plot the model results
colors = get(gca,'colororder');
symbols = 'x*o+^v';

% Counter for all datasets that were plotted, this is necessary to ensure
% that the right data symbol is chosen
counterData = 1;

loopIdx = 1:width(Fitted)-1;
if all(~isnan(logicalIndexPlotting)) && length(logicalIndexPlotting) == length(loopIdx)
  loopIdx = loopIdx(logicalIndexPlotting);
end
if contains(resultName,"sit")
  colors = [colors(6,:); colors(1:4,:)];
  symbols = [symbols(6), symbols(1:4)];
end

%figure
%Loop over the state variables
for idx = loopIdx %#ok<*USENS>

  %Plot the simulated values
  if S.meas(idx)
    LineStylePlotting = '-';
  else
    LineStylePlotting = '--';
  end

  plot(t,Fitted(:,idx),'Color',colors(idx,:),LineStyle=LineStylePlotting,LineWidth=1.5)
  hold on

  %Add the name of the State variable to the legend entries
  legendEntries = [legendEntries;stateVarNamesString(idx)];

  %If measurments were taken for the current state variable
  if S.meas(idx)

    %Plot the measured data
    s = scatter(loaded.tObs{idx},loaded.data{idx},100,colors(idx,:),'LineWidth',1.5);
    s.Marker = symbols(counterData);
    counterData = counterData + 1;

    %Add a placeholder to the legedn entries
    legendEntries = [legendEntries;""]; %#ok<*AGROW>
  end

end

title(titleName,'FontSize',16)
ylabel('C [\mug/kg]','FontSize',12)
%ylim ([0 250])
xlabel('Time [d]','FontSize',12)
ylim([0 inf])

%Plot a text fore the NRMSE in the plot
if flagTextbox
  textBox = "NRMSE:" + round(errVal.NRMSE,3) + ", MSC:" + round(errVal.MSC,3);
  annotation('textbox', [0.3, 0.65, 0.3, 0.15], 'String', textBox,'FontSize',10)
end
%TextLocation(textBox,'Location','best');

%Show the legend entries and labels and so on
if flagLegend
    legend(legendEntries,'Location','best',fontsize=10)
end

%Export the figure
plotName = savePath + saveName + ".png";
if saveFlag
  exportgraphics(gcf,plotName)

  actTableName = resultPath + saveName + "_local_act.xlsx";
  local_act_score{:,:} = round(local_act_score{:,:},2); %#ok<*NODEF>
  writetable(local_act_score,actTableName,'WriteRowNames',true)

  pFittedf = pFitted(1,P.fitting');
  paramTableName = resultPath + saveName + "_p_fitted.xlsx";
  pFittedf.Properties.VariableNames = string(pFittedf.Properties.VariableNames) + "_______";
  writetable(pFittedf,paramTableName,'WriteRowNames',true)
else
  actTableName = NaN;
  paramTableName = NaN;
end
hold off


end