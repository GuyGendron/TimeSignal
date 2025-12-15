function signal = readsignal(filename,titleline,ntitlelines,length,column)
% titleline = 0 if no title line, 1 otherwise
%fid=fopen(filename);
%line=0; %for storing the string value of each line of the file
%if (titleline == 1)
%  for i=1:ntitlelines
%      line=fgetl(fid); % read title line
%  endfor
%endif
%signal = zeros(length,1);
%i = 1;
%while (-1 ~= (line=fgetl(fid)))
%        signal_ligne=str2num(line);
%        signal(i) = signal_ligne(column);
%        i++;
%end
%fclose(fid);
if (titleline != 1)
  ntitlelines = 0;
  endif
dummy = dlmread(filename,"",ntitlelines,column-1);
signal = dummy(:,1);
clear dummy;
endfunction
