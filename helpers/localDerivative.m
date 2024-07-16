function FD = localDerivative(modelMeta,S,P,inputNorm,tFull,tObs,obs,dirs,xStep)

arguments
  modelMeta struct
  S table
  P table
  inputNorm table
  tFull (:,1) {mustBeNumeric}
  tObs (:,1) cell
  obs (:,1) cell
  dirs struct
  xStep (1,1) {mustBeNumeric} = 1e-8; 
end

names = P.Properties.RowNames; %name of parameters
namesf = names(P.fitting); %names of fitted parameters
nP = length(names); % number of parameters
nPf = length(namesf); % number of fitted parameters
nS = height(S); %number of state variables

FD = NaN(nPf,nS); % Empty array for finite differences 

input = norm2abs(inputNorm,P);

%Get the input parameter values for the current iterations, put them in a table and
%give them a name
xinput = P.InitValue;
xinput(P.fitting) = input{1,:};
pStart = array2table(reshape(xinput,1,nP));
pStart.Properties.VariableNames = names';

%Clear the last warning to use lastwarn later
lastwarn('')

[~,A] = modelMeta.starter(tFull,pStart,modelMeta,S,dirs);


%If a warning occured during the execution of the ode-solver, reject the
%solution
if ~isempty(lastwarn())
  warning("The odeSolver encountered a potential error, I reject the solution and try with the next one")
  return %Skip this iteration
end

%Save the NRMSE
NRMSE = NaN(nS,1);

%Loop over the state variables
for k = 1:nS
  if S.meas(k)
    xA = A(ismember(tFull,tObs{k}),k);
    xobs = obs{k};
    NRMSE(k) = 1/(max(xobs)-min(xobs))*RMSE(xA,xobs);
  else
    xA = A(:,k);
    NRMSE(k) = 1./(max(xA)-min(xA))*sum(xA);
  end
end
fStart = NRMSE;

%Loop over parameters
for j = 1:nPf
  %Add a small increment to the normalized parameter value
  inputNormStep = inputNorm(1,namesf{j});
  inputNormStep{1,1} = inputNormStep{1,1} + xStep;

  %Get the absolute value from the icdf
  inputStep = norm2abs(inputNormStep,P);

  %Get the parameter values of all parameters
  pStep = pStart;

  %Change the respective parameter for this iteration
  pStep.(string(namesf{j})) = inputStep.(string(namesf{j}));

  %Clear the last warning to use lastwarn later
  lastwarn('')

  [~,A] =  modelMeta.starter(tFull,pStep,modelMeta,S,dirs);

  %If a warning occured since the last warning cleanup
  if ~isempty(lastwarn)
    warning("The odeSolver encountered a potential error, I reject the solution and try with the next entry")
    continue
  end

  %Save the NRMSE
  NRMSE = NaN(length(obs),1);

  %Loop over the state variables
  for k = 1:nS
    %If an observation for the repective state variable exists
    if S.meas(k)
      %Get the simulated values for the respective state variable
      xA = A(ismember(tFull,tObs{k}),k);

      %Get the observations for the repsective state variable
      xobs = obs{k};

      %Calculate the NRMSE
      NRMSE(k) = 1/(max(xobs)-min(xobs))*RMSE(xA,xobs);

    %If there is no observation for this state variable
    else
      xA = A(:,k);
      NRMSE(k) = 1./(max(xA)-min(xA))*sum(xA);
    end
  end
  fStep = NRMSE;
  FD(j,:) = (fStep-fStart)./xStep;
end

end %end function
