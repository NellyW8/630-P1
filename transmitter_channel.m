f=ones(1,128);
k=zeros(1,8);
d=randi([0,1],1,664);
t=[f k d];
x=1-2*t;
x1=zeros(1,800);
for k=1:800
    x1(k)=exp(1i*pi*k/4)*x(k);
end
%x2=zeros(1,16*800);
%for i=1:800
 %   x2(i*16)=x1(i);
%end
h=rcosdesign(0.35,6,16);
s=upfirdn(x1,h,16);
r=zeros(1,880*16);
%r=signal_r(s,39,);
k0=-30;
f0=1000;
for k=1:12881
    r(40*16+k0*16+k)=exp(2*pi*f0*k*1i/16000)*s(k);
end
snr=100;
r=awgn(r,snr);