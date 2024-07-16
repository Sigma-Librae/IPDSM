clc
clear
close all

load("../dirs.mat")

addpath(dirs.helpers,dirs.models)

optMaster.model = @MDomWNERDummy;
optMaster.useFirst = false;
loaded.data = 0;

[S,P,modelMeta] = loadParams(optMaster,loaded,dirs);

plotDist(P)