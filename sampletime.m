function index_s=sampletime(input)

% Find the correct sampling time index_s using energy method
sum_energy=zeros(16,1,'int64');
for j=int16(1):int16(16)
    k_s=int16(0);
    while((16*k_s+j)<=int16(length(input)))
        localsum=ADD32(MUL16(input(16*k_s+j,1),input(16*k_s+j,1)),MUL16(input(16*k_s+j,2),input(16*k_s+j,2)));
        sum_energy(j)=ADD32(sum_energy(j),localsum);
        k_s=int16(k_s+1);
    end
end

[~,index_s]=max(sum_energy);