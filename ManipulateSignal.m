function ManipulateSignal (InfoTS, projectid, Titreglobal, Datemesures, sampling_rate,titleline, nlinestitle )
% This file needs to be documented fully. It does so many things.
global PlotSignal;
global PlotSubsignals;
global CalculateMetrics;
global PrintMetrics;
global PlotMetrics;

ifigure=1;
size_of_font = 18;
Titrexlabelfigsignal = "Temps (s)";
resultfile = ["reportMS" projectid ".tex"];
Nresultfile = ["reportMS" projectid ".tek"]; % tex file is copied to tek file so that git can be instructed to ignore tex files
fout = fopen(resultfile,"w");
printtopresultfile(fout,Titreglobal,Datemesures);
noflocations = size(InfoTS)(1); % Number of locations; must match number of lines of array InfoTS
maxlines = 0;
for iloc = 1:noflocations
   InfoTS{iloc,5} =   Nlinesfile(InfoTS{iloc,2},titleline, nlinestitle);
   if (maxlines < InfoTS{iloc,5})
     maxlines = InfoTS{iloc,5};
     endif;
endfor
dt = 1/sampling_rate;
tvect = 0:dt:(maxlines-1)*dt;
tvect = tvect';

% Main loop on the number of locations or number of lines of InfoTS
for iloc = 1:noflocations
   % Loop on direction
   TitleSection = [InfoTS{iloc,1}];
   fprintf(fout,"\\section{%s}\n",TitleSection);
   fprintf(fout,"\\begin{frame}{%s}\n",TitleSection);
     fprintf(fout,"\\begin{itemize}\n")
     fprintf(fout,"\\item Read from file: %s\n",strrep(InfoTS{iloc,2}, "_", "\\_"));
     fprintf(fout,"\\item Number of points: %d\n",InfoTS{iloc,5})
     fprintf(fout,"\\item Elapsed time: %10.3f \$\\rm\{s}\$\n",tvect(InfoTS{iloc,5}))
     fprintf(fout,"\\item Measured quantity: %s\n",InfoTS{iloc,3})
     fprintf(fout,"\\item Units: %s\n",InfoTS{iloc,4})
     fprintf(fout,"\\end{itemize}\n")
   fprintf(fout,"\\end{frame}\n");

   for idir=1:3
    icol = 0;
    if ((idir == 1) && (InfoTS{iloc,7} == 1))
      icol = 6;
      TitleSubSection = ["XDir"];
    elseif ((idir == 2) && (InfoTS{iloc,11} == 1))
      icol = 10;
      TitleSubSection = ["YDir"];
    elseif ((idir == 3) && (InfoTS{iloc,15} == 1))
      icol = 14;
      TitleSubSection = ["ZDir"];
    endif
   if (icol != 0) % if icol is not 0, then direction must be processed
      fprintf(fout,"\\subsection{%s}\n",TitleSubSection);
      fprintf(fout,"\\begin{frame}\n");
      fprintf(fout,"\\centering{%s}\n\n",TitleSubSection);
      if (InfoTS{iloc,icol+2}  == 1)
        fprintf(fout,"\\centering{Calculating the derivative of the signal}\n\n")
      elseif (InfoTS{iloc,icol+2}  == 2)
        fprintf(fout,"\\centering{Integrating the signal}\n\n")
      else
        fprintf(fout,"\\centering{Unknown option}\n\n")
      endif
      fprintf(fout,"\\end{frame}\n");
      % Read signal from file
      signal = readsignal(InfoTS{iloc,2},titleline,nlinestitle,InfoTS{iloc,5},InfoTS{iloc,icol});
%     Various numbers required later in the code
      nptssignal = InfoTS{iloc,5};
      ManipSignal = zeros(nptssignal,1);
      if (InfoTS{iloc,icol+2}  == 1)
        % Calculating the derivative
        ManipSignal = gradient(signal, dt);
      elseif (InfoTS{iloc,icol+2}  == 2)
        % Integrating the signal
        ManipSignal = cumtrapz(signal)*dt;
      else
        fprintf(fout,"\\centering{Unknown option}\n\n")
        return;
      endif
      initial_metrics_subplots = 250;
      if ((PrintMetrics != 0) || (PlotMetrics != 0))
        nsubsignalsmetrics = floor(nptssignal/initial_metrics_subplots);
        if (nsubsignalsmetrics == 0)
          nsubsignalsmetrics = 1;
        elseif (nsubsignalsmetrics > 25)
          nsubsignalsmetrics = 25;
        endif
        nptsmetrics = floor(nptssignal/nsubsignalsmetrics);
      endif % if ((PrintMetrics != 0) || (PlotMetrics != 0))
      if (PlotSubsignals != 0)
        nsubplots = 4;
        nptssubplot = nptssignal/nsubplots;
        if (nptssubplot > initial_metrics_subplots)
          nptssubplot = initial_metrics_subplots;
        endif
        rowsubplots = nsubplots/2;
        columnsubplots = nsubplots/rowsubplots;
        nptspersubfig = floor(nptssignal/nsubplots);
        if (nptspersubfig > nptssubplot)
          nptspersubfig = nptssubplot;
        endif
      endif % if (PlotSubsignals != 0)
      Tsignal = nptssignal/sampling_rate;


      Titrey   = [ " (" InfoTS{iloc,4} ")"];
      TitreyMS = [ " (" InfoTS{iloc,icol+3} ")"];
