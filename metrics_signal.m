function [average, max, min, rms]  = metrics_signal(x,print,fid)
  % x: vector of values
  % print: 0 do not print table of metrics, 1: print.
  % fid: print to file pointed to by fid.
  n = size(x,1);
  average = mean(x);
  max = max(x);
  min = min(x);
  rms = rms(x);
  if (print == 1) 
    if (fid == 0)  % print to command window
       fprintf("Max    : %10.3e\n",max);
       fprintf("Average: %10.3e\n",average);
       fprintf("RMS    : %10.3e\n",rms);
       fprintf("Min    : %10.3e\n",min);
    else
       fprintf(fid,"Max    : %10.3e\n",max);
       fprintf(fid,"Average: %10.3e\n",average);
       fprintf(fid,"RMS    : %10.3e\n",rms);
       fprintf(fid,"Min    : %10.3e\n",min);
    endif
  endif
  endfunction
