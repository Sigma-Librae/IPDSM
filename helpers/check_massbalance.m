function [result, max_dev] = check_massbalance(Fitted, S, p)
% Function to check whether the mass balance is balanced, returns true if
% this is the case, returns false otherwise
arguments
  Fitted (:,:) {mustBeNumeric}
  S (:,:) table
  p (1,:) table
end

% Create a factor to account for the differnet units of different state
% variables
factor = ones(size(S.domains));

% Change the factor according to the unit
factor(S.units=='water') = p.theta/p.rho;

%Take the sum over all domains, multiplied with factor, the sum should be
%identical over all time points
mass_balance = sum(factor' .* Fitted,2);

deviation = abs(mass_balance-mean(mass_balance));

%Return true if the mass balance is balanced
result =  ~any(deviation>1e-2);

% Get the maximum deviation of the mass balance
max_dev = max(deviation);


