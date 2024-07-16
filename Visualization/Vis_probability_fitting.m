clc
clear
close all

pathResults = "C:\Users\Matthias\Desktop\Program\Git\Programs_PhD\Results\Manuscript\";

% Path for definition of the general parameters for the model fitting
pathParams = "C:\Users\Matthias\Desktop\Program\Git\Programs_PhD\Params\";
paramsFile = pathParams + "MDomW_Params.csv";

% Path for definition of the specific parameters for the model fitting
pathSorbates = pathParams + "Sorbates\";
fileSorbates = pathSorbates + "TRI.csv";

% File that is used as basis for the creation of a new parameter file
inputFile = pathResults + "MDomWNER_TRI_s_Dalk.mat";

l = load(inputFile);

% Flag for the mode. 0 means that the exact value of parameters is used for
% simulation, 1 means that the confidence intervall is used. this doesn't
% work at the moment
flagType = 0;

% Current distributions that can be used for probability fitting
distributions = ["Normal", "Gamma"];

if flagType
  for idxHist = 1:width(l.bootparam)
    loadedParams = readtable(paramsFile,ReadRowNames=true);
    loadedParamsSorbates = readtable(fileSorbates,ReadRowNames=true);

    % Exclude columns of parameters that were not fitted
    if any(l.bootparam{:,idxHist} ~= l.bootparam{1,idxHist})
      % Get the name of the current parameter
      nameParam = string(l.bootparam.Properties.VariableNames{idxHist});

      figure
      %yyaxis left
      histogram(l.bootparam{:,idxHist},Normalization="pdf")
      title(l.bootparam.Properties.VariableNames(idxHist))
      disp(l.bootparam.Properties.VariableNames(idxHist))
      hold on
      %yyaxis right
      %mleResult = mle(l.bootparam{:,idxHist});
      for idxDist = 1:length(distributions)
        pds{idxDist} = fitdist(l.bootparam{:,idxHist},distributions(idxDist));
        x = linspace(pds{idxDist}.icdf(5e-3),pds{idxDist}.icdf(1-5e-3),length(l.bootparam{:,idxHist}));
        y = pdf(pds{idxDist},x);
        objFun(idxDist) = sum(abs(prctile(y,1:100)-prctile(l.bootparam{:,idxHist},1:100)))/mean(l.bootparam{:,idxHist});
      end
      [~,idxMin] = min(objFun);
      xPd = pds{idxMin};

      if any(nameParam==loadedParams.Properties.RowNames)
        loadedParams{nameParam,"trans"} = "d";
        loadedParams{nameParam,"dist"} = lower(distributions(idxMin));
        loadedParams{nameParam,"shift"} = 0;
        loadedParams{nameParam,"shift"} = 1;
        if xPd.DistributionName == "Normal"
          loadedParams{nameParam,"InitValue"} = xPd.mu;
          loadedParams{nameParam,"b"} = xPd.sigma;

        elseif xPd.DistributionName == "Gamma"
          loadedParams{nameParam,"InitValue"} = (a-1)*b;
          loadedParams{nameParam,"b"} = xPd.b;
        end
      elseif any(nameParam==loadedParamsSorbates.Properties.RowNames)
        loadedParamsSorbates{nameParam,"trans"} = "d";
        loadedParamsSorbates{nameParam,"dist"} = lower(distributions(idxMin));
        loadedParamsSorbates{nameParam,"shift"} = 0;
        loadedParamsSorbates{nameParam,"shift"} = 1;
        if xPd.DistributionName == "Normal"
          loadedParamsSorbates{nameParam,"InitValue"} = xPd.mu;
          loadedParamsSorbates{nameParam,"b"} = xPd.sigma;

        elseif xPd.DistributionName == "Gamma"
          loadedParamsSorbates{nameParam,"InitValue"} = (a-1)*xPd.b;
          loadedParamsSorbates{nameParam,"b"} = xPd.b;
        end
      end

      plot(x,y,LineWidth=1.5)
      figure
      qqplot(l.bootparam{:,idxHist},xPd)
      disp(sum(abs(prctile(y,1:100)-prctile(l.bootparam{:,idxHist},1:100)))/mean(l.bootparam{:,idxHist}))
    end
  end
else

  % Load the general parameters
  loadedParams = readtable(paramsFile,ReadRowNames=true);

  % Loop over the parameters
  for idxTable = 1:height(loadedParams)
    % Exchange the intial value ofthe parameter by the value that was
    % defined during calibration
    loadedParams{loadedParams.Properties.RowNames{idxTable},"InitValue"} = l.pFitted.(loadedParams.Properties.RowNames{idxTable});
    % If it's EAS or RES set the fitting to 1 if not to 0
    if string(loadedParams.Properties.RowNames{idxTable})== "EAS" || string(loadedParams.Properties.RowNames{idxTable})== "RES"
      loadedParams{loadedParams.Properties.RowNames{idxTable},"fitting"} = 1;
    else
    loadedParams{loadedParams.Properties.RowNames{idxTable},"fitting"} = 0;
    end
  end
  % Add 'Copy' to the filename, so it does'nt overwrite the original file
  strings = split(paramsFile,'.');
  writetable(loadedParams, strings(1) + "_Copy." + strings(2),'WriteRowNames',true)

  % do the same as before for the parameters that are specific to the
  % sorbate
  loadedParams = readtable(fileSorbates,ReadRowNames=true);
  for idxTable = 1:height(loadedParams)
    if ~(loadedParams.Properties.RowNames{idxTable}=="k")
      loadedParams{loadedParams.Properties.RowNames{idxTable},"InitValue"} = l.pFitted.(loadedParams.Properties.RowNames{idxTable});
      loadedParams{loadedParams.Properties.RowNames{idxTable},"fitting"} = 0;
    end
  end

  strings = split(fileSorbates,'.');
  writetable(loadedParams, strings(1) + "Copy." + strings(2),'WriteRowNames',true)

end