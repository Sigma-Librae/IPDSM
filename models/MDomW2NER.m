function [modelMeta] = MDomW2NER
% Multi-Domain-Model

t = [0,160];

modelMeta.ode = @odeMDomCW2;

modelMeta.model = "MDomW2NER";

modelMeta.table = "MDomW";

modelMeta.t = t;

modelMeta.starter = @odeStarter;

modelMeta.loadR = 1;

modelMeta.post = @MDomW2NERPost;

modelMeta.detStart = @MDomW2DetStart;

modelMeta.loadAddParam = 1;

modelMeta.check_massbalance = 1;

end