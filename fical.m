function output=fical(Intemp,FilterRX,Filterscale,datasize,Filsize)
output=zeros(datasize,2,'int16');

%Do convolution in fixed-point
for i=1:datasize
    sumI=int64(0);
    sumQ=int64(0);
    for j=1:Filsize
        localsum=MUL16(Intemp(i+j-1,1),FilterRX(j));
        localsum=SHIFT(localsum,15);
        sumI=ADD32(localsum,sumI);
        
        localsum=MUL16(Intemp(i+j-1,2),FilterRX(j));
        localsum=SHIFT(localsum,15);
        sumQ=ADD32(localsum,sumQ);
    end
    
    output(i,1)=int16(SHIFT(sumI,Filterscale));
    output(i,2)=int16(SHIFT(sumQ,Filterscale));
    
end