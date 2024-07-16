function scheme = cmap11(n)
arguments
  n (1,1) {mustBeInteger} = 11;
end

fullScheme  =  [0.1216, 0.4667, 0.7059;  % blue
          1.0000, 0.4980, 0.0549;  % orange
          0.1725, 0.6275, 0.1725;  % green
          0.8392, 0.1529, 0.1569;  % red
          0.5804, 0.4039, 0.7412;  % purple
          0.5490, 0.3373, 0.2941;  % brown
          0.8902, 0.4667, 0.7608;  % pink
          0.4980, 0.4980, 0.4980;  % gray
          0.7373, 0.7412, 0.1333;  % yellow-green
          0.0902, 0.7451, 0.8118;  % cyan
          0.9412, 0.8941, 0.2588]; % yellow

% Repeat the color map if the input ask for mor than eleven colors
if n<=11
  scheme = fullScheme(1:n,:);
else
  factor = ceil(n/11);
  ExpandedScheme = repmat(fullScheme,factor,1);
  scheme = ExpandedScheme(1:n,:);
end