function Nlines = Nlinesfile(filename,titleline,ntitlelines)
% titleline = 0 if no title line, 1 otherwise
fid=fopen(filename); 
line=0; %for storing the string value of each line of the file 
Nlines = 0;
while (-1 ~= (line=fgetl(fid))) 
        Nlines++; 
end 
if (titleline == 1)
  Nlines = Nlines - ntitlelines;
endif
fclose(fid); 
endfunction