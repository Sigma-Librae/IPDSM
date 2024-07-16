function [modelMeta] = MDomWNER
% Multi-Domain-Model


f = @odeMDomCW;
t = [0,160];

modelMeta.ode = f;

modelMeta.model = "MDomWNER";

modelMeta.table = "MDomW";

modelMeta.t = t;

modelMeta.starter = @odeStarter;

modelMeta.loadR = 1;

modelMeta.post = @MDomWNERPost;

modelMeta.detStart = @MDomWDetStart;

modelMeta.loadAddParam = 1;

modelMeta.check_massbalance = 1;

end