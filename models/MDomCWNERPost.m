function Afinal = MDomCWNERPost(resultsODE,p,S)

arguments
  resultsODE (:,:) {mustBeNumeric}
  p (1,:) table
  S table
end

%Create an empty array for the results
Afinal = NaN(height(resultsODE),length(S.domains));

%Get the number of S-domains
nS = S{"RES","domains"} + S{"EAS","domains"} + S{"NER_shale","domains"};

%Cw
Afinal(:,1) = resultsODE(:,1);
%Afinal(:,1) = resultsODE(:,1) + resultsODE(:,2) / nS;

%EAS
Afinal(:,2) = resultsODE(:,2)/nS;
%Afinal(:,2) = 0;
n_c = S{"EAS","domains"} + S{"CW","domains"};

% Get all inner shales (all shales except S_1)
%innerShales = resultsODE(:,3:end-2);

%RES
Afinal(:,3) = sum(resultsODE(:,(n_c+1):n_c + S{"RES","domains"})/(nS),2);
n_c = n_c + S{"RES","domains"};

%NER_shale
Afinal(:,4) = sum(resultsODE(:,(n_c+1):n_c + S{"NER_shale","domains"})/(nS),2);

%TM
Afinal(:,5) = resultsODE(:,end-1);

%NER
Afinal(:,6) = resultsODE(:,end);

% balance = sum(Afinal(:,[1,3:end]),2)-mean(sum(Afinal(:,[1,3:end]),2));
% 
% if max(abs(balance))>1
%   disp('Postprocessing: mass balance not closed')
% end


end