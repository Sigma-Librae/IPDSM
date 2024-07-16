function result = out(f_handle,n)
% function to get the n-th return of a function

switch n
  case 1
    result = f_handle();
  case 2
    [~,result] = f_handle();
  case 3
    [~,~,result] = f_handle();
  case 4
    [~,~,~,result] = f_handle();
  otherwise
    warning("Output not defined properly")
    result = NaN;
end
end