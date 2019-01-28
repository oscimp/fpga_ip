fs1=250e6;
N=2048;
f1=fs1*(0:N/2-1)/N;

freq_out=10e6;
addr=2^11;
cos_fake = cos([0:2*pi/addr:2*pi]);
cos_fake = cos_fake(1:N);

a = load("result.txt");
im_val = a(:,1)(1:N);
re_val = a(:,2)(1:N);
rfs = cos_fake' .*im_val;
ifs = cos_fake' .*re_val;
plop = re_val + i * im_val;
%plop=re_val .* re_val .+ im_val .* im_val;
plot(f1, 10*log10(abs(fft(plop)(1:N/2))))
plop=rfs .* rfs .+ ifs .* ifs;
plop = rfs + i * ifs;
plot(f1, 10*log10(abs(fft(plop)(1:N/2))))
