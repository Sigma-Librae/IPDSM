function preBoot(fileName)
% Function to run bootstrapping as a standalone procedure as part of the
% parallelization
arguments
  fileName {mustBeText}
end

%Print feedback
fprintf('%s Starting bootstrapping...\n',datestr(now))

try
  %Load the input file
  load(fileName,'xw','optMaster','optGlob',...
    'optMulti','f','data','S','P','tFull','tObs','dirs','j','modelMeta');

  addpath(dirs.home)
  addpath(dirs.helpers)
  addpath(dirs.boot.main)

  %run bootstrapping
  [w,p] = bootstrapping(optMaster,optGlob,optMulti,f,data,S,...
    P,modelMeta,tFull,tObs,dirs,xw);

  %save the result
  save(sprintf('%sResult_%d.mat',dirs.boot.out,j),'w','p','j');

  %Create an empty file to indicate that the slave is finished
  fclose(fopen(sprintf('%sResult_%d.matDone',dirs.boot.out,j), 'w'));

  fprintf('%s Slave finished successfully\n',datestr(now))
catch e
  warning(e.identifier,'%s bootstrapping was not successful, the error message was:\n\n%s',datestr(now),getReport(e))
  fclose(fopen(sprintf('%sResult_%d.matError',dirs.boot.out,j), 'w'));
end