function signal_r=AWGN_channel(s,delay,frequency,phase,noise)

len=length(s);
signal_delay=[zeros(640,1);s;zeros(640,1)];
signal_r=zeros(len+1280,1);

for k=(641+delay):(length(s)+640+delay)
    signal_r(k)=exp(phase*1i)*exp(2*pi*frequency*k*1i/16000)*signal_delay(k-delay,1);   
end

signal_r=awgn(signal_r,noise);



