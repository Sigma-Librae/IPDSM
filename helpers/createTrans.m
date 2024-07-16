function result = createTrans(transType,shift,scaling)
%Function to create transformation types based on a text input
arguments
  transType (1,:) {mustBeText}
  shift (:,1) {mustBeNumeric}
  scaling (:,1) {mustBeNumeric}
end
%Function to create Transformation type, this is important for
%lognormal distributions

%Reshape the input if it isn't in the right form already
transType = reshape(transType,length(transType),1);

for idx = 1:length(transType)
  %Create transformation objects according to the transformation type
  switch transType(idx)

    % Logarithmic transformation
    case "log"
      transobject.toAbs = @(x)(10.^(x)+shift(idx))*scaling(idx);
      transobject.toNorm = @(x)(log10(x)-shift(idx))/scaling(idx);

    % Negative logarithmic transformation (like the pH value)
    case "p"
      transobject.toAbs = @(x)(10.^-(x)+shift(idx))*scaling(idx);
      transobject.toNorm = @(x)(-log10(x)-shift(idx))/scaling(idx);
      
    % No transformation (default)
    case "d"
      transobject.toAbs = @(x)(x+shift(idx))*scaling(idx);
      transobject.toNorm = @(x)(x-shift(idx))/scaling(idx);
      
    % If the distribution type is not listed
    otherwise
      warning("Transformation type for parameter number %d not recognised, "+...
        "using default transformation instead",idx)
      transobject.toAbs = @(x)(x+shift(idx))*scaling(idx);
      transobject.toNorm = @(x)(x-shift(idx))/scaling(idx);
  end
  result(idx) = transobject; %#ok<*AGROW>
  clear transobject
end
result = reshape(result,length(result),1);