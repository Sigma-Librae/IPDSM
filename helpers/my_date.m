function result = my_date(usedDate)
% Return a string with the current date based on the ISO date format. 
% I. e. 23_0102_ for the date 2023-01-02
arguments
  usedDate = now % Date that is used for the result
end

% Add a "0" prefix if the day is lower than 10 to have a constant number of
% digits
if day(usedDate) < 10
  stringDay = "0" + day(usedDate);
else
  stringDay = string(day(usedDate));
end

% Add a "0" prefix if the month is lower than 10 to have a constant number of
% digits
if month(usedDate) <10
  stringMonth = "0" + month(usedDate);
else
  stringMonth = string(month(usedDate));
end

result = sprintf("%d_%s%s_",year(usedDate)-2000,stringMonth,stringDay);
end