function result = RMSE(sim,obs,weights)

% Function to determine the RMSE with optional weights

arguments
  sim (:,1) {mustBeNumeric}
  obs (:,1) {mustBeNumeric}
  weights (:,1) {mustBeNumeric} = ones(length(sim),1)
end
try
  % If any element of oby contains NaN, delete those elements from all
  % inputs
  if any(isnan(obs))
    sim = sim(not(isnan(obs)));
    weights = weights(not(isnan(obs)));
    obs = obs(not(isnan(obs)));
  end

  % If any element of oby contains NaN, delete those elements from all
  % inputs
  if any(isnan(sim))
    obs = obs(not(isnan(sim)));
    weights = weights(not(isnan(sim)));
    sim = sim(not(isnan(sim)));
  end

  % Calculate RMSE
  result = sqrt(sum((sim-obs).^2.*weights)/sum(weights));
catch e
  warning("The function RMSE encountered an error, the error message was \n %s", ...
    getReport(e))
  result = NaN;
end

end