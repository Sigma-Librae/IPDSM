function Afinal = MDomCWPost(A,p,S)

arguments
  A (:,:) {mustBeNumeric}
  p (1,:) table
  S table
end

%Create an empty array for the results
Afinal = NaN(height(A),5);

%Get the number of S-domains
nS = S{"RES","domains"} + S{"EAS","domains"};

%Cw
Afinal(:,1) = A(:,1);

%EAS
Afinal(:,2) = A(:,2)/nS;

%RES
Afinal(:,3) = sum(A(:,3:end-2)/nS,2);

%DIS
Afinal(:,4) = A(:,end-1) * p.theta/p.rho;

%NER
Afinal(:,5) = A(:,end);
end