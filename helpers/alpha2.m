function [result] = alpha2(pH,pKas)
arguments
  pH (:,1) {mustBeNumeric}
  pKas (:,1) {mustBeNumeric}
end

%function to calculate the distribution for an acid-base reaction of a
%compund with two pKa's

result = NaN(length(pH),length(pKas));

if length(pKas) == 1
  result(:,1) = 1./(1+10.^(-pKas+pH));
  result(:,2) = 1./(1+10.^(pKas-pH));
end

if length(pKas) == 2

%Acidic fraction
result(:,1) = 1./(1+10.^(pH-pKas(1))+10.^(2*pH-pKas(1)-pKas(2)));

%Neutral fraction
result(:,2) = 1./(1 + 10.^(pKas(1)-pH) + 10.^(pH-pKas(2)));

%Basic fraction
result(:,3) = 1./(1 + 10.^(pKas(1)+pKas(2)-2*pH) + 10.^(pKas(2)-pH));

end