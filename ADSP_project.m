%The Generation of 800 bits signal,which contains CW signal-128 bits,key 8
%bits and 664 bits random signal
clear


cw_signal=ones(128,1);
key_signal=ones(8,1);
content_signal=randi([0 1],664,1);
signal_input=[cw_signal;key_signal;content_signal];

% pi/4 BPSK modulator
for k_s=1:800
    signal_mod(k_s,1)=exp(pi*k_s*1i/4)*(1-2*signal_input(k_s,1));
end 

%Create a RRC filter,with alpha=0.35,This filter covers +/- 3 symbols, with length = 97 taps

rrc_filter=rcosdesign(0.35,6,16);               % or rcosdesign(0.35,3,32)

%Upsample the signal by 16
signal_mod_up=upsample(signal_mod,16);

%Pass the signal through a lowpass filter
%signal_s=upfirdn(signal_mod,rrc_filter,16);
signal_s=conv(signal_mod_up,rrc_filter);

% AWGN Channel This part needs to install coomunications toolbox.
signal_r=AWGN_channel(signal_s,0,0,0,1000);

% Pass the signal through the LPF filter:RRC filter
signal_r1=conv(signal_r,rrc_filter);
%signal_r1=upfirdn(signal_r,rrc_filter,1);

% Find the correct sampling time using energy method
sum_energy=zeros(16,1);
for j=1:16
    k_s=0;
    while((16*k_s+j)<=length(signal_r1))
        sum_energy(j)=sum_energy(j)+abs(signal_r1(16*k_s+j))^2;
        k_s=k_s+1;
    end
end

[ma,index_s]=max(sum_energy);

%Start downsampling from index_s
signal_r2=downsample(signal_r1,16,index_s-1);

signal_r2=signal_r2(7:end-6);  % not sure about this

%Using 128 point DFT to get the time delay and frequency
%Choose 128 point of the signal and change the choice
dft_max=zeros(length(signal_r2)-127,1);
dft_f=zeros(length(signal_r2)-127,1);

for j=1:80
    signal_dft=fft(signal_r2(j:j+127),128);
    [dft_max(j),dft_f(j)]=max(abs(signal_dft));
    clear signal_dft
end
% Estimate the frequency and the time delay

dft_f=(dft_f-1)*16000/128;
[~,dft_delay]=max(dft_max);
dft_delay=dft_delay-40;

%Recover the signal
signal_rec=zeros(800,1);
for k=1:800
    signal_rec(k)=exp(-2*pi*dft_f(1,1)*k*1i/16000)*signal_r2(k+40+dft_delay,1);     %some problem about the formulas given by teacher
end







