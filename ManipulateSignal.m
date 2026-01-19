function ManipulateSignal (InfoTS, filterspecs, projectid, Titreglobal, Datemesures, sampling_rate,titleline, nlinestitle )
% This file needs to be documented fully. It does so many things.
global PlotSignal;
global PlotSubsignals;
global CalculateMetrics;
global PrintMetrics;
global PlotMetrics;
global VISIBLE;

if ( (PrintMetrics == 1) || (PlotMetrics == 1))
  CalculateMetrics = 1;
  endif

ifigure=1;
size_of_font = 18;
Titrexlabelfigsignal = "Temps (s)";
resultfile = ["reportMS" projectid ".tex"];
Nresultfile = ["reportMS" projectid ".tek"]; % tex file is copied to tek file so that git can be instructed to ignore tex files
fout = fopen(resultfile,"w");
printtopresultfile(fout,Titreglobal,Datemesures);
noflocations = size(InfoTS)(1); % Number of locations; must match number of lines of array InfoTS
dt = 1/sampling_rate;

% Main loop on the number of locations or number of lines of InfoTS
for iloc = 1:noflocations
   % Loop on direction
   TitleSection = [InfoTS{iloc,1}];
   fprintf(fout,"\\section{%s}\n",TitleSection);
   fprintf(fout,"\\begin{frame}{%s}\n",TitleSection);
     fprintf(fout,"\\begin{itemize}\n")
     fprintf(fout,"\\item Read from file: %s\n",strrep(InfoTS{iloc,2}, "_", "\\_"));
     fprintf(fout,"\\item Measured quantity: %s\n",InfoTS{iloc,3})
     fprintf(fout,"\\item Units: %s\n",InfoTS{iloc,4})
      if (InfoTS{iloc,8}  != 0)
        fprintf(fout,"\\item Filtering: %d\n\n",InfoTS{iloc,8})
        fprintf(fout,"\\begin{itemize}\n")
        if (InfoTS{iloc,8}  == 2)
            fprintf(fout,"\\item Butterworth\n\n")
        endif
        fprintf(fout,"\\item Order: %d\n\n",filterspecs{InfoTS{iloc,8},2})
        fprintf(fout,"\\item Type       : %s\n\n",filterspecs{InfoTS{iloc,8},3})
        if (filterspecs{InfoTS{iloc,8},3}  == "low ")
           fprintf(fout,"\\item Cutoff  : %8.1f Hz\n",filterspecs{InfoTS{iloc,8},4})
           fprintf(fout,"\\end{itemize}\n")
        elseif (filterspecs{InfoTS{iloc,8},3}  == "high")
           fprintf(fout,"\\item Cutoff  : %8.1f Hz\n",filterspecs{InfoTS{iloc,8},4})
           fprintf(fout,"\\end{itemize}\n")
        elseif (filterspecs{InfoTS{iloc,8},3}  == "band")
           fprintf(fout,"\\item Cutoff low  : %8.1f Hz\n",filterspecs{InfoTS{iloc,8},4})
           fprintf(fout,"\\item high : %8.1f Hz\n",filterspecs{InfoTS{iloc,8},5})
           fprintf(fout,"\\end{itemize}\n")
        endif
      else
        fprintf(fout,"\\item No filtering applied\n")
      endif
     fprintf(fout,"\\end{itemize}\n")
   fprintf(fout,"\\end{frame}\n");

   for idir=1:3
    icol = 0;
    if ((idir == 1) && (InfoTS{iloc,10} == 1))
      icol = 9;
      TitleSubSection = ["XDir"];
    elseif ((idir == 2) && (InfoTS{iloc,14} == 1))
      icol = 13;
      TitleSubSection = ["YDir"];
    elseif ((idir == 3) && (InfoTS{iloc,18} == 1))
      icol = 17;
      TitleSubSection = ["ZDir"];
    endif
   if (icol != 0) % if icol is not 0, then direction must be processed
      signal = readsignal(InfoTS{iloc,2},titleline,nlinestitle,InfoTS{iloc,icol});
      nptssignal       = length(signal);
      InfoTS{iloc,5}  = nptssignal;
      tvect = 0:dt:(nptssignal-1)*dt;
      tvect = tvect';
      T = nptssignal/sampling_rate;
      ManipSignal = zeros(nptssignal,3);
      fprintf(fout,"\\subsection{%s}\n",TitleSubSection);
      fprintf(fout,"\\begin{frame}\n");
      fprintf(fout,"\\centering{%s}\n\n",TitleSubSection);
      fprintf(fout,"Number of points: %d\n\n",InfoTS{iloc,5})
      fprintf(fout,"Elapsed time: %10.3f \$\\rm\{s}\$\n\n",T)
      if (InfoTS{iloc,icol+2}  == 0)
         if (InfoTS{iloc,8}  != 0)
           fprintf(fout,"\\centering{Original signal unchanged, but filtered. Calculating its metrics.}\n\n")
         else
           fprintf(fout,"\\centering{Original signal unchanged. Calculating its metrics.}\n\n")
           endif
      elseif (InfoTS{iloc,icol+2}  == 1)
        fprintf(fout,"\\centering{Calculating the derivative of the signal}\n\n")
      elseif (InfoTS{iloc,icol+2}  == 2)
        fprintf(fout,"\\centering{Integrating the signal}\n\n")
      else
        fprintf(fout,"\\centering{Unknown option}\n\n")
      endif
      fprintf(fout,"\\end{frame}\n");
      % Read signal from file
      signal = readsignal(InfoTS{iloc,2},titleline,nlinestitle,InfoTS{iloc,icol});
      % Scale signal
      signal = signal.*InfoTS{iloc,7};
      % Always remove mean of signal before doing anything.
      signal = signal - mean(signal);
