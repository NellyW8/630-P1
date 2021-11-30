% Running the system needs to install communications box of Matlab
%The time of the signal is 50 msec
%Before running the code,youou need to type in the frequency uncertainty and time delay into the function "AWGN_channel" when using the code
%The time dffset ranges from -2.5 msec to 2.5 sec
%The range of frequency uncertainty is -1500 Hz to 1500 Hz
%Now the code shows a situation in which time delay and frequency uncertainty is zero, SNR is 100 dB
%Running the code needs to download the file "matlab.mat" in the file
%folder
%Running the code needs to install the "Fixed-Point Designer"

%The Generation of 800 bits signal,which contains CW signal-128 bits,key 8-bits and 664 bits random signal
clear

cw_signal=ones(128,1);
key_signal=zeros(8,1);
content_signal=randi([0 1],664,1);
signal_input=[cw_signal;key_signal;content_signal];

% pi/4 BPSK modulator
for k_s=1:800
    signal_mod(k_s,1)=exp(pi*k_s*1i/4)*(1-2*signal_input(k_s,1));
end 

%Create a RRC filter,with alpha=0.35,This filter covers +/- 3 symbols, with length = 97 taps

rrc_filter=rcosdesign(0.35,6,16);               

%Upsample the signal by 16
signal_mod_up=upsample(signal_mod,16);

%Pass the signal through a lowpass filter
signal_s=conv(signal_mod_up,rrc_filter);

% AWGN Channel This part needs to install coomunications toolbox.
% output=AWGN_channel(signal_s,time delay,frequency uncertainty,phase uncertainty,SNR)
%The time dffset ranges from -2.5 msec to 2.5 sec;The range of frequency uncertainty is -1500 Hz to 1500 Hz
signal_r=AWGN_channel(signal_s,0,0,0,100);

%A/D converter-Transfer the received signal to fixed point data
for j=1:length(signal_r)
    signal_e(j)=(abs(signal_r(j)))^2;
end

norm=max(signal_e);

for j=1:length(signal_r)
    signal_fix(j,1)=(2^15-1)*signal_r(j)/norm;
end

signal_real=int16(real(signal_fix));
signal_imag=int16(imag(signal_fix));
signal_fixr=int16(signal_fix);
signal_fixr1=[signal_real signal_imag];
datasize=int16(length(signal_fixr1));

% Pass the signal through the LPF filter:RRC filter
signal_fix_r1=fixedfilter(signal_fixr1,datasize);
% Find the correct sampling time index_s using energy method
fiaccel sampletime -args {signal_fix_r1} -report -o sampletime_mex
index_s=sampletime(signal_fix_r1);
index_s=index_s-1;
% Start downsampling from index_s
signal_r2=downsample(signal_fix_r1,16,index_s);

%Using 128 point fixed-point DFT to get the time delay and frequency
%Choose 128 point of the signal and change the choice
%don't need to calculate the whole span of DFT

fiaccel dftmax -args {signal_r2} -report -o dftmax_mex
[dft_max1,dft_f1]=dftmax_mex(signal_r2);

dft_f1=(dft_f1-1+4)*16000/128;
[~,dft_delay1]=max(dft_max1);
dft_delay3=int16(dft_delay1-44);
f_est1=dft_f1(dft_delay1,1);
f_est_t1=int16(f_est1-2000);


%Recover the signal
saveco=open('matlab.mat');
savcos=saveco.cosc;
savsin=saveco.sinc;

fiaccel signal_rec -args {signal_r2,dft_delay3,savcos,savsin,f_est_t1} -report -o signal_rec_mex
signal_recovery=signal_rec_mex(signal_r2,dft_delay3,savcos,savsin,f_est_t1);

%Calculate bit error rate and frame error rate
%Transfer the signal to the 0-1 form
for k=int16(1):int16(800)
    if (signal_recovery(k,1)<0)
        signal_dec(k,1)=int16(1);
    else
        signal_dec(k,1)=int16(0);
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
time_delay(1,1)=double(dft_delay3)/800*50;
e_fre(1,1)=f_est_t1;
ber_l(1,1)=ber;
fer_l(1,1)=fer;




%Fixed Point filter
function output=fixedfilter(input,datasize)

% RX filter RRC (Alpha=0.35,+/- 3 symbols 16X-size 97)
FilterRX=[-209,-212,-200,-169,-121,-56,23,114,210,307,398,476,535,569,572,539,468,358,211,29,-181,-411,-650,-887,-1108,-1298,-1444,-1531,-1546,-1477,-1316,-1056,-694,-231,327,973,1695,2476,3299,4141,4980,5793,6556,7246,7843,8327,8685,8904,8978,8904,8685,8327,7843,7246,6556,5793,4980,4141,3299,2476,1695,973,327,-231,-694,-1056,-1316,-1477,-1546,-1531,-1444,-1298,-1108,-887,-650,-411,-181,29,211,358,468,539,572,569,535,476,398,307,210,114,23,-56,-121,-169,-200,-212,-209];
FilterRX=int16(FilterRX);
Filsize=int16(97);
Fildelay=int16(48);
Filterscale=int16(7);


%Expand the filter input to cover filter lag
Intemp=zeros(datasize+Filsize-1,2,'int16');


for i=int16(1):int16(datasize)
    Intemp(i+Fildelay,1)=input(i,1);
    Intemp(i+Fildelay,2)=input(i,2);
end

fiaccel fical -args {Intemp,FilterRX,Filterscale,datasize,Filsize} -report -o fical_mex

output=fical_mex(Intemp,FilterRX,Filterscale,datasize,Filsize);

end

%Channel Function
function signal_r=AWGN_channel(s,delay,frequency,phase,noise)

len=length(s);
signal_delay=[zeros(640,1);s;zeros(640,1)];
signal_r=zeros(len+1280,1);
delay=round(delay/50*800*16);

for k=(641+delay):(length(s)+640+delay)
    signal_r(k)=exp(phase*1i)*exp(2*pi*frequency*k*1i/(16*16000))*signal_delay(k-delay,1);   
end

signal_r=awgn(signal_r,noise);
end