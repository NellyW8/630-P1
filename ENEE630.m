% section 1
data = zeros(1,800);
X = zeros(1,800);
for i = 1:128
    data(i) = 1;
end
for i = 129:136
    data(i) = 0;
end
for i = 137:800
    data(i) = randi([0, 1]);
end
for i = 1:800
    X(i) = exp(1j*pi*i/4)*(1 - 2*data(i));
end
rolloff = 0.35; % Filter rolloff
span = 6;       % Filter span
sps = 16;        % Samples per symbol
rrcFilter = rcosdesign(rolloff,span,sps);
X1 = upfirdn(X,rrcFilter,sps);
S = lowpass(X1,pi/16);

% section 2
in = ones(size(S));
out = awgn(in,10,'measured');
size(out,2)
for i = 1:size(out,2)
    out(i) = out(i)-1;
end