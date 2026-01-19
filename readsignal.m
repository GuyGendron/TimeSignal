function signal = readsignal(filename,titleline,ntitlelines,column)
[~, ~, ext] = fileparts(filename);
if strcmp(ext, ".mat")
   filedotmat = load(filename);
   fn     = fieldnames(filedotmat);
   signal  = filedotmat.(fn{1})(:,column);
else
  if (titleline != 1)
    ntitlelines = 0;
    endif
  dummy = dlmread(filename,"",ntitlelines,column-1);
  signal = dummy(:,1);
  clear dummy;
endif
endfunction
