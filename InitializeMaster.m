clc
clear
close all

%% Definition of input parameters

% Define the function that contains the name of the datasets
f = @()load_Dalk(12);

% Number of Master runs
nRuns = length(f());

% Flag for calibration
optMaster.doCalib   = 1;

% Flag and options for calculation of derivatives options
optMaster.doSA      = 0 ;  % Flag for sensitivity analysis
optMaster.doDeriv   = 0 ;  % Flag for creating derivatives
optMaster.ndf       = 1e3; % Number of derivatives

% Model function
optMaster.model = @MDomWNER;
optMaster.DIS = "TM";

% Flag for saving
optMaster.save = 1;

% Flag for using the first datapoint as initial value for the parameters that describe state variables 
optMaster.useFirst = 1;

% Flag for type of optimization, possible values are "local",
% "multi", "global" or "surrogate"
optMaster.optType   = "surrogate";

% Define options for the surrogate optimization
optSur.MaxTime = 6*60;
optSur.MaxFunctionEvaluations = 2e2;


% Flag and options for bootstrapping
optMaster.boot.do           = 0;        %Flag for bootstrapping
optMaster.boot.n            = 5e2;      %Number of bootstrap samples
optMaster.boot.bound        = 0.05;     %Confidence bounds
optMaster.boot.doParallel   = 0;        %Flag for parallelization
optMaster.boot.nParallel    = 25;       %Number of slaves
optMaster.boot.nPro         = 2;        %Number of processors per slave
optMaster.boot.runtime      = 72;       %Total maximum runtime in hours

%Name for the result File
resultName = out(f,2); 

%Name of the dataset
optMaster.data      = f();

%Starting point of the local optimization, current options are "center" and
%"random"
optMaster.optStart  = "random";
optMaster.CalAlg    = "fmincon";
optMaster.errMeas = "RMSE";

optMaster.optCalib  = optimoptions('fmincon',...
                      FiniteDifferenceType='central',...
                      StepTolerance=1e-6,...
                      MaxIterations=1e3,...
                      MaxFunctionEvaluations=3e3,...
                      Display='off');

%Define options for the global search
optGlob.MaxTime     = 6*60;
optGlob.Display     = "iter";
optGlob.NumStageOnePoints = 200;
optGlob.NumTrialPoints = 1e3;

% Define options for MultiStart
optMulti.MaxTime     = 8*60;
optMulti.Display     = "iter";
optMulti.UseParallel = true;
optMulti.StartPoints = 20;

%Define all directories
dirs.home       = pwd + "/";
dirs.models     = dirs.home + "models/";
dirs.odes       = dirs.home + "ODEs/";
dirs.data       = dirs.home + "data/";
dirs.log        = dirs.home + "logFunctions/";
dirs.graphs     = dirs.home + "Graphs/";
dirs.tables     = dirs.home + "Tables/";
dirs.results    = dirs.home + "Results/" + ...
  string(func2str(optMaster.model)) + "_" + optMaster.DIS + "/";
dirs.params     = dirs.home + "Params/";
dirs.paramsInd  = dirs.params + "Sorbates/";
dirs.states     = dirs.home + "States/";
dirs.helpers    = dirs.home + "helpers/";
dirs.logFiles   = dirs.home + "LogFiles/";

dirs.boot.main  = dirs.home + "Boot/";
dirs.boot.in    = dirs.boot.main + "Input/";
dirs.boot.out   = dirs.boot.main + "Output/";

addpath(dirs.helpers)
%% Processing of input parameters

%Create the filename(s) for the result file(s)
for i = 1:nRuns
  if length(optMaster.model) == 1
    mdlName = char(optMaster.model);
  else
    mdlName = char(optMaster.model{i});
  end
  if length(resultName)==1
    xdataset = resultName;
  else
    xdataset = resultName(i);
  end
  dirs.resultFile(i) = string(my_date + sprintf('%s_%s.mat',mdlName,xdataset));
end

%Combine all option structures in a cell array to loop over them
optCells = {optMaster,dirs,optGlob,optMulti,optSur};

%Clear the logFiles
%delete(dirs.logFiles + "*")

for i = 1:nRuns

  if nRuns >1
    %Copy every element in the structure for the Master. If the element is a
    %vector, it takes the i-th element, else it just copies the value, this
    %is done to change the options between runs of the master
    xoptCells = cell(size(optCells));
    for j = 1:length(optCells)
      fns = fieldnames(optCells{j});
      for k = 1:length(fns)
        %If the options consist of a vector with length nRun
        if length(optCells{j}.(fns{k}))==nRuns
          xoptCells{j}.(fns{k}) = optCells{j}.(fns{k}){i};
        %If the option consists of a scalar value
        elseif length(optCells{j}.(fns{k}))==1
          xoptCells{j}.(fns{k}) = optCells{j}.(fns{k});
        % If the option consist of vector that does not contain as many elements
        % than the number of runs, throw an error
        else
          error('Array size does not match the number of runs and is not one i = %d, j = %d, k = %d',i,j,k)
        end
      end
    end
  else
    xoptCells = optCells;
  end

  %save all the settings to recreate the conditions if something goes wrong
  save(dirs.log + "logInit.mat")
  
  %save the directories for other scripts to use
  save(dirs.home + "dirs.mat","dirs");

  try
    % Run the Master with the defined options
    Master(xoptCells{1},xoptCells{2},xoptCells{3},xoptCells{4},xoptCells{5})
  catch e
    warning('Master run number %d not successfull, the error meassage was: \n%s',i,getReport(e))
  end

  %runtimeCommands(i,dirs)
end
%InitializeMasterSit()
%shutdown