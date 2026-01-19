function ProcessData (vibdata, filterspecs, projectid, Titreglobal, freqmax_plot_fft, Datemesures, sampling_rate, WINDOWING, titleline, nlinestitle )
% This file needs to be documented fully. It does so many things.
global FFT_desired_Deltaf;
global OverlapFFT;  % Check that it is smaller than 1.
global PlotSignal;
global PlotSubsignals;
global CalculateMetrics;
global PrintMetrics;
global PlotMetrics;
if ((PrintMetrics != 0) || (PlotMetrics != 0))
  CalculateMetrics = 1;
  endif
global CalculateFFTs;
global PlotFFTs;
global PlotFFTsPhase;
if (PlotFFTs != 0)
  CalculateFFTs = 1;
  endif
global cutoffFFT_Plot; % Only FFT components above cutoffFFT_Plot are plotted.
global cutoffFFT_Print; % Only FFT components above cutoffFFT_Print are printed.
global OverlapFFT;
global PlotOnlyNFFTs;
global VISIBLE;
% sampling_rate must be an even number
% To do:
%
% Quand on a un signal qui compte des milliers de lectures, �a devient compliqu� de d�terminer quel est le nombre de lectures � utiliser; le
% delta f minimum, etc.  Tout cela pourrait �tre ajout� sur une diapo apr�s avoir lu le signal.
% Par exemple: delta f min. = 1/T = 1/(vibdata{iloc,5}*sampling_rate);
% Calculer un delta f typique: 1/(T/5) - 1 cinquieme de la periode du signal.
% Aussi, donner une idée du meilleur nombre d'intervalles.
%
% Calculer la rms des coefficients de la FFT
%
%
% Avoir un ficher de r�sultats main.tex et faire des input des autres fichiers qui deviendraient des chapitres
% Avoir un fichier warning.tex et �crire tous les warnings l�. Toujours inclure ce fichier comme premier input du report.texi_macros_file
% Ajouter Windowing aux donn�es de chaque signal
% Filtering
% first argument is order, second argument is cutoff frequency - cutoff frequency must be added as data.
%
%
% Une fonction qui �crirait une introduction serait utile. En profiter pour d�finir les directions.
% Dans le tableau des max fft, se d�placer pour ne pas que tous les max soient autour de la m�me fr�quence.
% Calculer le crest factor = peak/RMS pour le signal dans le temps. pour sin = sqrt(2); pour random = 3
% V�rifier ce qu'est le Kurtosis et le calculer.
%Read: https://www.edn.com/windowing-functions-improve-fft-results-part-ii/
%
%Peut-on illustrer Nyquist � voir  http://scholarsarchive.jwu.edu/cgi/viewcontent.cgi?article=1006&context=engineering_fac
%
%https://www.gaussianwaves.com/2015/11/interpreting-fft-results-obtaining-magnitude-and-phase-information/ - faire �a pour un tremblement de terre ou un signal plus complexe que ce que j�ai essay� jusqu�� maintenant.
%
%Continuer les tests faits ici : https://blog.mide.com/vibration-analysis-fft-psd-and-spectrogram . En particulier, s�assurer que la valeur des coefficients diminue lorsque je diminue delta f.
%
%D'autres tests sont ici : https://www.mathworks.com/help/matlab/ref/fft.html
%
%Calculer le 1/3 octave band frequency spectrum en utilisant la technique pr�sent�e � la page 166 de la th�se de Liu.
%
%
%Tester avec des donn�es de tremblement de terre :
%
%[17:14] Victor Bourassa
%https://peer.berkeley.edu/peer-strong-ground-motion-databases
%https://strongmotioncenter.org/
%
%Je devrais essayer de reconstruire le signal à partir des coefficients de la fft obtenus et mesurer la différence entre les deux signaux;

ifigure=1;
size_of_font = 18;
Titrexlabelfigsignal = "Temps (s)";
resultfile = ["report" projectid ".tex"];
Nresultfile = ["report" projectid ".tek"]; % tex file is copied to tek file so that git can be instructed to ignore tex files
fout = fopen(resultfile,"w");
printtopresultfile(fout,Titreglobal,Datemesures);
noflocations = size(vibdata)(1); % Number of locations; must match number of lines of array vibdata

