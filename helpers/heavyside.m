function result = heavyside(x,y)

if (x>0 || (x==0 && y>0))
    result = 1;
else
    result = 0;
    %fprintf('heavyside is zero at t=%f\n',t)
end
end