function Afinal = MDomWPost(resultsODE,p,S)

arguments
  resultsODE (:,:) {mustBeNumeric}
  p (1,:) table
  S table
end

%Create an empty array for the results
Afinal = NaN(height(resultsODE),length(S.domains));

%Get the number of S-domains
nS = S{"RES","domains"} + 1;

%EAS
Afinal(:,1) = resultsODE(:,1) + resultsODE(:,2) / nS;
n_c = 2;

%RES
Afinal(:,2) = sum(resultsODE(:,(n_c+1):n_c + S{"RES","domains"}-1)/(nS),2);
n_c = n_c + S{"RES","domains"};

%NER_shale
Afinal(:,3) = sum(resultsODE(:,(n_c+1):n_c + S{"NER_shale","domains"})/(nS),2);

%DIS
Afinal(:,4) = resultsODE(:,end-1);

%NER
Afinal(:,5) = resultsODE(:,end);


end