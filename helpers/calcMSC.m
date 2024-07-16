function MSC = calcMSC(p,S,R)
arguments
  p struct
  S double = 1;
  R double = 1;
end

% Calculates the Minimum selective concentration (MSC) with the parameters
% from the BioComp-Model

% if p.beta ~= 0
%   warning("beta is not zero but S and R are not defined, results might be inaccurate")
% end

MSC = p.MIC_s / (p.E_max/(p.alpha+2*p.beta*S*R)-1)^(1/p.H);
end