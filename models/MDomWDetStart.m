function [A0] = MDomWDetStart(S,p,dirs)
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
nS = S{"RES","domains"} + S{"NER_shale","domains"} + S{"EAS","domains"} - 1;

%Add the water and the two degradation domains to get the full number of
%domains
n = sum(S.domains);
n_deg = sum(S.domains(4:end));
 
A0 = zeros(n,1);

targetFun = @(C)C + p.K_f*(C/(p.theta/p.rho))^p.m/(nS)-EAS;

%C_alt = ((EAS*nS*p.rho)/(p.K_f*(nS*p.theta + p.rho))^(1/p.m));

%Create the initial concentration in water
fsolveOpt = optimoptions('fsolve','Display','none');

try
  A0(1) = fsolve(targetFun,EAS,fsolveOpt);
catch e
  warning(strcat("Determination of intial states has failed, the error ",...
    "message was: %s\n The workspace has been saved to recreate the ",...
    "conditions"),getReport(e))
  save(dirs.log + "logMDomWDetStart.mat")
  A0(1:end) = 0;
  return
end

%Create the initial concentration in S1
A0(2) = p.K_f*(A0(1)/(p.theta/p.rho))^p.m;

%Create the concentration distribution for the RES
nRES = S{"RES","domains"};
A0(3:2+S{"RES","domains"}) = initDist(nRES,p.factor,RES*nS/nRES);

%Create the initial condition for the degradation products
A0(end-n_deg+1:end) = S.value(end-n_deg+1:end);

end