%
      if (PlotSignal != 0)
        hf = figure(ifigure);
        plot(tvect(1:nptssignal),signal(1:nptssignal),"linewidth",1,"color","k");
        xlabel(Titrexlabelfigsignal,'FontSize',size_of_font);
        ylabel(Titrey,'FontSize',size_of_font);
        grid "on";
        filename = [InfoTS{iloc,1} TitleSubSection "signal.tex"];
        print(filename,'-dpdflatex');
        filenamesvg = [InfoTS{iloc,1} TitleSubSection "signal.svg"];
        print(filenamesvg);
        fprintf(fout,"\\begin{frame}{Entire signal (%d points)}\n",nptssignal);
           fprintf(fout,"\\begin\{figure\}[H]\n");
           fprintf(fout,"\\centering\n");
           fprintf(fout,"\\scalebox\{0.45\}\{\\input\{%s\}\}\n",filename);
           fprintf(fout,"\\end\{figure\}\n");
        fprintf(fout,"\\end{frame}\n");
        ifigure++;
        % Manipulated signal
        hf = figure(ifigure);
        plot(tvect(1:nptssignal),ManipSignal(1:nptssignal),"linewidth",1,"color","k");
        xlabel(Titrexlabelfigsignal,'FontSize',size_of_font);
        ylabel(TitreyMS,'FontSize',size_of_font);
        grid "on";
        filename = [InfoTS{iloc,1} TitleSubSection "Msignal.tex"];
        print(filename,'-dpdflatex');
        filenamesvg = [InfoTS{iloc,1} TitleSubSection "Msignal.svg"];
        print(filenamesvg);
        fprintf(fout,"\\begin{frame}{Manipulated signal (%d points)}\n",nptssignal);
           fprintf(fout,"\\begin\{figure\}[H]\n");
           fprintf(fout,"\\centering\n");
           fprintf(fout,"\\scalebox\{0.45\}\{\\input\{%s\}\}\n",filename);
           fprintf(fout,"\\end\{figure\}\n");
        fprintf(fout,"\\end{frame}\n");
        ifigure++;
      endif
    %
    if (PlotSubsignals != 0)
      istart    = zeros(nsubplots,1);
      iend      = zeros(nsubplots,1);
      onethird  = floor(nptssignal/3); % 1/3 works because we divide the signal in four subsignals; we need to be careful for istart(2) not to become smaller than 1.
      twothirds = 2*onethird;
      istart(1) = 1;
      iend(1)   = nptspersubfig;
      istart(2) = onethird  - nptspersubfig/2;
      iend(2)   = onethird  + nptspersubfig/2 - 1;
      istart(3) = twothirds - nptspersubfig/2;
      iend(3)   = twothirds + nptspersubfig/2 - 1;
      istart(4) = nptssignal - nptspersubfig + 1;
      iend(4)   = nptssignal;
        figure(ifigure)
        YrangeMin = min(signal(istart(1):iend(1)));
        YrangeMax = max(signal(istart(1):iend(1)));
         for i = 2:nsubplots
           tempmin = min(signal(istart(i):iend(i)));
           if (tempmin < YrangeMin)
            YrangeMin = tempmin;
          endif
          tempmax = max(signal(istart(i):iend(i)));
          if (tempmax > YrangeMax)
            YrangeMax = tempmax;
            endif
         endfor
         Xrange = 1.1*(tvect(iend(1)) - tvect(istart(1))); % increase timespan by 10%
        for i = 1:nsubplots
           subplot(rowsubplots,columnsubplots,i);
           plot(tvect(istart(i):iend(i)),signal(istart(i):iend(i)),"linewidth",1,"color","k");
           ylim([YrangeMin YrangeMax]);                       % Set y-axis range
           xlim([tvect(istart(i)) tvect(istart(i))+Xrange]);  % Set x-axis range
           grid "on";
           xlabel(Titrexlabelfigsignal,'FontSize',size_of_font);
           ylabel(Titrey,'FontSize',size_of_font);
        endfor
        ifigure++;
        filename = [InfoTS{iloc,1} TitleSubSection "subsignals.tex"];
        print(filename,'-dtex');
        fprintf(fout,"\\begin{frame}{%d intervals of %d points each (%6.3f \$\\rm\{s}\$)}\n",nsubplots, nptspersubfig,(nptspersubfig-1)/sampling_rate);
           fprintf(fout,"\\begin\{figure\}[H]\n");
           fprintf(fout,"\\centering\n");
           fprintf(fout,"\\scalebox\{0.6\}\{\\input\{%s\}\}\n",filename);
           fprintf(fout,"\\end\{figure\}\n");
        fprintf(fout,"\\end{frame}\n");
      endif % if (PlotSubsignals != 0)