% Main loop on the number of locations or number of lines of vibdata
for iloc = 1:noflocations
   TitleSection = [vibdata{iloc,1}];
   fprintf(fout,"\\section{%s}\n",TitleSection);
   fprintf(fout,"\\begin{frame}{%s}\n",TitleSection);
   fprintf(fout,"\\begin{itemize}\n")
   fprintf(fout,"\\item Read from file: %s\n",strrep(vibdata{iloc,2}, "_", "\\_"));
   fprintf(fout,"\\item Measured quantity: %s\n",vibdata{iloc,3})
   fprintf(fout,"\\item Units: %s\n",vibdata{iloc,4})
   fprintf(fout,"\\end{itemize}\n")
   fprintf(fout,"\\end{frame}\n");

   for idir=1:3
   % Loop on direction
    icol = 0;
    if ((idir == 1) && (vibdata{iloc,7} == 1))
      icol = 6;
      TitleSubSection = ["XDir"];
%      TitleSubSection = [vibdata{iloc,1}];
    elseif ((idir == 2) && (vibdata{iloc,10} == 1))
      icol = 9;
      TitleSubSection = ["YDir"];
    elseif ((idir == 3) && (vibdata{iloc,13} == 1))
      icol = 12;
      TitleSubSection = ["ZDir"];
    endif
   if (icol != 0) % if icol is not 0, then direction must be processed
      % Read signal from file
      signal = readsignal(vibdata{iloc,2},titleline,nlinestitle,vibdata{iloc,icol});
      nptssignal       = length(signal);
      vibdata{iloc,5}  = nptssignal;
      tvect = 0:(1/sampling_rate):(nptssignal-1)/sampling_rate;
      tvect = tvect';
      fprintf(fout,"\\subsection{%s}\n",TitleSubSection);
      fprintf(fout,"\\begin{frame}\n");
      fprintf(fout,"\\centering{%s}\n\n",TitleSubSection);
      fprintf(fout,"Number of points: %d\n\n",vibdata{iloc,5})
      fprintf(fout,"Elapsed time: %10.3f \$\\rm\{s}\$\n\n",nptssignal/sampling_rate)
      if (vibdata{iloc,icol+2}  != 0)
        fprintf(fout,"\\centering{Filtering: %d}\n\n",vibdata{iloc,icol+2})
        fprintf(fout,"\\centering{Order: %d}\n\n",filterspecs{vibdata{iloc,icol+2},2})
        fprintf(fout,"\\centering{Type       : %s}\n\n",filterspecs{vibdata{iloc,icol+2},3})
        if (filterspecs{vibdata{iloc,icol+2},3}  == "low ")
           fprintf(fout,"\\centering{Cutoff  : %8.1f Hz}\n",filterspecs{vibdata{iloc,icol+2},4})
        elseif (filterspecs{vibdata{iloc,icol+2},3}  == "high")
           fprintf(fout,"\\centering{Cutoff  : %8.1f Hz}\n",filterspecs{vibdata{iloc,icol+2},4})
        elseif (filterspecs{vibdata{iloc,icol+2},3}  == "band")
           fprintf(fout,"\\centering{Cutoff low  : %8.1f Hz}\n",filterspecs{vibdata{iloc,icol+2},4})
           fprintf(fout,"\\centering{\ high : %8.1f Hz}\n",filterspecs{vibdata{iloc,icol+2},5})
        endif
      else
        fprintf(fout,"\\centering{No filtering applied}\n")
      endif
      fprintf(fout,"\\end{frame}\n");
      if (vibdata{iloc,icol+2}  != 0)
        if (filterspecs{vibdata{iloc,icol+2},1}  == 1)
           if (filterspecs{vibdata{iloc,icol+2},3}  == "low ")
              lp_coeff = fir1(filterspecs{vibdata{iloc,icol+2},2},filterspecs{vibdata{iloc,icol+2},4}/(sampling_rate/2), "low");
           elseif (filterspecs{vibdata{iloc,icol+2},3}  == "high")
              lp_coeff = fir1(filterspecs{vibdata{iloc,icol+2},2},filterspecs{vibdata{iloc,icol+2},4}/(sampling_rate/2), "high");
           elseif (filterspecs{vibdata{iloc,icol+2},3}  == "band")
              lp_coeff = fir1(filterspecs{vibdata{iloc,icol+2},2},[filterspecs{vibdata{iloc,icol+2},4}/(sampling_rate/2),filterspecs{vibdata{iloc,icol+2},5}/(sampling_rate/2)], ...
                                  "bandpass");
                                  endif
         else
           printf("Non implemented filtering strategy = %d\n",vibdata{iloc,icol+2});
        endif
         signal = filter(lp_coeff,1,signal);
      endif
