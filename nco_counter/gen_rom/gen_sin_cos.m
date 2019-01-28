addr= 2^12
a = [0:2*pi/addr:2*pi];
aa = cos(a)*(((2^(16-1))-1)/2);%+127+0.5;
bb = sin(a)*((2^(16-1))/2)-1;%+127+0.5;
cos_val = int32(aa);
sin_val = int32(bb);
res = [cos_val sin_val];
plot(cos_val, 'b')
hold on
plot(sin_val, 'r')
%save -text "dds_coeff.dat" res;
%save -text "dds_sin.dat" sin_val;
save -text "dds_cos.dat" cos_val;

