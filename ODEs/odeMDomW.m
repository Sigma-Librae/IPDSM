function dA = odeMDomW(t,Init,p,S,modelMeta)
arguments
  t %#ok<INUSA> 
  Init (:,1) {mustBeNumeric}
  p (1,:) table
  S table
  modelMeta (1,1) struct
end

%If any value is lower than zero (this might happen with extreme parameters
%during calibratrion)
Init(Init<0)=0;

dA = zeros(length(Init),1);

A = modelMeta.A;

%create the rate constant based on the distance and timesteps
rate = p.D ./ modelMeta.dr.^2.*A(2:end)./A(1);

n = length(dA);

nRES = S{"RES","domains"};

%Water conentration
dA(1) = -p.a*p.rho/p.theta*(p.K_f*Init(1)^p.m-Init(2))-p.k_dis*Init(1);

%S_1
dA(2) = (p.a*(p.K_f*Init(1)^p.m-Init(2)) + rate(1)*(Init(3)-Init(2))-p.k_ner*Init(2))*nRES;

% Calculate all S-domains except the first and the last one (these are
% special cases)
for i = 3:nRES
  dA(i) = (rate(i-2)*(Init(i-1)-Init(i)) + rate(i-1)*(Init(i+1)-Init(i))-p.k_ner*Init(i))*nRES;
end

%S_end
dA(end-2) = (rate(end)*(Init(end-3)-Init(end-2))-p.k_ner*Init(end-2))*nRES;

%DIS
dA(end-1) = Init(1)*p.k_dis;

%NER
dA(end) = mean(Init(2:end-2))*p.k_ner*nRES;

end