% Metrics
      if (CalculateMetrics != 0)
        metricssignal = zeros(nsubsignalsmetrics+1,4);
        for i = 1:nsubsignalsmetrics
          subsignal = zeros(nptsmetrics,1);
          subsignal = signal((i-1)*nptsmetrics+1:i*nptsmetrics);
          %      Average             Max                  Min               RMS
           [metricssignal(i,1), metricssignal(i,2), metricssignal(i,3), metricssignal(i,4)] = ...
           metrics_signal(subsignal,0,0);
        endfor
        metricssignal(nsubsignalsmetrics+1,1) = mean(metricssignal(1:nsubsignalsmetrics,1));
        metricssignal(nsubsignalsmetrics+1,2) = mean(metricssignal(1:nsubsignalsmetrics,2));
        metricssignal(nsubsignalsmetrics+1,3) = mean(metricssignal(1:nsubsignalsmetrics,3));
        metricssignal(nsubsignalsmetrics+1,4) = mean(metricssignal(1:nsubsignalsmetrics,4));
      endif
      if (PlotMetrics != 0)
           hf = figure(ifigure);
           plot(metricssignal(1:nsubsignalsmetrics,1),'bo', metricssignal(1:nsubsignalsmetrics,2),'g*', ...
           metricssignal(1:nsubsignalsmetrics,3),'ks',metricssignal(1:nsubsignalsmetrics,4),'ro');
           xlabel("Sample",'FontSize',size_of_font);
           ylabel(Titrey,'FontSize',size_of_font);
           set(gca, 'xtick', 1:1:nsubsignalsmetrics);
           grid "on";
           legend("Average","Max","Min","RMS","location", "northeastoutside");
           filename = [InfoTS{iloc,1} TitleSubSection "metrics.tex"];
           print(filename,'-dtex');
        fprintf(fout,"\\begin{frame}{Metrics - %d subsignals of %d points}\n",nsubsignalsmetrics,nptsmetrics );
           fprintf(fout,"\\begin\{figure\}[H]\n");
           fprintf(fout,"\\centering\n");
           fprintf(fout,"\\scalebox\{0.5\}\{\\input\{%s\}\}\n",filename);
           fprintf(fout,"\\end\{figure\}\n");
         fprintf(fout,"\\end{frame}\n");
           ifigure++;
      endif % if (PlotMetrics != 0)
      if (PrintMetrics != 0)
        fprintf(fout,"\\begin{frame}{Metrics - %d subsignals of %d points}\n",nsubsignalsmetrics,nptsmetrics );
           fprintf(fout,"\\begin\{table}\n");
           fprintf(fout,"\\begin\{tabular}{|l | l | l | l | l |}\n");
           fprintf(fout,"\\hline\n");
           fprintf(fout," & Average & Max & Min & RMS \\\\ \n");
           fprintf(fout,"\\hline\n");
           fprintf(fout,"\\hline\n");
           fprintf(fout,"%s & %10.3e & %10.3e & %10.3e & %10.3e \\\\ \n","Ave", metricssignal(nsubsignalsmetrics+1,1), metricssignal(nsubsignalsmetrics+1,2), ...
               metricssignal(nsubsignalsmetrics+1,3),metricssignal(nsubsignalsmetrics+1,4));
           fprintf(fout,"\\hline\n");
           fprintf(fout,"\\end\{tabular}\n");
           fprintf(fout,"\\end\{table}\n");
        fprintf(fout,"\\end{frame}\n");
      endif % if (PrintMetrics != 0)
     endif % Processing X, Y or Z column of data
   endfor % Number of directions
endfor % Number of locations
fprintf(fout,"\\end{document}\n");
fclose(fout);
copyfile(resultfile,Nresultfile);
endfunction