%      signalpadded = zeros(3*nptssignal,1);
      % Filter signal
      if (InfoTS{iloc,8}  != 0)
        if (filterspecs{InfoTS{iloc,8},1}  == 1)
           if (filterspecs{InfoTS{iloc,8},3}  == "low ")
              lp_coeff = fir1(filterspecs{InfoTS{iloc,8},2},filterspecs{InfoTS{iloc,8},4}/(sampling_rate/2), "low");
           elseif (filterspecs{InfoTS{iloc,8},3}  == "high")
              lp_coeff = fir1(filterspecs{InfoTS{iloc,8},2},filterspecs{InfoTS{iloc,8},4}/(sampling_rate/2), "high");
           elseif (filterspecs{InfoTS{iloc,8},3}  == "band")
              lp_coeff = fir1(filterspecs{InfoTS{iloc,8},2},[filterspecs{InfoTS{iloc,8},4}/(sampling_rate/2),filterspecs{InfoTS{iloc,8},5}/(sampling_rate/2)], ...
                                  "bandpass");
           endif
%          signalpadded = [signal; signal; signal];
%           signalpadded = filter(lp_coeff,1,signalpadded);
           signal = filter(lp_coeff,1,signal);
       elseif (filterspecs{InfoTS{iloc,8},1}  == 2)
           if (filterspecs{InfoTS{iloc,8},3}  == "low ")
              [b,a] = butter(filterspecs{InfoTS{iloc,8},2},filterspecs{InfoTS{iloc,8},4}/(sampling_rate/2), "low");
           elseif (filterspecs{InfoTS{iloc,8},3}  == "high")
              [b,a] = butter(filterspecs{InfoTS{iloc,icol+2},2},filterspecs{InfoTS{iloc,8},4}/(sampling_rate/2), "high");
           elseif (filterspecs{InfoTS{iloc,8},3}  == "band")
              [b,a] = butter(filterspecs{InfoTS{iloc,8},2},[filterspecs{InfoTS{iloc,8},4}/(sampling_rate/2),filterspecs{InfoTS{iloc,8},5}/(sampling_rate/2)], ...
                                  "bandpass");
           endif
