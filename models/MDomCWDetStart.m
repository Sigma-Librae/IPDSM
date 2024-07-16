function [A0] = MDomCWDetStart(S,p,dirs)
%Function to determine initial values based on the properties of the state
%Variables and parameters defined in S and P
arguments
  S table
  p (1,:) table
  dirs (1,1) struct
end

% Get the names of all domains
nameDomains = S.Properties.RowNames;

%Replace the values in S with the parameters from p if such a value exists
%in p
for i = 1:height(S)
  if any(ismember(nameDomains(i),p.Properties.VariableNames))
    S{nameDomains(i),"value"} = p.(string(nameDomains(i)));
  end
end

CW  = S{"CW","value"};
EAS = S{"EAS","value"};
RES = S{"RES","value"};
TM = S{"TM","value"};
NER = S{"NER","value"};

%Determine the number of solid domains
%nS = S{"RES","domains"} + S{"NER_shale","domains"}; %IMPLEMENTATION OUTDATED!
nRES = S{"RES","domains"};

%Get the full number of domains
n = sum(S.domains);
n_deg = sum(S.domains(5:end));

%Create an empty array for the result
A0 = NaN(n,1);

%Create the concentration in the water
A0(1) = CW;

%Create the initial conentration in S1
A0(2) = EAS;

%Create the concentration distribution for the RES
A0(3:nRES+2) = initDist(nRES,p.factor,RES);

%Create the concentration distribution for the RES
A0(nRES+3:end-n_deg) = zeros(S{"NER_shale","domains"},1);

%Create the initial condition for the degradation products
A0(end-1:end) = [TM;NER];

end


