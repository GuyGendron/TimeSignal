function Triangle = Triangle_func(t,plot_flag)
  % plot: 0 or 1; 1 to plot function
  Ndata = length(t);
  ivalues = 0:(Ndata-1);
  Triangle = 1 .- abs((ivalues' .-Ndata/2)/(Ndata/2));
 if (plot_flag == 1)
   plot(t,triangle);
   ylabel("Triangular Window");
   grid("on");
 endif
endfunction
