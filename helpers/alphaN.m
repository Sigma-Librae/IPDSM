function [result] = alphaN(pH,pkAs)
arguments
  pH (:,1) {mustBeNumeric}
  pkAs (:,1) {mustBeNumeric}
end

n = length(pkAs);
result = NaN(n+1,1);

exp_term = 0;
for i = 1:n
    exp_term = exp_term + 10 ^ (i*pH - sum(pkAs(1:i)));
end

result(1) = 1/(1+exp_term);

if n>1
  for k = 1:n+1
    exp_term1 = 0;
    exp_term2 = 0;
    for i = 1:k-1
      exp_term1 =  exp_term1 + 10 ^ sum(pKa(k-1:i)-i*pH);
    end

    for i = 1:n+1-k
      exp_term2 =  exp_term2 + 10 ^ (i*pH - sum(pkAs(k:(i+k-1))));
    end

    result(k) = 1/(1 + exp_term1 + exp_term2);

  end
end