% Various numbers required later in the code
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
    nsamples = floor(FFT_desired_Deltaf/(1/Tsignal));
    if (nsamples == 0)
        nsamples++;
        nptsperFFT = nptssignal;
        IntervalsFFT = 1; % Number of FFTs calculated. 2 = signal divided in 2 and 2 FFT calculated
    else % nsamples != 0
##        if (nsamples > 10) % limit number of samples to 10
##          nsamples = 10;
##        endif
        nptsperFFT = pow2(floor(log2(nptssignal/nsamples)));
        % floor below should not be used as the result should be an integer always
        IntervalsFFT = floor((nptssignal - nptsperFFT)/(nptsperFFT*(1-OverlapFFT))) + 1;
        if ( (floor((nptssignal - nptsperFFT)/(nptsperFFT*(1-OverlapFFT))) + 1) != ...
          ((nptssignal - nptsperFFT)/(nptsperFFT*(1-OverlapFFT))) + 1)
            printf("Number of intervalsFFT not integer. Check to make sure ranges are ok.\n");
         endif
    endif; % if (nsamples == 0)
     FFTs2Print = zeros(PlotOnlyNFFTs,1);
     if (IntervalsFFT <= PlotOnlyNFFTs)
       FFTs2Print = (1:1:IntervalsFFT);
     else
       FFTs2Print =  sort(randperm(IntervalsFFT,PlotOnlyNFFTs));
     endif
    is_ie = zeros(IntervalsFFT,2); % nptsFFT = column 2 - column 1 + 1
    fprintf(fout,"\\begin{frame}{FFT parameters}\n");
           fprintf(fout,"\\begin\{table}\n");
           fprintf(fout,"\\begin\{tabular}{ll}\n");
     fprintf(fout,"Sampling Rate            & %d samples per s\\\\ \n",sampling_rate);
     fprintf(fout,"Number of pts per FFT    & %d \\\\ \n",nptsperFFT);
     fprintf(fout,"Overlap                  & %8.1f \$ \\%% \$ \\\\ \n",OverlapFFT*100);
     fprintf(fout,"No of FFTs per signal    & %d  \\\\ \n",IntervalsFFT);
     fprintf(fout,"No of plotted FFTs       & %d  \\\\ \n",PlotOnlyNFFTs);
     fprintf(fout,"Number of spectral lines & %d \\\\ \n",nptsperFFT/2);
     fprintf(fout,"Frequency resolution     & %10.3f Hz \\\\ \n",sampling_rate/nptsperFFT);
     if ( WINDOWING>0 && WINDOWING<=1 )
       fprintf(fout,"Window                 & Flat top - alpha = %8.2f \\\\ \n", WINDOWING);
     elseif (WINDOWING ==2)
       fprintf(fout,"Window                 & Hanning \\\\ \n");
     else
       fprintf(fout,"Unwindowed signal      & \\\\ \n");
     endif
     fprintf(fout,"Max Frequency Displayed  & %8.1f Hz \\\\ \n",freqmax_plot_fft);
     fprintf(fout,"\\end{tabular}\n")
     fprintf(fout,"\\end{table}\n")
    fprintf(fout,"\\end{frame}\n");



    Titrey = [vibdata{iloc,3} " (" vibdata{iloc,4} ")"];
