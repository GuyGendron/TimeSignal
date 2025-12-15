function Hanning = Hanning_func(N)
  % N: size of vector
  % Some useless comment.
   Hanning = zeros(N,1);
   i=0:(N-1);
   Hanning = 0.5*(1 - cos(2*pi*i/N))';
endfunction
