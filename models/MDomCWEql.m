function [modelMeta] = MDomCWEql
% Multi-Domain-Model with separate results for the C_w domain


f = @odeMDomCWEql;
t = [0,160];

modelMeta.ode = f;

modelMeta.model = "MDomCWEql";

modelMeta.table = "MDomCW";

modelMeta.t = t;

modelMeta.starter = @odeStarter;

modelMeta.loadR = 1;

modelMeta.post = @MDomCWPost;

modelMeta.detStart = @MDomCWDetStart;

modelMeta.loadAddParam = 1;

modelMeta.check_massbalance = 1;

end