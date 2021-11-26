function abs=getabs(input)
abs=zeros(length(input),1,'int64');
for k=1:length(input)
    abs(k,1)=ADD32(MUL32(input(k,1),input(k,1)),MUL32(input(k,2),input(k,2)));
end