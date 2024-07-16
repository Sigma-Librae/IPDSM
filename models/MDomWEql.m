function [modelMeta] = MDomWEql
% Multi-Domain-Model


f = @odeMDomCWEql;
t = [0,160];

modelMeta.ode = f;

modelMeta.model = "MDomWEql";

modelMeta.table = "MDomW";

modelMeta.t = t;

modelMeta.starter = @odeStarter;

modelMeta.loadR = 1;

modelMeta.post = @MDomWPost;

modelMeta.detStart = @MDomWDetStart;

modelMeta.loadAddParam = 1;

modelMeta.check_massbalance = 1;

end