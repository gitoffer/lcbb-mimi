function V = sine_vectorfield(freq,phase,t)

V = zeros(numel(t),numel(freq),1,2);
for i = 1:numel(t)
    V(i,:,:,1) = sin(freq*t(i)+phase);
    V(i,:,:,2) = cos(freq*t(i)+phase);
end