% Running the system needs to install communications box of Matlab
%The time of the signal is 50 msec
%Before running the code,youou need to type in the frequency uncertainty and time delay into the function "AWGN_channel" when using the code
%The time dffset ranges from -2.5 msec to 2.5 sec,so "time delay"ranges from -640 points to 640 points
%The range of frequency uncertainty is -1500 Hz to 1500 Hz
%Now the code shows a situation in which time delay and frequency uncertainty is zero, SNR is 100 dB
%The Generation of 800 bits signal,which contains CW signal-128 bits,key 8 bits and 664 bits random signal

for loop=1:100

cw_signal=ones(128,1);
key_signal=zeros(8,1);
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
% output=AWGN_channel(signal_s,time delay,frequency uncertainty,phase uncertainty,SNR)
signal_r=AWGN_channel(signal_s,0,0,0,1);

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

signal_r2=signal_r2(7:end-6);  % not sure about this,how to account for the delay caused by the filter   

%Using 128 point DFT to get the time delay and frequency
%Choose 128 point of the signal and change the choice
dft_max=zeros(80,1);
dft_f=zeros(80,1);

for j=1:80
    signal_dft=fft(signal_r2(j:j+127),128);
    [dft_max(j),dft_f(j)]=max(abs(signal_dft));
    clear signal_dft
end

%Compare-there is problem for choosing time delay
% Estimate the frequency and the time delay

dft_f=(dft_f-1)*16000/128;
f_est=mean(dft_f);
[~,dft_delay]=max(dft_max);
dft_delay1=(dft_delay-41)*16+index_s-1;
dft_delay2=dft_delay-41;

%Recover the signal-some questions about it
signal_rec=zeros(800,1);
signal_rec_ori=zeros(800,1);
for k=1:800
    signal_rec(k)=exp(-2*pi*(f_est)*(k+40)*1i/16000)*signal_r2(k+40+dft_delay2,1);     %some problem about the formulas given by teacher
    signal_rec_ori(k)=(1-signal_rec(k))/2;
end

%Calculate bit error rate and frame error rate

%Transfer the signal to the 0-1 form
for k=1:800
    if (signal_rec(k)<0)
        signal_dec(k,1)=1;
    else
        signal_dec(k,1)=0;
    end
end

%Calculate BER
[number,ber]=biterr(signal_input,signal_dec);

% Calculate FER
if number==0
    fer=0;
else
    fer=1;
end

%save data from this frame
time_delay(loop,1)=dft_delay2;
e_fre(loop,1)=f_est;
ber_l(loop,1)=ber;
fer_l(loop,1)=fer;

clearvars -except time_delay e_fre ber_l fer_l loop
end

%Calculate the average of estimation, BER and FER of the 100 times circle
mean_delay=mean(time_delay);
mean_f=mean(e_fre);
mean_ber=mean(ber_l);
mean_fer=mean(fer_l);

function signal_r=AWGN_channel(s,delay,frequency,phase,noise)

len=length(s);
signal_delay=[zeros(640,1);s;zeros(640,1)];
signal_r=zeros(len+1280,1);

for k=(641+delay):(length(s)+640+delay)
    signal_r(k)=exp(phase*1i)*exp(2*pi*frequency*k*1i/(16*16000))*signal_delay(k-delay,1);   
end

signal_r=awgn(signal_r,noise);



