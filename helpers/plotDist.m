function plotDist(P)
%Function to plot probability distributions base on a table with defined
%distribution objects and transformations
arguments
  P table
end

% Get the name of all parameters that will be fitted
namesf = P.Properties.RowNames(P.fitting);

figure
for i = 1:length(namesf)
  
  %Get the transformation of the current parameter
  trans = P{namesf{i},'trans'};

  %Get the respective pdf of the parameter
  pd = P{namesf{i},'dist'};

  %Create the values of the x-Axis and create y-Values based on the pdf
  x = linspace(pd.icdf(5e-3),pd.icdf(1-5e-3),1e3);
  y = pdf(pd,x);

  nexttile()

 

  plot(trans.toAbs(x),y,'b',LineWidth=1.5)
  name = namesf{i};

   % If the transformation type is p or log
   if trans.toNorm(100)==-2 || trans.toNorm(100)==2
     %invert the x values (and effectively the x-Axis)
     set(gca,"XScale",'log')
   end

  %Create correct subscripts for the title
  if any(name=='_')
    pieces = split(name,'_');
    titleName = sprintf('%s_{%s}',pieces{1},pieces{2});
  else
    titleName = namesf{i};
  end

  title(titleName)
  xlabel('Parameter Value','interpreter','latex');
  ylabel('pdf','interpreter', 'latex')
end

% Save the plot into the clipboard
hgexport(gcf,'-clipboard')