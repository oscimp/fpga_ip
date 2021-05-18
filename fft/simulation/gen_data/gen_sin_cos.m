SIZE=6*pi;
STEP=2048;
a = [0:SIZE/STEP:SIZE];
aa = cos(a)*(32768/2);%+127+0.5;
bb = sin(a)*(32768/2);%+127+0.5;
cos_val = int32(aa);
sin_val = int32(bb);
res = [cos_val sin_val];
hold off
plot(cos_val, 'b')
hold on
plot(sin_val, 'r')
%save -text "dds_coeff.dat" res;
%save -text "dds_sin.dat" sin_val;
save -text "data.dat" cos_val;
%save -text "coeff_re.dat" cos_val;
%save -text "coeff_im.dat" sin_val;

