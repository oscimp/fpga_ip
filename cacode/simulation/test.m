pkg load signal
close all;
%load result.txt
res = load("../simuC/toto");
%res = load("result.txt");

%for k=1:32
%for k=10:20
%for k=21:32
%x = cacode(k);
%plot(xcorr(x-mean(x), res(:,k)-mean(res(:,k))))
%title(num2str(k))
%figure
%end

res = res(1:1023);
res = res';
x = cacode(1);
%plot(xcorr(x-mean(x), res(:,1)-mean(res(:,1))))
%plot(xcorr(x, res-mean(res)))
plot(xcorr(x-mean(x), x-mean(x)))
