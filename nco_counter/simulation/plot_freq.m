F=125e6;
load("result.txt");
q1=result(:,1);%(50:end);
i1=result(:,2);%(50:end);
l=i1 + i * q1;
N=length(i1);
fs=(([1:1:N]*F)/N)(1:N/2);
ff1 = 10*log10(abs(fft(l)));

load("result2.txt");
q2=result(:,1);%(50:end);
i2=result(:,2);%(50:end);
l2=i2 + i * q2;
N=length(i2);
fs=(([1:1:N]*F)/N)(1:N/2);
ff2 = 10*log10(abs(fft(l2)));

%plot(fs, ff1(1:N/2), fs, ff2(1:N/2));
plot(q1, 'r', i1, 'g', q2, 'b', i2, 'k');

