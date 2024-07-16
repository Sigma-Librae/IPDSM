clc
clear
close all

%Script to simulate sampling from the water phase and visualize the
%difference between the simulated "true" value in the water and the simulated
%observed value

load(pwd + "/../dirs.mat","dirs")

savePath = "C:\Users\Matthias\OneDrive\Desktop\Arbeit\Writing\support_files\Plots\";

%Font sizes for the plot
lblSize = 12;
title_size = 16;
legend_size = 11;

%Flag for saving the created plots
flags.save = 1;

% Add directories, that contain functions, to the path
addpath(dirs.home,dirs.models,dirs.odes,dirs.helpers,dirs.boot.main)

% Load the names related to the datasets
%[~,result_name,titles] = load_Dalk(13);
%german_titles = strings(size(result_name));


resultsPath = dirs.home + "Results/Manuscript/";
subplot

filenames = ["MDomWNER_SMX_s_Dalk_boot.mat", "MDomWNER_TRI_s_dalk.mat"];
filenames = filenames(contains(filenames,"."));

titles = filenames;


% + ["24_0405_MDomWNER_TRI_s_dalk",...
%   "24_0321_MDomWNER_SMX_s_Dalk_boot",...
%   "24_0321_MDomWNER_NAP_s_Dalk_boot",...
%   "24_0320_MDomWNER_DIC_s_Dalk_boot",...
%   "24_0320_MDomWNER_CAR_s_Dalk_boot",...
%   "24_0320_MDomWNER_BEZ_s_Dalk_boot"]...
%   + ".mat";

% Flag for plotting results for individual timesteps
flag_plotting_steps = 0;

% Flag for plotting the generalized simulation
flag_plotting = 1;

% Factor by which the water content is increased during extraction
dilution_factor = 5;

NRMSE_list_extract = NaN(1,length(filenames));
NRMSE_list_model = NaN(1,length(filenames));
NRMSE_list_extract_alt = NaN(1,length(filenames));
error_percent_list = NaN(1,length(filenames));

