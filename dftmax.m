function [dft_max1,dft_f1]=dftmax(input)
dft_max1=zeros(84,1,'int32');
dft_f1=zeros(84,1,'int32');

for m=int16(1):int16(84)
    inputdft=[input(m:m+127,1) input(m:m+127,2)];
    signal_dft1=fidft(inputdft);
    dft2=getabs(signal_dft1);
    [dft_max1(m),dft_f1(m)]=max(dft2);
end