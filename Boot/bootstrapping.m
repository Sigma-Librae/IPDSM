function [w,p] = bootstrapping(optMaster,optGlob,optMulti,optSur,data,S,P,modelMeta,tFull,tObs,dirs,w)
% Function to run the bootstrapping
arguments
  optMaster struct
  optGlob struct
  optMulti struct
  optSur struct
  data (:,1) cell
  S table
  P table
  modelMeta struct
  tFull (1,:) {mustBeNumeric}
  tObs (1,:) cell
  dirs struct
  w cell
end

%Get the starttime of the function
starttime = now;

%Determine the parameter names
names = P.Properties.RowNames;

%Determine the names of parameters that should be fitted
namesf = names(P.fitting);

%Put it in a table and label the table
p = array2table(reshape(P.InitValue,1,[]));
p.Properties.VariableNames = P.Properties.RowNames';

%Create a table that only holds the intial values since the p table will be
%epxpanded to hold all bootstrapping samples
xp = p;

%Create placeholders for the results of inidividual optimizations
p(2:length(w),:) = array2table(NaN(length(w)-1,width(p)));

%Create the bootstrapping datasets
for i = 1:length(w)

  %Run the calibration with adjusted weights
  [sol,~] = calib(optMaster, optGlob,optMulti,optSur,...
    data,S,P,modelMeta,tFull,tObs,w{i},dirs); 
  
  %Switch the dimensions put it in a table and label the table
  %solNorm = array2table(reshape(solNorm,1,[]));
  %solNorm.Properties.VariableNames = namesf;
  %sol = norm2abs(solNorm,P);
  
  %Replace the fitted values in the inital values table
  for k = 1:width(sol)
    try
      xp(1,namesf{k}) = sol(1,namesf{k});
    catch
      stop = 1;
    end
  end
  p(i,:) = xp;
  
  %Give a feedback to estimate the remaining time
  if mod(i,10)==1
    stoptime = starttime+(now-starttime)*length(w)/i;
    fprintf('%s The function "bootstrapping" is %d%% done\n It will probably be finished by %s\n',...
      datestr(now),round(i/length(w)*100),datestr(stoptime))
  end

  % Save the workspace to recreate the conditions if necessary
  save(sprintf('%slogBoot.mat',dirs.log),'p')
end


end