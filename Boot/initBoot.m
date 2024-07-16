function [result,weights,p] = initBoot(optMaster,optGlob,optMulti,optSur,data,S,P,modelMeta,tFull,tObs,dirs)
% Function to initialize bootstrapping either in order or in parallel,
% depending on the options
arguments
  optMaster struct %Option structure for the model
  optGlob struct   %Option structure for global calibration
  optMulti struct  %Option structure for  MultiStart calibration
  optSur struct
  data (:,1) cell
  S table
  P table
  modelMeta struct
  tFull (1,:) {mustBeNumeric}
  tObs (1,:) cell
  dirs struct
end

%save the table so the result is not lost in case something goes wrong
save(dirs.log + "logBootPar.mat")

try

%% Create a cell array of weights
%Create an empty array for the weights
weights = cell(optMaster.boot.n,1);

nPar = height(P);

for i = 1:optMaster.boot.n
  %Create an empty array inside the weights
  weights{i} = cell(length(data),1);

  for j = 1:length(data)
    if S.meas(j)
      xdata = data{j};

      %Sample a vector of indexes (with replacement)
      sample = datasample(1:length(xdata),length(xdata));

      %Count the number of elements and create the weight vector based on the
      %number of occurences of an index
      weights{i}{j} = countElements(sample);
    end
  end
end

%% Do the bootstrapping either in parallel or normally
if optMaster.boot.doParallel
  %Determine the number of samples per slave
  nSamples = ceil(optMaster.boot.n/optMaster.boot.nParallel);

  %Create an array with all directories necessary for the parallel
  %bootstrapping
  directories = [dirs.boot.in,dirs.boot.out];

  % Create the directores if they don't exist, clear them if they do
  for i = 1:length(directories)
    if exist(directories(i),'file')
      delete(directories(i) + "*");
    else
      mkdir(directories(i))
    end
  end

  %Clear the input and output directory
  delete(sprintf('%s*',dirs.boot.out));
  delete(sprintf('%s*',dirs.boot.in));

  %Create a table to keep track the slaves
  sz = [optMaster.boot.nParallel, 2];
  varTypes = ["string","categorical"];
  varNames = ["name","status"];
  track = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

  fprintf('%s Starting parallel slaves...\n',datestr(now))
  for j = 1:optMaster.boot.nParallel

    if j ~= optMaster.boot.nParallel
      xw = weights((j-1)*nSamples+1:j*nSamples);
    else
      xw = weights((j-1)*nSamples+1:end);
    end
    inFile = sprintf('%sBoot_in_%d.mat',dirs.boot.in,j);

    %Save the input for the next slave
    save(inFile,'xw','optMaster','optGlob',...
      'optMulti','optSur','data','S','P','tFull','tObs','dirs','j','modelMeta');

    %Delete xw from the workspace to ensure it is created correctly in the
    %next iteration
    clear xw

    %Get the name of the script that initiates the next slave
    scriptName = createBootScript(dirs,j,inFile,optMaster.boot.nPro,optMaster.boot.runtime);

    %Execute the script
    [~] = system(sprintf('qsub -q geo2 %s',scriptName));

    track{j,"status"} = "running";
    track{j,"name"} = sprintf("Result_%d",j);
  end
  tic

  runLoop = true;
  counterCommand = 1;

  while any(track.status=="running") && toc<=optMaster.boot.runtime*60*60 && runLoop
    pause(30)
    fprintf('%s %d slaves are considered running\n',datestr(now),sum(track.status=="running"))

    %get the filesnames of all finished slaves
    resultFiles = dir(fullfile(dirs.boot.out,'*.matDone'));

    %Create a string from the struct
    resultFiles = string({resultFiles.name})';

    % if there are no result files, we can skip this
    if isempty(resultFiles)
      continue
    end
    %Delete the "file type"
    toImport = erase(resultFiles,".matDone");

    % Loop over all result files that should be imported
    for k = 1:length(toImport)
      %Load the result
      l = load(dirs.boot.out + toImport(k) + ".mat","w","p","j");

      %Add the result to the table
      track{l.j,"content"} = {l.p};
      track{l.j,"weights"} = {l.w};
      track{l.j,"status"} = "finished";

      clear l

      %Delete result files
      delete(dirs.boot.out + toImport(k) + ".mat")
      delete(dirs.boot.out + toImport(k) + ".matDone")
    end

    %save the table so the result is not lost in case something goes wrong
    save(dirs.log + "logBootPar.mat")

    %Execute a runtime command if there is one
    if exist('runTimeCommands.txt','file')
      try
        command = (textread('runTimeCommands.txt','%c')); %#ok<DTXTRD> 
        try
          eval(command)
          feedback = sprintf(['%s runTimeCommand %d executed successfully, ',...
            'the following command(s) were executed\n%s\n'],...
            datestr(now),counterCommand,command);
        catch me
          feedback = sprintf(['%s runTimeCommand %d not successful, ',...
            'the following commands caused an error\n%s\n\n The error message was:\n%s\n']...
            ,datestr(now),counterCommand,command,getReport( me, 'extended', 'hyperlinks', 'on' ));
        end


        counterCommand = counterCommand + 1;
        delete('runTimeCommands.txt');
      catch me
        feedback = getReport( me, 'extended', 'hyperlinks', 'on' );
      end
      %Print the feedback to the terminal
      fprintf(1,feedback);

      %Print the feedback to a logfile
      fid = fopen(sprintf('logRunTimeCommand%d',counterCommand),'w');
      fprintf(fid,feedback);
      fclose(fid);
    end
  end

  %Merge the results from the individual slaves
  idxFinished = find(track.status=="finished");
  p = array2table(NaN(optMaster.boot.n,nPar));
  p.Properties.VariableNames = P.Properties.RowNames;
  weights = cell(optMaster.boot.n,1);

  nPerSlave = optMaster.boot.n/optMaster.boot.nParallel;

  for o = reshape(idxFinished,1,[])
    %xp = track.content(o);
    xp = track{o,"content"}{1};
    p((o-1)*nPerSlave+1:o*nPerSlave,:) = xp;

    xw = track{o,"weights"}{1};
    weights((o-1)*nPerSlave+1:o*nPerSlave) = xw;
  end
  result = finishBoot(optMaster,P,p);

  save(dirs.log + "logInitBoot.mat")

else
  % Do regular bootstrapping without parallelization
  [weights,p] = bootstrapping(optMaster,optGlob,optMulti,optSur,data,S,...
    P,modelMeta,tFull,tObs,dirs,weights);
  result = finishBoot(optMaster,P,p);
end

catch e
  save(dirs.log + "bootCrashWorkspace")
  warning("Bootstrapping encountered an unexpected error, the error message was: \n%s",getReport(e))
  result = NaN;
  weights = NaN;
  p = NaN;
end

