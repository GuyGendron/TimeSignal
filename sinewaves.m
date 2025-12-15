function [xtot] = sinewaves(t_vect, N_harmonics, Ampl, freqs, Phases)
  Ndata = length(t_vect);
  x    = zeros(Ndata,N_harmonics);
  xtot = zeros(Ndata,1);
  for ii=1:N_harmonics
    x(:,ii) = Ampl(ii)*sin(2*pi*freqs(ii)*t_vect - Phases(ii));
    xtot = xtot + x(:,ii);
  endfor
endfunction
