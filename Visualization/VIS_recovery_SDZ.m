clc
clear
close all

% Load all directories and add them to the path
load("../dirs.mat")
addpath(dirs.helpers,dirs.odes,dirs.models)

pathData = "C:\Users\Matthias\OneDrive\Desktop\BioModel\Code\data\SDZ_water_low.csv";

data = readmatrix(pathData);
c_SDZ = data(:,2)*2;
tData = data(:,1)*24; % [h]

c_SDZ = c_SDZ(isfinite(c_SDZ));
tData = tData(isfinite(tData));

% Timepoint at which the ABX-concentration is reduced
tTurn = 300;

% Read the table with parameters
P = readtable(dirs.params + "BioComp_Params.csv",ReadRowNames=true);

% Create a struct from the table
for idx = 1:height(P)
  p.(P.Properties.RowNames{idx}) = P{idx,1};
end

% Create the time vector
t = linspace(0,900,5e2)';
%EASData = ones(size(t))*p.EAS;
%EASData(t>tTurn) = 0;

% Create a 
EASData = (1-cdf('normal',t,tTurn,20))*p.EAS;

%EASData = [ones(10,1);zeros(90,1)]*p.EAS;
tic
p.EAS = fitrgp(tData,c_SDZ);
toc

plot(tData,predict(p.EAS,tData))
figure

%EASData
modelMeta = BioComp();
A0 = [1,1,0,0];

fun = @(t,A)odeBioComp(t,A,p,0,modelMeta,0);
tic
[~,A] = ode45(fun,t,A0);
toc

%Growth correction for antibiotics for susceptibles
E_s = 1 - p.E_max ./ ((p.MIC_s./(EASData./p.V_aq)).^p.H+1);

%Growth correction for antibiotics for resistants
E_r = 1 - p.E_max ./ ((p.MIC_r./(EASData./p.V_aq)).^p.H+1);

tThresholdEs = t(E_s>(1-p.alpha));

[valueMSC,idxMSC] = min(abs(predict(p.EAS,t)-calcMSC(p)));

colors = get(gca,'colororder');

nexttile()
plot(t/24,A(:,1),LineWidth=1.5)
hold on
plot(t/24,A(:,2),LineWidth=1.5)
xline(t(idxMSC)/24)
legend(["Susceptibles (S)", "Resistants (R)"],Location="best",FontSize=9)
xlabel("t [d]")
ylabel("C_B [\mug/l]")

nexttile()
plot(tData/24,c_SDZ,'x',LineWidth=1.5,Color=colors(4,:))
hold on
plot(tData/24,predict(p.EAS,tData),LineWidth=1.5,Color=colors(4,:))
xlabel("t [d]")
ylabel("C_{ABX} [\mug/l]")
xlim([-inf,max(t/24)])
yline(calcMSC(p))
text(25,calcMSC(p)+0.1,"MSC")

% Save the plot into the clipboard
hgexport(gcf,'-clipboard')





