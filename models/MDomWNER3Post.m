function Afinal = MDomWNER3Post(resultsODE,p,S)

arguments
  resultsODE (:,:) {mustBeNumeric}
  p (1,:) table
  S table
end

%Get the number of all domains that are not degradation domains
n_non_deg = S{"RES","domains"} + S{"EAS","domains"} + S{"NER_shale","domains"};

%Create an array where the results of the ode are in a form as expected by
%MDomWNERPost
resultsODE2 = [resultsODE(:,1:n_non_deg),...
              zeros(height(resultsODE),1),...
              resultsODE(:,end)];

Afinal = MDomWNERPost(resultsODE2,p,S);

% NER
Afinal(:,6) = Afinal(:,5);

% TM-OH 
Afinal(:,4) = resultsODE(:,n_non_deg+1) ;

% TM-Ac
Afinal(:,5) = resultsODE(:,n_non_deg+2);


end