for idx = 1:length(filenames)
  % If values were already loaded, delete them so it does not interfere
  % with the data that is loaded next
  if exist('loaded','var')
    clear loaded
  end
  loaded = load(resultsPath + filenames(idx));
  NRMSE_list_model(idx) = loaded.errVal.NRMSE;

  splits = strsplit(filenames(idx),'_');
  titles(idx) = splits(2) + "_" + splits(3);

  %Define the number of timepoints for simulated sampling
  %n_t = 100;

  % Define the time-vector
  %t = linspace(0.1,max(loaded.loaded.tFull),n_t);
  t = uniquetol(loaded.loaded.tFull,0.4/max(loaded.loaded.tFull));
  n_t = length(t);

  % Set the states in S to dynamic so the starting value for the states is
  % defined by the calibrated value for it
  loaded.S{"EAS","dynamic"} = 1;
  loaded.S{"RES","dynamic"} = 1;

  % Define an empty vectors for the results of the simulated
  deviations = NaN(n_t,1);

  squared_differences = NaN(n_t,1);

  simulated_true_values = NaN(n_t,1);

  thetaOrg = loaded.pFitted.theta;

  % Adjust theta according to the dilution factor
  thetaDil = thetaOrg*dilution_factor;


  % Loop over the timesteps
  for idxInner = 1:n_t

    %tSampling = linspace(0.5,t(idxInner),30);


    % if the first value  in t is zero, set it to a positive value slightly
    % above zero to avoid problems
    if t(idxInner)<=0
      t(idxInner) = 1e-4;
    end

    % Simulation time in advance of extraction
    tInit = linspace(0,t(idxInner),100);

    % Simulation time of extraction
    tSample = linspace(1e-4,1,100);

    loaded.pFitted.theta = thetaOrg;

    % Run the simulation to the sampling point
    [tSimInit,Fitted1,fullFit1] = loaded.modelMeta.starter(tInit,...
      loaded.pFitted,loaded.modelMeta,loaded.S,loaded.dirs);

    loaded.pFitted.theta = thetaDil;

    % Adjust the initial conditions so C_W is properly diluted by the
    % increase of theta
    %loaded.modelMeta.A0 = fullFit1(end,:).*[1/dilution_factor,ones(1,width(fullFit1)-1)];
    loaded.modelMeta.A0 = fullFit1(end,:);

    % Run the simulation starting with the sampling point
    [tSim2,Fitted2,fullFit2] = loaded.modelMeta.starter(tSample,loaded.pFitted,loaded.modelMeta,loaded.S,loaded.dirs);
    tSim2 = tSim2 + max(tInit);

    % Remove the field A0 so for the next iterations so there is no default
    % value for A0 anymore and it will be calculated
    loaded.modelMeta = rmfield(loaded.modelMeta,'A0');

    % titles = ["b","r","y","g"];
    % for idx = 1:width(Fitted)
    %   plot(tSimInit,Fitted(:,idx),titles(idx))
    %   hold on
    % end
    % for idx = 1:2
    %   plot(tSim2,Fitted2(:,idx),titles(idx)+"--")
    % end
    % legend({'EAS','RES','DIS','NER'})


    %% Plotting
    if flag_plotting_steps
      figure %#ok<*UNRCH>

      % Plot the part before the sampling
      plot(tSimInit,fullFit1(:,1),'b',LineWidth=2)
      hold on

      % Plot the part after the sampling
      plot(tSim2,fullFit2(:,1),'b',LineWidth=2)
      xlabel('Time [d]')
      ylabel('C_W [µg/kg]')
      %title(titles(idx))
      %legend(["Normaler Verlauf", "Verlauf während Extraktion"],location = "best")
      xline(max(tSimInit))
      if flags.save
        exportgraphics(gcf,savePath + filenames(idx) + ".png","Resolution",300)
      end
    end

    deviations(idxInner) = fullFit2(end,1);

    % Calculate the error through extraction as as percentage (might be
    % problematic, may need corrections)

    squared_differences(idxInner) = (fullFit2(end,1)...
      -fullFit1(end,1))^2;

    simulated_true_values(idxInner) = fullFit1(end,1);



    %disp('Deviation of ' + string(round(percent_difference)) + '%')


  end
  loaded.pFitted.theta = thetaOrg;
  % Run the simulation to the sampling point
  [~,SimSamplingPoints] = loaded.modelMeta.starter(t,...
    loaded.pFitted,loaded.modelMeta,loaded.S,loaded.dirs);




  NRMSE_list_extract(idx) = sqrt(sum(squared_differences)/n_t)/(max(simulated_true_values)-min(simulated_true_values));
  NRMSE_list_extract_alt(idx) = sqrt(sum(squared_differences)/n_t)/mean(simulated_true_values);

  term1 = abs(deviations-SimSamplingPoints(:,1))./SimSamplingPoints(:,1);
  [~,idxMax] = max(term1);
  term1(idxMax) = [];
  error_percent_list(idx) = mean(term1)*100;

  disp('NRMSE is: ' + string(NRMSE_list_extract(idx)))
  titles = ["(a)","(b)"];
  if flag_plotting
    subplot(1,2,idx)
    %figure
    % plot the extraction error
    plot(t+1,deviations,'b--','LineWidth',1.5)
    hold on
    % plot the simulated "true" value
    plot(tSimInit,fullFit1(:,1),'b-','LineWidth',1.5)
    xlim([0,max(t)])
    xlabel('Time [d]','FontSize',lblSize)
    if idx == 1
      ylabel('C_w [\mug/kg]','FontSize',lblSize)
    end
    %title(titles(idx))
    %ylabel('C_w [µg/kg]',FontSize=lblSize)
    %title(titles(idx),FontSize=title_size)
    %legend('simulated "observed" value','simulated "true" value',fontsize=legend_size)

    hold off
  end
end
if flags.save
  exportgraphics(gcf,savePath + "Fig3" + ".tif","Resolution",600)
end



NRMSE_table = array2table([round(NRMSE_list_model,3)',round(NRMSE_list_extract,3)']);
NRMSE_table.Properties.RowNames = cellstr(titles');
NRMSE_table.Properties.VariableNames = ["NRMSE model","NRMSE extraction"];
writetable(NRMSE_table,savePath + 'NRMSE_extraction.csv',"WriteRowNames",true)

% hold on
%
% titles = ['bx','rx'];
% for idx = 1:length(loaded.data)
%   scatter(loaded.tObs{idx},loaded.data{idx},titles(idx))
% end




