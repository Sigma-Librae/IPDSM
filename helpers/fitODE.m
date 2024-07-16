function result = fitODE(inputNorm,obs,S,tFull,tObs,P,optMaster,modelMeta,weights,dirs)
arguments
  inputNorm (1,:) {mustBeNumeric}
  obs(1,:)  cell
  S table
  tFull (1,:) {mustBeNumeric}
  tObs (1,:) cell
  P table
  optMaster struct
  modelMeta struct
  weights cell
  dirs struct
end

%Get the number of parameters
nPar = length(inputNorm);

%Bring the input in to the correct dimensions (if this is already the case,
%nothing changes), put it in a table and label the table
inputNorm = reshape(inputNorm,1,nPar);
inputNorm = array2table(inputNorm);
inputNorm.Properties.VariableNames = P.Properties.RowNames(P.fitting)';

%Transform the normalized values into absolute ones
input = norm2abs(inputNorm,P);

%Transform the input into a table and label the table
p = array2table(reshape(P.InitValue,1,[]));
p.Properties.VariableNames = P.Properties.RowNames';


%Copy the parameters that are determined to the table that contains
%the initial parameters (parameter that are calibrated are
%overwritten, all other parameter values are equal to the initial values)
namesf = input.Properties.VariableNames;
for idx = 1:width(input)
  p(1,namesf{idx}) = input(1,namesf{idx});
end

% if any(p.Properties.VariableNames=="NER_shale")
%     S{"NER_shale","domains"} = round(p.NER_shale);
% end
% 
% if any(p.Properties.VariableNames=="n_RES")
%     S{"RES","domains"} = round(p.n_RES);
% end

%Clear lastwarn to use it later
lastwarn('')

%Simulate results with the current dataset
[~,A] = modelMeta.starter(tFull,p,modelMeta,S,dirs);

A(A<0) = 0;

%If the odesolver returned a warning, reject the result and return a
%very high value for the calibration algorithm
if any(isnan(A),'all')
  %warning("Values contain NaN, ignoring result")
  result = 1e4;
  return
end

%Calculate the NRMSE to use it as a target quantity for the optimization
NRMSE = NaN(length(S.meas),1); %Empty array

% Create an empty array for the RMSE and add an underscore to the name to
% distinguish between the variable and the function with the same name
RMSE_ =  NaN(length(S.meas),1);

for idx = 1:length(S.meas)
  if S.meas(idx) %if state was observed
    xobs = obs{idx}; %Take the current observation
    xA = A(ismember(tFull,tObs{idx}),idx); %Take all results that correspond to the respective time vector
    RMSE_(idx) = RMSE(xA,xobs,weights{idx});
    NRMSE(idx) = 1/(max(xobs(weights{idx}>0))-min(xobs(weights{idx}>0)))*RMSE_(idx);
    %NRMSE(i) = RMSE(xA,xobs,w{i}); %Calculate RMSE
  end
end
save(dirs.log + "NRMSEs.mat","NRMSE")

switch optMaster.errMeas
  case "NRMSE"  
    result = mean(NRMSE.*S.meas,"omitnan");
  case "RMSE"
    result = mean(RMSE_.*S.meas,"omitnan");
  otherwise
    warning("Type of error measurement not recognised, using NRMSE as default option")
    result = mean(NRMSE.*S.meas,"omitnan");
end
  

%Give a warning if the result is NaN for some reason
if isnan(result)
  warning('The result of fitODE is NaN')
  save(dirs.log + "logfit_ODE")
end
end