function abs=getabs(input)
abs=zeros(length(input),1,'int32');
for k=int16(1):int16(length(input))
    in1=SHIFT(input(k,1),9);
    in2=SHIFT(input(k,2),9);
    abs(k,1)=ADD32(MUL16(in1,in1),MUL16(in2,in2));
    %localabs=ADD32(MUL32(input(k,1),input(k,1)),MUL32(input(k,2),input(k,2)));
    %abs(k,1)=SHIFT_LONG(localabs,15);
end