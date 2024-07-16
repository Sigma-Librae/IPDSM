function dist = makeMyDist(name, maxVals, variance, trans)
%Function to create probability distributions
arguments
  name (:,1) {mustBeText} % name of the distribution type
  maxVals (:,1) {mustBeNumeric} % maximum of the distribution function
  variance (:,1) {mustBeNumeric} % "Variance" is not very accurate here, it more or less describes the width of the pdf
  trans (:,1) struct
end

% Number of desired distributions
n = length(maxVals);

% Empty array for pdfs
%dist = cell(n,1);

for i = 1:n
  maxVal = trans(i).toNorm(maxVals(i));
  try
  % Decide which distributions are chosen
  if lower(name(i)) == "beta"
    if maxVals(i)<=0 || maxVals(i)>=1
      warning('For the Beta distribution, the maxValue must be within (0,1)')
      return
    end
    % create the distribution object, a is transformed to always represent
    % the maximum of the distribution
    dist(i) = makedist(name(i),'a',((maxVal*(variance(i)-2)+1)/(1-maxVal)),'b',variance(i)); %#ok<*AGROW> 
  elseif lower(name(i)) == "gamma"
    dist(i) = makedist(name(i),'a',(maxVal/variance(i)+1),'b',variance(i));
  elseif lower(name(i)) == "normal"
    dist(i) = makedist(name(i),'mu',maxVal,'sigma',variance(i));
  else
    error('Distribution name not found')
  end
  catch e
    warning("The function 'makeMyDist' caused an error at loop counter "+ num2str(i) +", the error message was: \n\n" + getReport(e))
  end
end
dist = reshape(dist,length(dist),1);

end