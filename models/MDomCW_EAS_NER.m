function [modelMeta] = MDomCW_EAS_NER
% Multi-Domain-Model with separate results for the C_w domain


f = @odeMDomCW_EAS_NER;
t = [0,160];

modelMeta.ode = f;

modelMeta.model = "MDomCW_EAS_NER";

modelMeta.table = "MDomCW";

modelMeta.t = t;

modelMeta.starter = @odeStarter;

modelMeta.loadR = 1;

modelMeta.post = @MDomCWPost;

modelMeta.detStart = @MDomCWDetStart;

modelMeta.loadAddParam = 1;

modelMeta.check_massbalance = 1;

end