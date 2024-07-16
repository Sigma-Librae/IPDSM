function [S,P,modelMeta] = loadParams(optMaster,loaded,dirs)
arguments
  optMaster (1,1) struct
  loaded struct
  dirs struct
end

% Load all options for the chosen model
modelMeta = optMaster.model();

%Read the table that describes the params
Praw = readtable(sprintf('%s%s_Params.csv',dirs.params,modelMeta.table));

if isfield(modelMeta,"loadAddParam")

  %Get the three characters shortform of the sorbate (e.g. BEZ)
  splits = strsplit(optMaster.data,"_");
  nameData =  splits{2};

  % Load the parameter names and distributions
  tInd = readtable(dirs.paramsInd + nameData + ".csv");

  warning('off','MATLAB:table:RowsAddedExistingVars')

  switch optMaster.DIS
    case "TM"
      tInd.Names{tInd.Names=="k"} = 'k_tm';
      tInd{end+1,1} = {'k_ner'};
    case "NO" %No dissipation
      tInd.Names{tInd.Names=="k"} = 'k_tm';
      tInd.InitValue(cellstr(tInd.Names)=="k_tm") = 0;
      tInd.fitting(cellstr(tInd.Names)=="k_tm") = 0;
      tInd.trans(cellstr(tInd.Names)=="k_tm") = {'d'}; 
      tInd.dist(cellstr(tInd.Names)=="k_tm") = {'normal'};
      tInd.shift(cellstr(tInd.Names)=="k_tm") = 0;
      tInd.scaling(cellstr(tInd.Names)=="k_tm") = 1;
      tInd{end+1,1} = {'k_ner'};
      
    case "NER"
      tInd.Names{tInd.Names=="k"} = 'k_ner';
      tInd{end+1,1} = {'k_tm'};
    case "2TM"
      % Replace k with the k_tm_OH
      tInd.Names{tInd.Names=="k"} = 'k_tm_OH';

      % Copy the row with k_tm_OH
      tInd(end+1,:) = tInd(tInd.Names=="k_tm_OH",:);

      %Rename the parameter of the copied row into k_tm_AC
      tInd{end,1} = {'k_tm_AC'};

      tInd{end+1,1} = {'k_tm'};
      tInd{end,"trans"} = {'d'}; tInd{end,"dist"} = {'normal'};
      tInd{end,"shift"} = 0; tInd{end,"scaling"} = 1;

      tInd{end+1,1} = {'k_ner'};  

    case "2TMNER"
      % Replace k with the k_tm_OH
      tInd.Names{tInd.Names=="k"} = 'k_tm_OH';

      % Copy the row with k_tm_OH
      tInd(end+1,:) = tInd(tInd.Names=="k_tm_OH",:);

      %Rename the parameter of the copied row into k_tm_AC
      tInd{end,1} = {'k_tm_AC'};

      % Copy the row with k_tm_OH
      tInd(end+1,:) = tInd(tInd.Names=="k_tm_OH",:);

      %Rename the parameter of the copied row into k_tm_AC
      tInd{end,1} = {'k_ner'};

      tInd{end+1,1} = {'k_tm'};  
    otherwise
      tInd.fitting(tInd.Names=="k") = 0;
      tInd.InitValue(tInd.Names=="k") = 0;
      tInd.Names{tInd.Names=="k"} = 'k_tm';
      tInd{end+1,1} = {'k_ner'};
  end

  tInd{end,"trans"} = {'d'};
  tInd{end,"dist"} = {'normal'};
  tInd{end,"shift"} = 0;
  tInd{end,"scaling"} = 1;


  Praw = [Praw;tInd];
end

%Read the table that describes the state variables
Sraw = readtable(dirs.states + modelMeta.table + "_States.csv");

%Get the names of the state variables
stateNames = Sraw.Names;

%Use the names of state variables as column names
Sraw = Sraw(:,2:end);
Sraw.Properties.RowNames = stateNames;

%Transform the loaded values into the final table
S = Sraw(:,1);
S(:,'dynamic') = array2table(Sraw.dynamic==1);
S(:,'meas') = array2table(Sraw.measured);
S(:,"units") = array2table(string(Sraw.units));

%Get the number of domains for each state variable, if this is not
%specified, set the number off all domains to one
if any(string(Sraw.Properties.VariableNames) == "domains")
  S(:,'domains') = Sraw(:,'domains');
else
  S(:,'domains') = array2table(ones(height(S),1));
end

%Get the names of the parameters
paramNames = Praw.Names;

%Use the param variables as column names
Praw = Praw(:,2:end);
Praw.Properties.RowNames = paramNames;

if any(S.Properties.VariableNames == "RES")
  modelMeta.nS = S{"RES","domains"} + S{"NER_shale","domains"} + S{"EAS","domains"} - 1;
end

%Initialize the parameter table P
P = Praw(:,1);

%Add the fitting attribute
P(:,'fitting') = array2table(Praw.fitting==1);

%Create the transformation object
trans = createTrans(string(Praw.trans),Praw.shift,Praw.scaling);
P(:,'trans') = array2table(trans);

%If useFirst is enabled, use the value of the first data point as Initial
%value for the determination of the start value
if optMaster.useFirst
  stateVarNames = S.Properties.RowNames;
  namesParam = P.Properties.RowNames;
  idxStates = S.meas>=1;
  for idx = 1:length(idxStates)
    % if the state is also listed as parameter
    if ismember(stateVarNames(idx),namesParam) && idxStates(idx)
      xvalue = loaded.data{idx}(1);
      P{stateVarNames(idx),"InitValue"} = xvalue;
    end
  end
end

if isfield(modelMeta,"customFun")
  [P,S,modelMeta,~] = modelMeta.customFun(P,S,modelMeta,loaded);
end

%Create the distribution objects
dists = makeMyDist(string(Praw.dist), P.InitValue, Praw.b, trans);
P(:,'dist') = array2table(dists);

%If loadR is enabled, load the different radii for the spherical model
if isfield(modelMeta,"loadR")
  [r,dr,A] = detR(S{"RES","domains"}+S{"NER_shale","domains"}+1, Praw{"r","InitValue"});
  modelMeta.radii = r;
  modelMeta.dr = dr;
  modelMeta.A = A;
end

% Activate all parameters that belong to the current growth model for fittig
% and deactivate the parameters, that belong to other growth models
if isfield(modelMeta,"fGrowth")
  P{modelMeta.fullParams,"fitting"} = 0;
  P{modelMeta.usedParams,"fitting"} = 1;
end

%Give a warning and save the workspace in case something went wrong
if any(isnan(S.value))
  warning("S contains NaNs")
  save(dirs.log + "logloadParams.mat")
end

end