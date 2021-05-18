a = load("result.txt");
re = a(:,1);%a([1:127],1);
im = a(:,2);%a([1:127],2);
plot(abs(re + i * im));
