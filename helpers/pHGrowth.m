function result = pHGrowth(pH,pH_min,pH_max,pH_opt)
% Calculates a bacterial growth factor between 0 and 1 depending on
% temperature
arguments
  pH (:,1) {mustBeNumeric}
  pH_min (1,1) {mustBeNumeric}
  pH_max (1,1) {mustBeNumeric}
  pH_opt (1,1) {mustBeNumeric}
end

result = (pH-pH_min).*(pH-pH_max)./((pH-pH_min).*(pH-pH_max)-(pH-pH_opt).^2);

end