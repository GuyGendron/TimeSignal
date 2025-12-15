function sinsquared = sinsquared_func(x,A,T,plot_flag)
  % x: Values where A*sin(x)*sin(x) is evaluated
  % plot_flag: 0 or 1; 1 plot the function
   N = length(x);
   sinsquared = A*sin(2*pi*x/T).*sin(2*pi*x/T);
   if (plot_flag == 1)
     plot(x,sinsquared);
   endif
endfunction
