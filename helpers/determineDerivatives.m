function [df] = determineDerivatives(tFull,tObs,P,S,n,obs,modelMeta,dirs,xStep)

arguments
  tFull (1,:) {mustBeNumeric}
  tObs (1,:) cell
  P table
  S table
  n (1,1) {mustBeInteger} %number of points where the derivative is determined
  obs (1,:) cell
  modelMeta struct
  dirs (1,1) struct
  xStep = 1e-4;
end

%Get the time at which the determination for derviatives starts to
%determine the total time it took
starttime = now;

%Get the names of the parameters
names = P.Properties.RowNames;

%Get only the names of the parameters that are fitted
%namesf = P.Properties.RowNames(P.fitting);

%Get the number of fitted parameters
nPf = sum(P.fitting);

%Get the number of fitted parameters
nP = height(P);

%Get the number of state variables
nS = height(S);

%Create an empty table for the derivatives for one quantity
df = array2table(NaN(n,nPf));
df.Properties.VariableNames = P.Properties.RowNames(P.fitting);

%Create an empty array for the derivatives for all quantities
df = repmat({df},nS,1);

%Draw normalized (0,1) input values with the latin hypercube algorithm and
%create a table with the drawn values
inputNorm = lhsdesign(n,nPf);
inputNorm = array2table(inputNorm);
inputNorm.Properties.VariableNames = P.Properties.RowNames(P.fitting);

%Transform the normalized into absolute values
input = norm2abs(inputNorm,P);

for i = 1:n
  %Save the workspace to a .mat file to recreate the conditions in case
  %somethin goes wrong
  save(dirs.log + 'logdetermineDerivatives')

  %Print some feedback about the state of the calculation
  if mod(i,10)==0
    stoptime = starttime+(now-starttime)*n/i;
    fprintf('%s The function "determineDerivatives" is %d %% done\n It will probably be finished by %s\n',...
      datestr(now),round(i/n*100),datestr(stoptime))

  end

  %Get the input parameter values for the current iterations, put them in a table and
  %give them a name
  xinput = P.InitValue;
  xinput(P.fitting) = input{i,:};
  pStart = array2table(reshape(xinput,1,nP));
  pStart.Properties.VariableNames = names';

  %{

  %Clear the last warning to use lastwarn later
  lastwarn('')

  [~,A] = modelMeta.starter(tFull,pStart,modelMeta,S,dirs);


  %If a warning occured during the execution of the ode-solver, reject the
  %solution
  if ~isempty(lastwarn)
    warning("The odeSolver encountered a potential error, I reject the solution and try with the next one")
    continue %Skip this iteration
  end

  %Save the NRMSE
  NRMSE = NaN(nS,1);
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
    inputNormStep = inputNorm(i,namesf{j});
    inputNormStep{1,1} = inputNormStep{1,1} + xStep;

    %Get the absolute value from the icdf
    inputStep = norm2abs(inputNormStep,P);

    %Get the parameter values of all parameters
    pStep = pStart;

    %Change the parameter that should be changed for this iteration
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
    fStep = NRMSE;

    %Calculate the derivative based on the finite difference method
    for k = 1:nS
      FD = (fStep(k)-fStart(k))/xStep;
      df{k}(i,namesf{j}) = table(FD);
    end
  end
  %}
  FD = localDerivative(modelMeta,S,P,inputNorm(i,:),tFull,tObs,obs,dirs,xStep);
  for k = 1:nS

    df{k}(i,:) = array2table(FD(:,k)');
  end

end

%Delete all values that are inf or NaN
for k = 1:length(df)
  df{k} = df{k}(all(isfinite(df{k}{:,:}),2),:);
end