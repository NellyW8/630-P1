function outputs1=signal_rec(inputs,delay,savcos,savsin,f_est_t)

outputs=zeros(800,2,'int32');
outputs1=zeros(800,2,'int32');
for k=int16(1):int16(800)
    sign_mod=MUL16(f_est_t,k+43+delay);
    cos1=savcos(mod(sign_mod,16000)+1,1);
    sin1=savsin(mod(sign_mod,16000)+1,1);
    %cos1=(2^15-1)*cos(2*pi*f_est_t*(k+44+delay)/16000);
    %sin1=(2^15-1)*sin(2*pi*f_est_t*(k+44+delay)/16000);
    sign_mod1=MUL16(int16(2000),k);
    cos2=savcos(mod(sign_mod1,16000)+1,1);
    sin2=savsin(mod(sign_mod1,16000)+1,1);
    %cos2=(2^15-1)*cos(2*pi*2000*k/16000);
    %sin2=(2^15-1)*sin(2*pi*2000*k/16000);

    outputs(k,1)=ADD32(MUL16(cos1,inputs(k+43+delay,1)),MUL16(sin1,inputs(k+43+delay,2)));
    outputs(k,1)=SHIFT(outputs(k,1),15);
    outputs(k,2)=SUB32(MUL16(cos1,inputs(k+43+delay,2)),MUL16(sin1,inputs(k+43+delay,1)));
    outputs(k,2)=SHIFT(outputs(k,2),15);

    outputs1(k,1)=ADD32(MUL16(cos2,outputs(k,1)),MUL16(sin2,outputs(k,2)));
    outputs1(k,1)=SHIFT(outputs1(k,1),15);
    outputs1(k,2)=SUB32(MUL16(cos2,outputs(k,2)),MUL16(sin2,outputs(k,1)));
    outputs1(k,2)=SHIFT(outputs1(k,2),15);
end
