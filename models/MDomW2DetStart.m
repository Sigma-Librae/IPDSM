function [A0] = MDomW2DetStart(S,p,dirs)
%Function to determine initial values based on the properties of the state
%Variables and parameters defined in S and P
arguments
  S table
  p (1,:) table
  dirs (1,1) struct
end

nameDomains = S.Properties.RowNames;

%Replace the values in S with the parameters from p if such a value exists
%in p
for idx = 1:height(S)
  if any(ismember(nameDomains(idx),p.Properties.VariableNames)) && S{nameDomains(idx),"dynamic"}
    S{nameDomains(idx),"value"} = p.(string(nameDomains(idx)));
  end
end

EAS = S{"EAS","value"};
RES = S{"RES","value"};

%Determine the total number of RES-domains
nS = S{"RES","domains"};

%Add the water and the two degradation domains to get the full number of
%domains
n = sum(S.domains);
n_deg = sum(S.domains(3:end));
 
A0 = NaN(n,1);

% Determine CW in mass/V_w
A0(1) = EAS/p.theta/p.rho;

%Create the initial conentration in S1
A0(2) = p.K_f*A0(1)^p.m;

%Create the concentration distribution for the RES
A0(2:end-n_deg) = initDist(nS,p.factor,RES);

%Create the initial condition for the degradation products
A0(end-n_deg+1:end) = S.value(3:end);

end


