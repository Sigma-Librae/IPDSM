function result = MSC(xdata,xsim,nData,nPar)

arguments
  xdata (:,1) {mustBeNumeric} % Observed data
  xsim  (:,1) {mustBeNumeric} % Simulated data
  nData (1,1)  % Number of datapoints
  nPar (1,1)  % Number of parameters
end

%Calculate the numerator and the denominator for the MSC
numerator = sum((xdata-mean(xdata,'omitnan')).^2,'omitnan');
denominator = sum((xdata-xsim).^2,'omitnan');

% Calculate the MSC
result = log(numerator./denominator)-2*nPar/nData;






