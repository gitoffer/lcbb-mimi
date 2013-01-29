function sub_pulse = subID_pulses(pulse,logical)
%SUBID_PULSES 
%
% pulse = subID_pulses(pulse,condition);
%
% xies@mit.edu

sub_pulse = pulse(logical);
num_peaks = numel(sub_pulse);
for i = 1:num_peaks
    sub_pulse(i).subID = i;
end

end