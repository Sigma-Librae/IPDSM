function [tFull,Afinal,A] = odeStarter(tFull,p,modelMeta,S,dirs)
arguments
  tFull     (:,1)   {mustBeNumeric}
  p         (1,:)   table
  modelMeta         struct
  S         (:,:)   table
  dirs              struct
end

%Function to start an odeSolver

%% Pre-Processing

% If the model already contains initial values, use them. Otherwise,
% determine them based on the method specified in the model or with the
% default option
if ~isfield(modelMeta,"nS")
  modelMeta.nS = S{"RES","domains"} + S{"NER_shale","domains"} + S{"EAS","domains"} - 1;
end

if isfield(modelMeta,'A0')
  A0 = modelMeta.A0;
else
  % Determine the initial values either based on the given values or based on
  % drawn parameters
  if isfield(modelMeta,"detStart")
    A0 = modelMeta.detStart(S,p,dirs);
  else
    %If the number of initial state is not equal to the number of domains (e.g.
    %when one state variable consists of more than on domain)
    if any(S.domains ~= 1)

      %Create an array with the full number of domains
      A0full = NaN(sum(S.domains),1);

      %Create counter to keep track of the domains
      counter = 1;
      for i = 1:length(S.domains)

        %If the state variable consists of more than one domain, then add a
        %start value for every additional domain
        if S.domains(i)>1
          A0full(counter:counter+S.domains(i)-1) = initDist(S.domains(i),p.factor,A0(i));
        else
          %Create the initial value from the array with initial values
          A0full(counter) = A0(i);
        end

        %Increase the coounter by the number of domains that were added
        counter = counter + S.domains(i);
      end
      %Overwrite the initial values that were just created
      A0 = A0full;
    else
      A0 = detA0(S,p);
    end
  end
end

%set the options of the ode-solver, this should be moved to the initializer
%of the master at some point
%opt = odeset('OutputFcn',@odeTimer,'RelTol',5e-3,'AbsTol',1e-4);

%Create a global variable to track the time since the ode-solver was
%started
%global startTimeode %#ok<GVMIS>
%startTimeode = now;


if any(S.Properties.RowNames=="CW")
  % Add an extra shell to nS in case CW is defined explicitly and hence
  % not part of EAS
  modelMeta.nS = S{"RES","domains"} + S{"NER_shale","domains"} + S{"EAS","domains"} - 1;
  modelMeta.nS = modelMeta.nS + 1;
end

%Turn the warning for integration tolerance off since it often appears
%during calibration and the result is discarded in this case anyway
warning('off','MATLAB:ode15s:IntegrationTolNotMet')

%Simulate results with the current dataset
[t,A] = ode15s(modelMeta.ode,tFull,A0,'',p,S,modelMeta,now);

%% Post Processing

%If a specific postprocessor exists for this model
if isfield(modelMeta,"post")
  Afinal = modelMeta.post(real(A),p,S);

  %Use the default post-processor
else

  %create an array for the results of all domains
  Afinal = NaN(height(A),length(S.domains));

  %Create a counter to keep track of the number of domains (just like the
  %counter above)
  counter = 1;

  %Loop over the number of state variables and average the domains, if a
  %state variable consists of more than one domain
  for i = 1:length(S.domains)
    Afinal(:,i) = mean(A(:,counter:counter+S.domains(i)-1),2);
    counter = counter + S.domains(i);
  end


end

%If the result is not of the expected dimensions, create an array of
%NaNs instead and save the workspace to recreate the conditions if
%necessary
if width(Afinal)~=length(S.domains) || height(Afinal)~=length(tFull)
  Afinal = NaN(length(tFull),length(S.domains));
  save(dirs.log + "logODEStarter.mat");
  %warning("The result does not have the expected dimensions")
end

end