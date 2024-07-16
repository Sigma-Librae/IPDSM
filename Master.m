function Master(optMaster,dirs,optGlob,optMulti,optSur)

diary(dirs.log + "commandLog.txt")

fprintf("%s Starting Master with dataset '%s'\n",datestr(now),optMaster.data)

% Give a feedback if saving is not activated in case this happened
% accidentally
if ~optMaster.save
    fprintf("Saving is deactivated\n")
end

% Add directories, that contain functions, to the path
addpath(dirs.models,dirs.odes,dirs.helpers,dirs.boot.main)

%Create all subdirectories specified in dirs that do not exist
fn = fieldnames(dirs);
for i = 1:length(fn)
  if isa(dirs.(string(fn(i))),'string')
    if ~exist(dirs.(string(fn(i))),'file')... if the directory does not exist
        && ~contains(dirs.(string(fn(i))),".") % and is not a filename (does not contain a dot)
      %create the directory
      mkdir(dirs.(string(fn(i))))
    end
  end
end

%Create the metadata that will be saved with the model results
metadata.dirs = dirs;
metadata.StartTime = datestr(now);

%Load the observations
loaded = load(dirs.data + optMaster.data + ".mat",'data','tObs','tFull');

%Load the parameters
[S,P,modelMeta] = loadParams(optMaster,loaded,dirs);

% Get the names of the state variables
stateVarNames = S.Properties.RowNames;

%Get the names of the parameters
namesParam = P.Properties.RowNames;

%Get only the names of the parameters that will be fitted
namesParamf = namesParam(P.fitting);

%Get the number of parameters that are fitted
nPf = sum(P.fitting);

%Get the filename of the derivatives that are needed for the sensitivitiy
%analysis
dfFilename = dirs.data + modelMeta.model + "_" + optMaster.DIS + "_df.mat";

%Give the time vector a simpler name
t = loaded.tFull;

%% Sensitivity analysis
try
  if optMaster.doSA
    %If determination of derivatives is enabled, determine the derivatives
    if optMaster.doDeriv || ~exist(dfFilename,'file')
      fprintf('Determining derivatives...\n')
      tic
      df = determineDerivatives(loaded.tFull,loaded.tObs,P,S,optMaster.ndf,loaded.data,modelMeta,dirs);
      fprintf('%s Determination of derivatives finished after %d seconds\n\n',datestr(now),round(toc));
      if optMaster.save
        save(dfFilename,'df');
      end
    else
      load(dfFilename,'df')
    end

    %Create an empty array for the activity scores
    activityScore = NaN(nPf, height(S));
    for i = 1:length(df)
      dfSingle = df{i};
      
      % Logical column vector that contains 1 for all rows that do not
      % contain any complex value and 0 for rows that do
      logicReal = all(imag(dfSingle{:,:})==0,2);

      %Test for outliers
      logicOutlier = all(~isoutlier(real(dfSingle{:,:})),2);
      
      %Logical array that contains 1 for all rows that contain only real
      %values and no outliers
      logic = logicReal & logicOutlier;

      %Delete all values that were marked as outliers
      dfSingle = dfSingle(logic,:);

      %Determine the activity score
      [~,~,activityScore(:,i)] = eigenActSS(dfSingle,dirs);
    end

    % Convert the activity scores in percentages
    activityScore = array2table(round(activityScore*100));

    %Add the parameter and stateVariable names to the activity score table
    activityScore.Properties.RowNames = namesParamf;
    activityScore.Properties.VariableNames = stateVarNames;
    
    % Save the activity scores as csv file
    writetable(activityScore,sprintf('%s%s_actScore.csv',dirs.tables,modelMeta.model),WriteRowNames=true)
  end
catch e
  warning("Global Sensitivity Analysis has failed, the error message was: \n%s",getReport(e))
end



%% Calibration and Bootstrapping

%Put the initial parameter values in a table and label the table
pFitted = array2table(reshape(P.InitValue,1,[]));
pFitted.Properties.VariableNames = P.Properties.RowNames';
pFittedNorm = abs2norm(pFitted,P); %#ok<NASGU> 


if optMaster.boot.do
  %Print feedback
  fprintf('%s Starting bootstrapping...\n',datestr(now))
  
  %Get the starttime of the bootstrapping
  startBoot = now;

  %Run the bootstrapping
  [bootTable,bootW,bootparam] = initBoot(optMaster,optGlob,optMulti,optSur,loaded.data,S,P,modelMeta,loaded.tFull,loaded.tObs,dirs); %#ok<ASGLU> 
  fprintf('%s Bootstrapping finished after %d seconds\n',datestr(now), round((now-startBoot)*86400))
end

saveName = dirs.results + dirs.resultFile;
if optMaster.save
  save(saveName)
end

% If calibration is enabled
if optMaster.doCalib
  %Get the starttime of the calibration
  startCalib = now;
  fprintf('%s Starting calibration of type "%s"...\n',...
    datestr(now),optMaster.optType)

  tic

  %Do the calibration
  [pFitted,val,obj] = calib(optMaster, optGlob,optMulti,optSur,...
                        loaded.data,S,P,modelMeta,loaded.tFull,loaded.tObs,{0},dirs); %#ok<ASGLU> 


  fprintf('%s Calibration finished after %d seconds\n',datestr(now), round((now-startCalib)*86400))