%           signalpadded = [signal; signal; signal];
%           signalpadded = filter(b,a,signalpadded);
           signal = filter(b,a,signal);
        else
           printf("Non implemented filtering strategy = %d\n",InfoTS{iloc,8});
           return;
        endif
%        signal = signalpadded((nptssignal+1):2*nptssignal);
      endif
      if (InfoTS{iloc,icol+2}  == 0)
        % Do nothing. Just copy original signal in ManipSignal
        ManipSignal(:,idir) = signal;
      elseif (InfoTS{iloc,icol+2}  == 1)
        % Calculating the derivative
        ManipSignal(:,idir) = gradient(signal, dt);
      elseif (InfoTS{iloc,icol+2}  == 2)
       % Integrating the signal in the time domain
         ManipSignal(:,idir) = cumtrapz(signal)*dt;
         ManipSignal(:,idir) = detrend(ManipSignal(:,idir),1);
      elseif (InfoTS{iloc,icol+2}  == 3)
       % Integrating the signal in the frequency signal
        signal = detrend(signal,1);
        w = 2*pi * [0:(nptssignal/2-1), -nptssignal/2:-1] / T;   % symmetric frequency vector
        w = w';
        flattop = tukeywin(nptssignal, 0.2);
        signal = signal.*flattop;
        X = fft(signal);
        w(1) = 1.0e-12;
        Y = X ./ (1j * w);
        ManipSignal(:,idir) = real(ifft(Y));
        ManipSignal(:,idir) = ManipSignal(:,idir) - mean(ManipSignal(:,idir));
        %
      else
        fprintf(fout,"\\centering{Unknown processing option}\n\n");
        printf("Unknown processing option\n");
        return;
      endif
      initial_metrics_subplots = sampling_rate;
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
        hf = figure(ifigure,"visible",VISIBLE);
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
        hf = figure(ifigure,"visible",VISIBLE);
        plot(tvect(1:nptssignal),ManipSignal(1:nptssignal,idir),"linewidth",1,"color","k");
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
        figure(ifigure,"visible",VISIBLE)
        YrangeMin = min(ManipSignal(istart(1):iend(1),idir));
        YrangeMax = max(ManipSignal(istart(1):iend(1),idir));
         for i = 2:nsubplots
           tempmin = min(ManipSignal(istart(i):iend(i),idir));
           if (tempmin < YrangeMin)
            YrangeMin = tempmin;
          endif
          tempmax = max(ManipSignal(istart(i):iend(i),idir));
          if (tempmax > YrangeMax)
            YrangeMax = tempmax;
            endif
         endfor
         Xrange = 1.1*(tvect(iend(1)) - tvect(istart(1))); % increase timespan by 10%
        for i = 1:nsubplots
           subplot(rowsubplots,columnsubplots,i);
           plot(tvect(istart(i):iend(i)),ManipSignal(istart(i):iend(i),idir),"linewidth",1,"color","k");
           ylim([YrangeMin YrangeMax]);                       % Set y-axis range
           xlim([tvect(istart(i)) tvect(istart(i))+Xrange]);  % Set x-axis range
           grid "on";
           xlabel(Titrexlabelfigsignal,'FontSize',size_of_font);
           ylabel(TitreyMS,'FontSize',size_of_font);
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
        metricssignal = zeros(nsubsignalsmetrics+1,6);
        for i = 1:nsubsignalsmetrics
          subsignal = zeros(nptsmetrics,1);
          subsignal = ManipSignal((i-1)*nptsmetrics+1:i*nptsmetrics,idir);
          %      Average             Max                  Min               RMS
           [metricssignal(i,1), metricssignal(i,2), metricssignal(i,3), metricssignal(i,4), metricssignal(i,5), metricssignal(i,6)] = ...
           metrics_signal(subsignal,0,0);
        endfor
        metricssignal(nsubsignalsmetrics+1,1) = mean(metricssignal(1:nsubsignalsmetrics,1));
        metricssignal(nsubsignalsmetrics+1,2) = mean(metricssignal(1:nsubsignalsmetrics,2));
        metricssignal(nsubsignalsmetrics+1,3) = mean(metricssignal(1:nsubsignalsmetrics,3));
        metricssignal(nsubsignalsmetrics+1,4) = mean(metricssignal(1:nsubsignalsmetrics,4));
        metricssignal(nsubsignalsmetrics+1,5) = mean(metricssignal(1:nsubsignalsmetrics,5));
        metricssignal(nsubsignalsmetrics+1,6) = mean(metricssignal(1:nsubsignalsmetrics,6));
      endif
      if (PlotMetrics != 0)
           hf = figure(ifigure,"visible",VISIBLE);
           plot(metricssignal(1:nsubsignalsmetrics,1),'bo', metricssignal(1:nsubsignalsmetrics,2),'g*', ...
           metricssignal(1:nsubsignalsmetrics,3),'ks',metricssignal(1:nsubsignalsmetrics,4),'ro',metricssignal(1:nsubsignalsmetrics,5),'ko', ...
           metricssignal(1:nsubsignalsmetrics,6),'k*');
           xlabel("Sample",'FontSize',size_of_font);
           ylabel(TitreyMS,'FontSize',size_of_font);
           set(gca, 'xtick', 1:1:nsubsignalsmetrics);
           grid "on";
           legend("Average","Max","Min","RMS","Kurtosis","Skewness","location", "northeastoutside");
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
           fprintf(fout,"\\begin{tabular}{|l | l | l | l | l |}\n");
           fprintf(fout,"\\hline\n");
           fprintf(fout," & Average & Max & Min & RMS  \\\\ \n");
           fprintf(fout,"\\hline\n");
           fprintf(fout,"%s & %8.3e & %8.3e & %8.3e & %8.3e  \\\\ \n","Ave", metricssignal(nsubsignalsmetrics+1,1), metricssignal(nsubsignalsmetrics+1,2), ...
               metricssignal(nsubsignalsmetrics+1,3),metricssignal(nsubsignalsmetrics+1,4));
           fprintf(fout,"\\hline\n");
           fprintf(fout,"\\hline\n");
           fprintf(fout," &  Kurtosis & Skewness & & \\\\ \n");
           fprintf(fout,"%s & %8.3e & %8.3e &  &  \\\\ \n","Ave", metricssignal(nsubsignalsmetrics+1,5),metricssignal(nsubsignalsmetrics+1,6));
           fprintf(fout,"\\hline\n");
           fprintf(fout,"\\end\{tabular}\n");
           fprintf(fout,"\\end\{table}\n");
        fprintf(fout,"\\end{frame}\n");
        printf("Metrics of manipulated signal:\n");
        printf("\t Average: %10.3e\n",metricssignal(nsubsignalsmetrics+1,1));
        printf("\t Maximum: %10.3e\n",metricssignal(nsubsignalsmetrics+1,2));
        printf("\t Minimum: %10.3e\n",metricssignal(nsubsignalsmetrics+1,3));
        printf("\t RMS:     %10.3e\n",metricssignal(nsubsignalsmetrics+1,4));
      endif % if (PrintMetrics != 0)
     endif % Processing X, Y or Z column of data
     fid = fopen(InfoTS{iloc,6}, 'w');   % open file for writing
     for i = 1:size(ManipSignal,1)
       stringtoprint = sprintf('%14.7e %14.7e %14.7e %14.7e\n', tvect(i), ManipSignal(i,1), ManipSignal(i,2), ManipSignal(i,3));
       fprintf(fid,stringtoprint);
     end
     fclose(fid);
   endfor % Number of directions
endfor % Number of locations
fprintf(fout,"\\end{document}\n");
fclose(fout);
copyfile(resultfile,Nresultfile);
endfunction