%
      if (PlotSignal != 0)
        hf = figure(ifigure,"visible",VISIBLE);
        plot(tvect(1:nptssignal),signal(1:nptssignal),"linewidth",1,"color","k");
        xlabel(Titrexlabelfigsignal,'FontSize',size_of_font);
        ylabel(Titrey,'FontSize',size_of_font);
        grid "on";
        filename = [vibdata{iloc,1} TitleSubSection "signal.tex"];
        print(filename,'-dpdflatex');
        filenamesvg = [vibdata{iloc,1} TitleSubSection "signal.svg"];
        print(filenamesvg);
        fprintf(fout,"\\begin{frame}{Entire signal (%d points)}\n",nptssignal);
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
        filename = [vibdata{iloc,1} TitleSubSection "subsignals.tex"];
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
          subsignal = signal((i-1)*nptsmetrics+1:i*nptsmetrics);
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
           metricssignal(1:nsubsignalsmetrics,3),'ks',metricssignal(1:nsubsignalsmetrics,4),'ro', ...
           metricssignal(1:nsubsignalsmetrics,5),'bo',metricssignal(1:nsubsignalsmetrics,6),'k*');
           xlabel("Sample",'FontSize',size_of_font);
           ylabel(Titrey,'FontSize',size_of_font);
           set(gca, 'xtick', 1:1:nsubsignalsmetrics);
           grid "on";
           legend("Average","Max","Min","RMS","Kurtosis","Skewness","location", "northeastoutside");
           filename = [vibdata{iloc,1} TitleSubSection "metrics.tex"];
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
      endif % if (PrintMetrics != 0)
      %
      % FFT
      %
      if (CalculateFFTs != 0)
          % Filling up is_ie
          is_ie(1,1) = 1;
          is_ie(1,2) = nptsperFFT;
          for i=2:(IntervalsFFT-1)
               is_ie(i,1) = is_ie(i-1,2) + 1 - floor(OverlapFFT*nptsperFFT);
               is_ie(i,2) = is_ie(i,1)   + nptsperFFT - 1;
            endfor
          is_ie(IntervalsFFT,1) = nptssignal - nptsperFFT + 1;
          is_ie(IntervalsFFT,2) = nptssignal;
          jFFTPrint = 1;
          for iFFT=1:IntervalsFFT
            if (jFFTPrint <= PlotOnlyNFFTs)
            if (iFFT == FFTs2Print(jFFTPrint))
              jFFTPrint++;
              signalFFT = zeros(nptsperFFT,1);
              signalFFT = signal(is_ie(iFFT,1):is_ie(iFFT,2));
              if ( WINDOWING > 0 && WINDOWING <= 1 )
                FlatTop = tukeywin(nptsperFFT, WINDOWING);
                signalFFT = signalFFT.*FlatTop;
              elseif (WINDOWING == 2)
                  Hanning = Hanning_func(nptsperFFT);
                  signalFFT = signalFFT.*Hanning;
               endif
               df = sampling_rate/nptsperFFT;
               freqs_fft = [0 : df: (sampling_rate/2-df)];
               fft_RI = 2/nptsperFFT.*fft(signalFFT,nptsperFFT,1);
               fft_RI(1)=fft_RI(1)/2;
               fft_phase_angle = arg(fft_RI)*180/pi;
                  %
               fftabs = abs(fft_RI);
               DCcomp = fftabs(1);
               [sortfft,ifft] = sort(fftabs(1:nptsperFFT/2),1,"descend");
               MaxFFTcomp = sortfft(1);
               fractionofmax     = DCcomp/MaxFFTcomp;
               maxfftcomps       = zeros((nptsperFFT/2),1);
               freqs2plot        = zeros((nptsperFFT/2),1);
               phasemaxfftcomps  = zeros((nptsperFFT/2),1);
               maxfftcomps_Print = zeros((nptsperFFT/2),1);
               freqs2print       = zeros((nptsperFFT/2),1);
               i = 1;
               maxfftcomps(1)       = MaxFFTcomp;
               phasemaxfftcomps(1)  = fft_phase_angle(ifft(1));
               freqs2plot(1)        = freqs_fft(ifft(1));
               maxfftcomps_Print(1) = MaxFFTcomp;
               freqs2print(1)       = freqs_fft(ifft(1));
               while (i<nptsperFFT/2 && (sortfft(i+1) > cutoffFFT_Plot*MaxFFTcomp))
                    maxfftcomps(i+1)      = sortfft(i+1);
                    freqs2plot(i+1)       = freqs_fft(ifft(i+1));
                    phasemaxfftcomps(i+1) = fft_phase_angle(ifft(i+1));
                    i++;
               endwhile
               noffreqs2plot = i;
               i = 1;
               while (i<nptsperFFT/2 && (sortfft(i+1) > cutoffFFT_Print*MaxFFTcomp))
                    maxfftcomps_Print(i+1)      = sortfft(i+1);
                    freqs2print(i+1)       = freqs_fft(ifft(i+1));
                    i++;
               endwhile
               noffreqs2print = i;
               sortfft_2 = zeros(noffreqs2print,1);
               [sortfft_2,ifft2print] = sort(freqs2print(1:noffreqs2print),1,"ascend");
             if (PlotFFTs != 0)
    %            Plotting magnitude
                 figure(ifigure,"visible",VISIBLE);
                 stem(freqs2plot(1:noffreqs2plot),maxfftcomps(1:noffreqs2plot),"o", "color","k", ...
                    "linewidth",2,"markersize",9, "markeredgecolor","k");
                 grid "on";
                 axis([0 freqmax_plot_fft 0 MaxFFTcomp]);
                 xlabel("Frequency (Hz)","fontsize",size_of_font);
                 ylabel(Titrey,'FontSize',size_of_font);
                    h = legend(TitleSection);
                    legend(h,"location","northeast");
                    iFFTs = num2str(iFFT);
                 filename = [vibdata{iloc,1} TitleSubSection "FFT" iFFTs ".tex"];
                 print(filename,'-dtex');
                 filenamesvg = [vibdata{iloc,1} TitleSubSection "FFT" iFFTs ".svg"];
                 print(filenamesvg);
                    ifigure++;
                  fprintf(fout,"\\begin{frame}{FFT - Magn. - Interval %d (N pts = %d, %d to %d)}\n",iFFT, nptsperFFT,is_ie(iFFT,1),is_ie(iFFT,2));
                     fprintf(fout,"DC component = %10.3e (%8.3e \$ \\%% \$ of Max)\n",DCcomp,fractionofmax*100);
                     fprintf(fout,"\n");
                     fprintf(fout,"Max over all calculated FFTs = %10.3e at %8.3e Hz\n",maxfftcomps(1),freqs2plot(1));
                     fprintf(fout,"\n");
                     fprintf(fout,"Number of plotted components = %d (Threshold: %5.1f \$ \\%% \$ of Max)\n",noffreqs2plot, cutoffFFT_Plot*100);
                     fprintf(fout,"\\begin\{figure\}[H]\n");
                     fprintf(fout,"\\centering\n");
                     fprintf(fout,"\\scalebox\{0.55\}\{\\input\{%s\}\}\n",filename);
                     fprintf(fout,"\\end\{figure\}\n");
                 fprintf(fout,"\\end{frame}\n");
                     if (noffreqs2print >= 6)
                       nlinestablefreqs = floor(noffreqs2print/6);
                       if (nlinestablefreqs > 7 )
                         nlinestablefreqs = 7;
                       endif
                       % Sorted by magnitude: high to low
                       fprintf(fout,"\\begin{frame}{FFT - Magn. - Interval %d (N pts = %d, %d to %d)}\n",iFFT, nptsperFFT,is_ie(iFFT,1),is_ie(iFFT,2));
                       fprintf(fout,"\\fontsize{9pt}{10pt}\\selectfont\n");
                       fprintf(fout,"Sorted by decreasing magnitude\n");
                       fprintf(fout,"\n");
                       fprintf(fout,"Number of components = %d (Threshold: %5.1f \$ \\%% \$ of Max) - Printed: %d\n",...
                                        noffreqs2print, cutoffFFT_Print*100,nlinestablefreqs*6);
                       fprintf(fout,"\\begin\{table}\n");
                       fprintf(fout,"\\begin\{tabular}{| l | l | l | l | l | l | l |}\n");
                       fprintf(fout,"\\hline\n");
                       fprintf(fout,"  & 1 & 2 & 3 & 4 & 5 & 6 \\\\ \n");
                       fprintf(fout,"\\hline\n");
                       fprintf(fout,"\\hline\n");
                       for iline=1:nlinestablefreqs
                         k = (iline - 1)*6;
                         fprintf(fout,"  %d    & %10.1e & %10.1e & %10.1e & %10.1e & %10.1e & %10.1e \\\\ \n", k, ...
                         maxfftcomps_Print(k+1),maxfftcomps_Print(k+2), maxfftcomps_Print(k+3), ...
                         maxfftcomps_Print(k+4), maxfftcomps_Print(k+5), maxfftcomps_Print(k+6));
                         fprintf(fout,"Freq. &     %8.1f & %8.1f     & %8.1f     & %8.1f & %8.1f     & %8.1f \\\\ \n", ....
                         freqs2print(k+1),freqs2print(k+2),freqs2print(k+3),freqs2print(k+4),freqs2print(k+5),freqs2print(k+6));
                         fprintf(fout,"\\hline\n");
                       endfor
                       fprintf(fout,"\\end\{tabular}\n");
                       fprintf(fout,"\\end\{table}\n");
                       fprintf(fout,"\\end{frame}\n");
                       % sorted by frequency; low to high;
                       fprintf(fout,"\\begin{frame}{FFT - Magn. - Interval %d (N pts = %d, %d to %d)}\n",iFFT, nptsperFFT,is_ie(iFFT,1),is_ie(iFFT,2));
                       fprintf(fout,"\\fontsize{9pt}{10pt}\\selectfont\n");
                       fprintf(fout,"Sorted by increasing frequency\n");
                       fprintf(fout,"\n");
                       fprintf(fout,"Number of components = %d (Threshold: %5.1f \$ \\%% \$ of Max) - Printed: %d\n",...
                                        noffreqs2print, cutoffFFT_Print*100,nlinestablefreqs*6);
                       fprintf(fout,"\\begin\{table}\n");
                       fprintf(fout,"\\begin\{tabular}{| l | l | l | l | l | l | l |}\n");
                       fprintf(fout,"\\hline\n");
                       fprintf(fout,"  & 1 & 2 & 3 & 4 & 5 & 6 \\\\ \n");
                       fprintf(fout,"\\hline\n");
                       fprintf(fout,"\\hline\n");
                     for iline=1:nlinestablefreqs
                         k = (iline - 1)*6;
                         fprintf(fout,"  %d    & %10.1e & %10.1e & %10.1e & %10.1e & %10.1e & %10.1e \\\\ \n", k, ...
                         maxfftcomps_Print(ifft2print(k+1)),maxfftcomps_Print(ifft2print(k+2)), maxfftcomps_Print(ifft2print(k+3)), ...
                         maxfftcomps_Print(ifft2print(k+4)), maxfftcomps_Print(ifft2print(k+5)), maxfftcomps_Print(ifft2print(k+6)));
                         fprintf(fout,"Freq. &     %8.1f & %8.1f     & %8.1f     & %8.1f & %8.1f     & %8.1f \\\\ \n", ....
                         sortfft_2(k+1),sortfft_2(k+2),sortfft_2(k+3),sortfft_2(k+4),sortfft_2(k+5),sortfft_2(k+6));
                       endfor
                       fprintf(fout,"\\hline\n");
                       fprintf(fout,"\\end\{tabular}\n");
                       fprintf(fout,"\\end\{table}\n");
                       fprintf(fout,"\\end{frame}\n");
                     endif % if (noffreqs2plot >= 6)
        % Plotting phase
                if (PlotFFTsPhase != 0)
                   figure(ifigure,"visible",VISIBLE);
                   stem(freqs_fft(ifft(1:noffreqs2plot)),phasemaxfftcomps(1:noffreqs2plot),"o", "color","k", ...
                      "linewidth",2,"markersize",9, "markeredgecolor","k");
                   grid "on";
                   axis([0 freqmax_plot_fft -180 180]);
                   set(gca,'YTick',-180:45:180)
                   xlabel("Frequency (Hz)");
                   ylabel("Phase Angle (deg.)");
                      h = legend(TitleSection);
                      legend(h,"location","northeast");
                      iFFTs = num2str(iFFT);
                   filename = [vibdata{iloc,1} TitleSubSection "FFT_ANGLE" iFFTs ".tex"];
                   print(filename,'-dtex');
                   ifigure++;
                   fprintf(fout,"\\begin{frame}{FFT - Phase (deg.) - Interval %d (N pts = %d, %d to %d)}\n",iFFT, nptsperFFT,is_ie(iFFT,1),is_ie(iFFT,2));
                       fprintf(fout,"Number of plotted components = %d \n",noffreqs2plot);
                       fprintf(fout,"\\begin\{figure\}[H]\n");
                       fprintf(fout,"\\centering\n");
                       fprintf(fout,"\\scalebox\{0.6\}\{\\input\{%s\}\}\n",filename);
                       fprintf(fout,"\\end\{figure\}\n");
                   fprintf(fout,"\\end{frame}\n");
                 endif % if PlotFFTSPhase
             endif % if PlotFFTs != 0
           endif % Was this FFT requested for plotting or printing by user.
          endif % Are we done plotting the FFTs that the user has requested.
         endfor % Loop on FFTs
        endif % if CalculateFFTs != 0
         %
         % PSD
         %
         [Pxx,f] = pwelch(signal, nptsperFFT, OverlapFFT, nptsperFFT, sampling_rate, 'half', 'plot');
         figure(ifigure,"visible",VISIBLE);
         loglog(f,Pxx);
         MaxFreqPWelch = power(10,(floor(log10(freqmax_plot_fft))+1));
         xlim([1 MaxFreqPWelch]);
         grid "on";
         ylim([1.0e-07 100]);  % Set y-axis range
         xlabel("Frequency (Hz)");
         ifigure++;
         filename = [vibdata{iloc,1} TitleSubSection "PSD.tex"];
         print(filename,'-dtex');
         fprintf(fout,"\\begin{frame}{PSD - Units: (%s)$^2/$ Hz\}\n",vibdata{iloc,4});
         fprintf(fout,"\\begin\{figure\}[H]\n");
         fprintf(fout,"\\centering\n");
         fprintf(fout,"\\scalebox\{0.7\}\{\\input\{%s\}\}\n",filename);
         fprintf(fout,"\\end\{figure\}\n");
         fprintf(fout,"\\end{frame}\n");
           %    Spectogram
          window = hanning(nptssignal/4);         % analysis window
          noverlap = OverlapFFT*nptssignal/4;                % overlap between windows
          figure(ifigure,"visible",VISIBLE);
          specgram(signal, nptssignal/4, sampling_rate, window, noverlap);
%          specgram(signal, nptsperFFT/2, sampling_rate);
          colorbar;
          title("Spectrogram");
          xlabel("Time (s)");
          ylabel("Frequency (Hz)");
          ylim([0 freqmax_plot_fft]);

         ifigure++;
         filename = [vibdata{iloc,1} TitleSubSection "SPGM.tex"];
         print(filename,'-dtex');
         fprintf(fout,"\\begin{frame}{Spectogram\}\n");
         fprintf(fout,"\\begin\{figure\}[H]\n");
         fprintf(fout,"\\centering\n");
         fprintf(fout,"\\scalebox\{0.5\}\{\\input\{%s\}\}\n",filename);
         fprintf(fout,"\\end\{figure\}\n");
         fprintf(fout,"\\end{frame}\n");
       endif % Processing X, Y or Z column of data
   endfor % Number of directions
endfor % Number of locations
fprintf(fout,"\\end{document}\n");
fclose(fout);
copyfile(resultfile,Nresultfile);
endfunction
