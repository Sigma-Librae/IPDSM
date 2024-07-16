function dA = odeMDomCW2(t,Init,p,S,modelMeta,startTime)
arguments
  t %#ok<INUSA> 
  Init (:,1) {mustBeNumeric}
  p (1,:) table
  S table
  modelMeta (1,1) struct
  startTime
end

%Create an empty array for the result
dA = NaN(length(Init),1);

%If the start value contain imaginary parts or the maximum time is exceeded, return only NaNs
if not(isreal(Init)) || (now-startTime)*86400>30
  return
end

%If any value is lower than zero, change it to zero 
% (this might happen with extreme parameters during calibration)
Init(Init<0)=0;

% Get the surface areas of the individual spheres
surfaceAreas = modelMeta.A;

%create the rate constant based on the distance and diffusivity
rate = p.d ./ modelMeta.dr.^2.*surfaceAreas(2:end)./surfaceAreas(1);

% Get the number of spheres
n = length(dA);

% Get the number of solid domains (number of RES domains + EAS domain)
nS = S{"RES","domains"};

%Water concentration [mass pollutant/volume water]
dA(1) = -p.a*p.rho/p.theta*(p.K_f*Init(1)^p.m-Init(2))-p.k_dis*Init(1);

%S_1 [mass pollutant/mass soil]
dA(2) = (p.a*(p.K_f*Init(1)^p.m-Init(2))...
        + rate(1)/p.b*Init(3)...
        - rate(1)*Init(2))*nS;

% S_2 [mass pollutant/mass soil]
dA(3) = (- rate(1)/p.b*Init(3)...
        + rate(1)*Init(2)...
        + rate(2)*(Init(4)-Init(3))...
        -p.k_ner*Init(3))*nS;

% Calculate all S-domains except the two first ones and the last one (these are
% special cases) [mass pollutant/mass soil]
for i = 4:n-3
  dA(i) = (rate(i-2)*(Init(i-1)-Init(i))...
         + rate(i-1)*(Init(i+1)-Init(i))...
         - p.k_ner*Init(i))*nS;
end

%S_end [mass pollutant/mass soil]
dA(end-2) = (rate(end-1)*(Init(end-3)-Init(end-2))-p.k_ner*Init(end-2))*nS;

%DIS [mass pollutant/volume water]
dA(end-1) = Init(1)*p.k_dis;

%NER [mass pollutant/mass soil]
dA(end) = sum(Init(3:end-2))*p.k_ner;

% Create an transformation array c to determine the concentration relative to
% the total mass of solids
% c = ones(size(dA))/nS;
% c([1,end-1]) = p.theta/p.rho;
% c(end) = 1;
% 
% % Calculate the mass balance this should be zero
% balance = sum(dA.*c);
% 
% %If the mass balance deviates from zero by more than a certain threshold
% if abs(balance)>1e-3
%   disp('Mass balance not zero')
% end

end


