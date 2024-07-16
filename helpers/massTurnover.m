function result = massTurnover(t,Init,p,S,modelMeta,startTime)
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

%If any value is lower than zero, change it to zero 
% (this might happen with extreme parameters during calibration)
Init(Init<0)=0;

% Get the surface areas of the individual spheres
surfaceAreas = modelMeta.A;

%create the rate constant based on the distance and diffusivity
rates = p.d ./ modelMeta.dr.^2.*surfaceAreas(2:end)./surfaceAreas(1);

% Get the number of spheres
n = length(dA);

% Get the number of solid domains (number of RES domains + EAS domain)
%nS = modelMeta.nS;

sorptionTurnover = abs(p.a*(p.K_f*(Init(1)/(p.theta/p.rho))^p.m-Init(2)));
TMTurnover = p.k_tm*Init(1);
DiffTurnover =  abs(+ rates(1)/p.b*Init(3) - rates(1)*Init(2))... %S_1 <-> S_2
               +abs( + rates(2)*(Init(4)-Init(3)));  %S_2 <-> S_3

for idx = 4:n-3
  DiffTurnover = DiffTurnover + abs(rates(idx-1)*(Init(idx+1)-Init(idx))); % interaction  with next inner shale
end

result = [sorptionTurnover, TMTurnover, DiffTurnover];


end


