function [modelMeta] = MDomCWNER
% Multi-Domain-Model with separate results for the C_w domain and the inner
% spheres as NER

f = @odeMDomCW;
t = [0,160];

modelMeta.ode = f;

modelMeta.model = "MDomCWNER";

modelMeta.table = "MDomCW";

modelMeta.t = t;

modelMeta.starter = @odeStarter;

modelMeta.loadR = 1;

modelMeta.post = @MDomCWNERPost;

modelMeta.detStart = @MDomCWDetStart;

modelMeta.loadAddParam = 1;

modelMeta.check_massbalance = 1;

end