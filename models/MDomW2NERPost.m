function Afinal = MDomW2NERPost(resultsODE,p,S)

arguments
  resultsODE (:,:) {mustBeNumeric}
  p (1,:) table
  S table
end

%Create an empty array for the results
Afinal = NaN(height(resultsODE),4);

%Get the number of S-domains
nS = S{"RES","domains"};

%EAS
Afinal(:,1) = resultsODE(:,1)*p.theta/p.rho;

% Get all shales
Shales = resultsODE(:,2:end-2);

%RES
RES_number = ceil(nS/2);
Afinal(:,2) = sum(Shales(:,1:RES_number)/nS,2);

%DIS
Afinal(:,3) = resultsODE(:,end-1) * p.theta/p.rho;

%NER
Afinal(:,4) = sum(Shales(:,RES_number+1:end)/nS,2);

end