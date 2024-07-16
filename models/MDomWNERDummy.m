function [modelMeta] = MDomWNERDummy
% Multi-Domain-Model


f = @odeMDomCW;
t = [0,160];

modelMeta.ode = f;

modelMeta.model = "MDomWNER";

modelMeta.table = "MDomW";

modelMeta.t = t;


end