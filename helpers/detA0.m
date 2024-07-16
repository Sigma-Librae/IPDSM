function [A0] = detA0(S,p)
%Function to determine initial values based on the properties of the state
%Variables and parameters defined in S and P
arguments
  S table
  p (1,:) table
end

%Get the number of state variables
nState = height(S);

%Create an empty array for the result
A0 = NaN(nState,1);

%Get the names of state Variables
stateNames = string(S.Properties.RowNames);

for i = 1:height(S)
  %If the state variable is marked as "dynamic" (is defined by a parameter)
  if S.dynamic(i)
    %If the parameter that should describe the state variable exists
    if ismember(stateNames(i),p.Properties.VariableNames)
      A0(i) = p.(stateNames(i));
    else
      warning('State variable %s is defined as dynamic but not properly defined as a parameter',stateNames(i))
      A0(i) = S.value(i);
    end
  %Use the defined initial value and not a parameter
  else
    A0(i) = S.value(i);
  end
end
end


