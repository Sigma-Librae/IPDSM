function [errVal] = errMeas(tObs,data,t,sim,P,S,weights)
%Function to calculate the model selection criterion (unfinished)

arguments
  tObs (:,1) cell
  data (:,1) cell
  t    (:,1) {mustBeNumeric}
  sim  (:,:) {mustBeNumeric}
  P table
  S table
  weights = 0 %#ok<INUSA> Option to use wheights on the data (not implemented)
end

%Define empty arrays for the whole dataset and the terms for the MSC
dataArray = [];
simArray = [];
numerator = NaN(length(data),1);
denominator = numerator;

RMSE_ = NaN(length(data),1);
NRMSE = NaN(length(data),1);

for idxLoop = 1:length(data)
  %Get the index of times that are in the current dataset
  idxTime = ismember(t,tObs{idxLoop});

  %Get the times that belong to the index
  xsim = sim(idxTime,idxLoop);

  %Get the respective dataset
  xdata = data{idxLoop};

  %If the data ios marked as "observed"
  if S.meas(idxLoop)
    %Append the data to data Array to keep track of the total number of
    %datapoints
    dataArray = [dataArray;xdata]; %#ok<*AGROW>
    simArray = [simArray;xsim];

    %Calculate the numerator and the denominator for the MSC
    numerator(idxLoop) = sum((xdata-mean(xdata)).^2);
    denominator(idxLoop) = sum((xdata-xsim).^2);

    RMSE_(idxLoop) = RMSE(xsim,xdata);
    NRMSE(idxLoop) = 1/(max(xdata)-min(xdata))*RMSE_(idxLoop);
  end

  
end

% Get the number of parameters
nPar = sum(P.fitting);

errVal.MSC = log(sum(numerator./denominator,'omitnan'))-2*nPar/length(dataArray);
errVal.MSE = sum(((dataArray-simArray)).^2)/length(simArray);
errVal.RMSE = mean(RMSE_,'omitnan');
errVal.NRMSE = mean(NRMSE,'omitnan');


end