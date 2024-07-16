function [pFitted,val,obj] = calib(optMaster,optGlob,optMulti,optSur,data,S,P,modelMeta,tFull,tObs,weights,dirs)
arguments
  optMaster struct
  optGlob struct
  optMulti struct
  optSur struct
  data (1,:) cell
  S table
  P table
  modelMeta struct
  tFull (1,:) {mustBeNumeric}
  tObs (1,:) cell
  weights cell         %Choose {0} for default values
  dirs struct
end

margin = 1e-7;

if weights{1} == 0
  %Loop over datasets
  for i = 1:length(data)
    %Create a uniform vector of weights
    weights{i} = ones(length(data{i}),1);
  end
end

% Get the number of parameters that are fitted
nPf = sum(P.fitting);

%Decide on the start value of the solver
switch optMaster.optStart
  case "center"
    %Choose the start condition at the center of gravity of the probability
    %distribution
    p0 = ones(nPf,1)*0.5;
  case "random"
    %Choose a random starting condition
    p0 = rand(nPf,1);
  otherwise
    warning('optStart option not recognised, using "center" as default option')
    p0 = ones(nPf,1)*0.5;
end

%% Create an optimization problem

% Choose the objective function based on the model setting
if isfield(modelMeta,"objFun")
  obj_fun = @(input)modelMeta.objFun(input,data,S,tFull,tObs,P,optMaster,modelMeta,weights,dirs);
else % Default option
  obj_fun = @(input)fitODE(input,data,S,tFull,tObs,P,optMaster,modelMeta,weights,dirs);
end

% Create upper and lower bound for fitting
upperBoundsFitting = ones(nPf,1)*(1-margin);
lowerBoundsFitting = zeros(nPf,1) + margin;

% Create an optimization problem. This is not used by the surrogateopt
% algorithm
problem_fcon = createOptimProblem(optMaster.CalAlg,'x0',p0,...
  'objective',obj_fun,'lb',lowerBoundsFitting,...
  'ub',upperBoundsFitting,'options',optMaster.optCalib);
try
  switch optMaster.optType
    case "local"
      %Do a local calibration with fmincon
      [solNorm,val,~,~,obj] = fmincon(problem_fcon);

    case "global"
      %Create a global search object
      gs = GlobalSearch('MaxTime',optGlob.MaxTime,...
        'Display',optGlob.Display,...
        'NumStageOnePoints',optGlob.NumStageOnePoints,...
        'NumTrialPoints',optGlob.NumTrialPoints);

      %Run the global search
      [solNorm,val,~,~,obj] = run(gs,problem_fcon);

    case "surrogate"

      optionsSur = optimoptions('surrogateopt','MaxTime',optGlob.MaxTime,...
        'MaxFunctionEvaluations',optSur.MaxFunctionEvaluations,...
        'Display','none');
      problemSurrogate = struct('objective',obj_fun,...
          'lb',lowerBoundsFitting,...
          'ub',upperBoundsFitting,...
          'options',optionsSur,...
          'solver','surrogateopt',...
          'InitialPoints',p0);
      [solNorm,val,~,~,obj] = surrogateopt(problemSurrogate);
      
    case "multi"
      %Create a MultiStart object
      ms = MultiStart('MaxTime',optMulti.MaxTime,...
        'Display',optMulti.Display,...
        'UseParallel',optMulti.UseParallel);

      %run the MultiStart search
      [solNorm,val,~,~,obj] = run(ms,problem_fcon,optMulti.StartPoints);
    otherwise
      warning('Calibration type not recognised, using start Values as calibration result')
      solNorm = 0.5*ones(nPar,1);
  end
catch e
  warning("Calibration failed, the error message was \n%s",getReport(e))
  save(dirs.log + "logCalib.mat")
  solNorm = NaN(size(p0));
  val = NaN;
  obj = NaN;
end

% Post-processing of calibration
pFitted = calibPost(solNorm,P);
end