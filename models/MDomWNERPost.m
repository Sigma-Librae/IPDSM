function Afinal = MDomWNERPost(resultsODE,p,S)

arguments
  resultsODE (:,:) {mustBeNumeric}
  p (1,:) table
  S table
end

%Create an empty array for the results
Afinal = NaN(height(resultsODE),length(S.domains)-1);

%Get the number of S-domains
nS = S{"RES","domains"} + S{"NER_shale","domains"} + S{"EAS","domains"} - 1;

%EAS
Afinal(:,1) = resultsODE(:,1) + resultsODE(:,2) / nS;

% Create a counter to keep track which shales were already transfered into
% Afinal
n_c = 2;

%RES
Afinal(:,2) = sum(resultsODE(:,(n_c+1):n_c + S{"RES","domains"})/(nS),2);
n_c = n_c + S{"RES","domains"};

%NER_shale
Afinal(:,3) = sum(resultsODE(:,(n_c+1):n_c + S{"NER_shale","domains"})/(nS),2);

%TM
Afinal(:,4) = resultsODE(:,end-1);

%NER
Afinal(:,5) = resultsODE(:,end);

balance = sum(Afinal,2)-mean(sum(Afinal,2));
% 
% if max(abs(balance))>1
%   disp('Postprocessing: mass balance not closed')
% end


end