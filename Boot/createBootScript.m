function [scriptName] = createBootScript(dirs,j,inFile,pro,runtime,name)
% Create the bash-Script to run the bootstrapping
arguments
  dirs struct
  j (1,1) {mustBeNumeric}
  inFile {mustBeText}
  pro = 1;
  runtime = 12; %runtime in hours
  name = 'Boot';
end

%Define script Name
scriptName = sprintf('%sBoot_%d.sh',dirs.boot.in,j);

%If a file with the intended name already exists, delete it
if exist(scriptName,'file')
  delete(scriptName);
end

%Create the bash file
fid = fopen(scriptName,'w');

%Create the "organizational" part, e.g. runtime, nodes etc.
fprintf(fid,['#!/bin/bash \n',...
  '#PBS -N %s_%d \n',...
  '#PBS -l nodes=1:ppn=%d:geo2 \n',...
  '#PBS -q geo2 \n',...
  '#PBS -l walltime=%d:00:0 \n',...
  '#PBS -e %s%s_%d.err\n',...
  '#PBS -o %s%s_%d.log\n\n',...
  '# go to directory\n',...
  'cd %s\n\n'],...
  name,j,pro,runtime,dirs.logFiles,name,j,dirs.logFiles,name,j,dirs.boot.main);

%Create the execution command for the matlab function
fprintf(fid,['# load matlab\n',...
  'module load math/matlab/R2021a\n',...
  '# run matlab file\n',...
  'matlab -batch "preBoot(''%s'')"\n\n'],...
  inFile);

%Close the file
fclose(fid);