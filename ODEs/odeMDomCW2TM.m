function dA = odeMDomCW2TM(t,Init,p,S,modelMeta,startTime)
arguments
  t  
  Init (:,1) {mustBeNumeric}
  p (1,:) table
  S table
  modelMeta (1,1) struct
  startTime
end

Init(Init<0) = 0;

n_non_deg = S{"RES","domains"} + S{"EAS","domains"} + S{"NER_shale","domains"};

Init2 = [Init(1:n_non_deg);0;Init(end)];

dA = odeMDomCW(t,Init2,p,S,modelMeta,startTime);

% Complete C_w with the degradation rates from Ac and OH
dA(1) = dA(1) - p.k_tm_OH*Init(1) + p.k_tm_AC * Init(end-1);

%Shift the NER one columns further to make room for the two TM
dA(end+1) = dA(end);% + p.k_ner_OH*Init(end-2);

% Overwrite the former TM with TM-OH
dA(end-2) = + p.k_tm_OH*Init(1);% - p.k_ner_OH*Init(end-2);

% Overwrite the former NER with TM-Ac
dA(end-1) = - p.k_tm_AC * Init(end-1);

%  c = ones(size(dA))/n_non_deg;
%  c([1,end-2:end]) = 1;
% 
%  balance = sum(dA.*c);
% 
%  if abs(balance)>1
%    disp('Mass balance not zero')
%  end

end