input = load("../out_fpga_cordic1.dat");
%input = load("../gen_data/data.dat");
resComp = load("result.dat");
resVhd = load("../result.txt");
N=2048;
input = input(1:2048);
val_fft=abs(fft(input));
%val_comp = abs(resComp(:,1)+(i*resComp(:,2)));
%val_vhd = abs(resVhd(:,1)+(i*resVhd(:,2)));
val_comp = sqrt((resComp(:,1).^2) + (resComp(:,2).^2));
val_vhd = sqrt((resVhd(:,1).^2)+(resVhd(:,2).^2));

val_fft=val_fft(2:N/2);
val_comp=val_comp(2:N/2);
val_vhd=val_vhd(2:N/2);
%plot(val_fft, 'r', val_comp, 'g', val_vhd, 'm');
%plot(val_fft, 'r', val_comp, 'g');
%plot(10*log10(val_fft), 'r', 10*log10(val_comp), 'g', 10*log10(val_vhd), 'm');
%plot(10*log10(val_fft), 'r', 10*log10(val_comp), 'g');
plot(10*log10(val_fft), 'r', 10*log10(val_vhd), 'm');
%plot(val_comp);
%plot(10*log10(val_fft)-10*log10(val_vhd), 'r', 10*log10(val_fft)-10*log10(val_comp),'g');
%plot(10*log10(val_fft)-10*log10(val_comp))
%plot(10*log10(val_fft),'r', 10*log10(val_comp),'g')
%plot(10*log10(val_comp)-10*log10(val_vhd))
%plot(10*log10(val_comp))
%plot(abs(abs(val_comp)-abs(val_fft)))
