function stop = odeTimer( ~, ~, ~,~,~,~ )
%Function to determine the runtime of the an ode-solver and hopefully stop
%it when it exceeds 5 seconds for a single solver run

%Get the global variable startTimeode
global startTimeode %#ok<GVMIS> 
stop = false;

%If the startTime is more than five seconds ago, set stop to true to
%(hopefully) stop the ode-solver
if (startTimeode-now)*86400>5
  stop = true;
  frprintf('Forced ode to stop after 5 seconds')
end