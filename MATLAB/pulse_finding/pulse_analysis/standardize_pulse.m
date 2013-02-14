function pulse_sd = standardize_pulse(pulse)
%STANDARDIZE_PULSE Creates a field in the pulse structure corresponding to
% the percentile-ranking of each pulse in the distribution of all pulse
% sizes within a single embryo.
%
% SYNOPSIS: pulse_sd = standardize_pulse(pulse);
%
% xies@mit.edu

pulse_sd = pulse;
num_embryos = numel(unique([pulse.embryoID]));

for i = 1:num_embryos
    sizes = [pulse([pulse.embryoID] == i).size];
    bins = prctile(sizes,1:100);
    [~,bin] = histc(sizes,bins);
    pulseID = [pulse([pulse.embryoID] == i).pulseID];
    for j = 1:numel(bin)
        [pulse_sd(pulseID(j)).percentile] = bin(j);
    end
end

end