end

if optMaster.doCalib && 0==1
  %Do a local sensitivity analysis
  local_act_score = array2table(localDerivative(modelMeta,S,P,abs2norm(pFitted(1,P.fitting),P),loaded.tFull, loaded.tObs, loaded.data, dirs));
  local_act_score.Properties.VariableNames = stateVarNames;
  local_act_score.Properties.RowNames = namesParamf;
end

% Create additional timepoints for the simulation according to the 
if isfield(modelMeta,"tIntervall")
  if isstring(modelMeta.tIntervall)
    switch modelMeta.tIntervall
      case "original"
        tAdd = [];
    end
  end  
end

% Default option
if ~exist("tAdd","var")
  tAdd = 0:max(t);
end

%Sort the time array
t = sort([t;tAdd']);

%Delete any duplicates
t = unique(t);

%Run the model a last time with the determined parameters to get and visualize the
%final simulations
[t,Fitted,fullFit] = modelMeta.starter(t,pFitted,modelMeta,S,dirs); %#ok<ASGLU> 


if isfield(modelMeta,"check_massbalance")
  [mass_condition,max_dev] = check_massbalance(Fitted,S,pFitted);

  if ~mass_condition
    warning(['Mass balance of the calibration result is not balanced \n', ...
      'The maximum deviation is: %.3f µg/kg \n'],max_dev)
  else
    fprintf('Mass balance is balanced\n\n')
  end
end

%Calculate the models selection criterion (MSC) and the MSE

try
  errVal = errMeas(loaded.tObs,loaded.data,t,Fitted,P,S); 
catch
  warning("The function errMeas failed")
end



%% Plotting

%Plot the probability distributions of the parameters
plotDist(P)

%save the plot if saving is enabled
if optMaster.save
  exportgraphics(gcf,sprintf('%sprob_dist.png',dirs.graphs));
else
  save("./lastResult");
end


if optMaster.doCalib
  %Plot the model results
  figure 
  set(gcf, 'Position',[20,20,900,500])
  plot(t,Fitted,'LineWidth',1.5)
  colors = get(gca,'colororder');
  hold on
  for i = 1:length(loaded.data)
    if S.meas(i)
        plot(loaded.tObs{i},loaded.data{i},'x','Color',colors(i,:),'LineWidth',1.5)
    end
  end

  try
    title("RMSE: " + val + "; NRMSE:" + errVal.NRMSE + " " + optMaster.data)
  catch
    title("Missing title")
  end

  %ylim([0,max(max(Fitted,[],'all')*1.1,max(loaded.data,[],'all')*1.1)])
  plot(t,sum(Fitted,2),'LineWidth',1.5)
  if optMaster.save
    exportgraphics(gcf,sprintf('%sfitted.png',dirs.graphs))
  end
  
else
  figure 
  plot(t,Fitted)
  
end
legend([string(stateVarNames);strings(sum(S.meas),1);"Total"],'Location','best')

%figTable = uifigure;
%uitable(figTable,"Data",pFitted);

drawnow

% figure
% xFitted = Fitted;
% xFitted(:,1) = xFitted(:,1)/pFitted.theta/pFitted.rho;
% plot(sum(xFitted,2))
%{
try
figure
Amod = Fitted;
Amod(:,1) = Fitted(:,1)/pFitted.r;
mass = sum(Amod,2);
plot(t,mass)
catch
end
%}

%{
save(dirs.results + "test")
save(dirs.results + "test2","dirs")
testText = "test3";
save(dirs.results + testText)
%}

%Get the end time of this Master run
metadata.endTime = datestr(now); %#ok<STRNU> 

%If saving is enabled, save the whole workspace to the result file
if optMaster.save
  try
    save_name = dirs.results + dirs.resultFile;

    save_dir_alt = char(strrep(dirs.results,"Results","Results_backup"));
    save_dir_alt = save_dir_alt(1:end-1);

    save_name_alt = strrep(save_name,"Results","Results_backup");

    % If a file in the backup folder already exists
    if isfile(save_name_alt)

      % Load the error value of the already existing file
      loaded_error = load(save_name_alt,"errVal");

      % Overwrite the existing file if the NRMSE if its NRMSE is higher than
      % the current one
      if loaded_error.errVal.NRMSE>errVal.NRMSE
        disp('The new run is better than the previous best run. The former best run will be overwritten')
        save(save_name_alt)
      end
      % Create the directoy and save the current run
    else
      if ~isfolder(save_dir_alt)
        mkdir(save_dir_alt)
      end
      save(save_name_alt)
    end
  catch e
    warning("Saving to backup encountered an unexpected error, the error message was: \n%s",getReport(e))
  end
  
    if optMaster.boot.do
    splits = strsplit(saveName,".");
    saveName = splits(1) + "_boot." + splits(2);
  end
  save(saveName)
end

% Remove all directories that were added in the beginning from the path
rmpath(char(dirs.models))
rmpath(dirs.odes)
rmpath(dirs.helpers)
rmpath(dirs.boot.main)

%Print feedback
fprintf('%s Master finished successfully\n\n',datestr(now))

diary off
