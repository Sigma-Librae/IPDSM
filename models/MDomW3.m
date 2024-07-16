function [modelMeta] = MDomW3
% Multi-Domain-Model


t = [0,160];

modelMeta.ode = @odeMDomCW2DIS;

modelMeta.model = "MDomWNER3";

modelMeta.table = "MDomW3";

modelMeta.t = t;

modelMeta.starter = @odeStarter;

modelMeta.loadR = 1;

modelMeta.post = @MDomW3Post;

modelMeta.detStart = @MDomWDetStart;

modelMeta.loadAddParam = 1;

modelMeta.check_massbalance = 1;

end