#!/usr/bin/octave-cli --persist

% octave 4.0.0
% recursive filter 
%2^(-N)*z^(-1)/(1-(1-2^(-N)*z^-1))
clc, clear all, close all

Fs = eval(argv(){1})
figure%, subplot(2,1,1)
c = {}
for N = 1:1:20
  B = [2^-N, 0];
  A= [-(1-2^(-N)), 1];
  N
  fp = -Fs*log(1-2^(-N))/(2*pi)
  wn = logspace(0,8,100)*pi/Fs;
  [H,W]=freqz(B,A,wn);
  hold on
  hl = semilogx(Fs*W/(2*pi),20*log10(abs(H)));
  c = [c,sprintf("N= %d",N)];
end
hg = legend(c, 'location', "eastoutside");
grid on
set([gca;hg;hl],'linewidth',2);
set(gca,'fontsize',26);
xlabel('frequency [Hz]');
ylabel('TF magnitude[dB]');
title("IIR lowpass filter, H(z) = 2^{-N}z^{-1}/(1-(1-2^{-N})z^{-1})","interpreter","tex")

input("Press to continue...");
exit
