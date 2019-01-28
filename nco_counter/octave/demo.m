cpt_bit=32;
freq_in=250e6;
freq_out=10e6;

% phase accum
freq_step=freq_in/2^cpt_bit;
incr=freq_out/freq_step;
inc_int=int32(incr);

% LUT
addr= 2^12;
a = [0:2*pi/addr:2*pi];
aa = cos(a)*((2^16-1)/2)-1;
cos_val = int32(aa);

clf;
plot(aa, 'g');
hold on;
plot(cos_val);

step_int=int32([0:inc_int:2^32]./2^(cpt_bit-12)).+1;
step=[0:incr:2^32]./2^(cpt_bit-12).+1;
plot(step_int, cos_val(step_int),'r+');
plot(step, aa(int32(step)),'g+');
%plot([step step], [ones(1,length(step))*max(aa)' ones(1,length(step))*min(aa)'],'g');
hold off;

plot(cos_val(1:int32(step):end), 'r', cos_val.+10, 'b')


% LUT
addr= 2^12;
b = [0:2*pi/addr:2*pi*25];
bb = cos(b)*((2^16-1)/2)-1;
cos_val_b = int32(bb);
