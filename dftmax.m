function [dft_max1,dft_f1]=dftmax(signal_r2)
dft_max1=zeros(84,1,'int64');
dft_f1=zeros(84,1,'int64');

for m=1:84
    inputdft=[signal_r2(m:m+127,1) signal_r2(m:m+127,2)];
    signal_dft1=fidft(inputdft);
    dft2=getabs(signal_dft1);
    [dft_max1(m),dft_f1(m)]=max(dft2);
end