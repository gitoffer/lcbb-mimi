function sorted = sort_pulses(pulses)
%BIN_PULSES Bin pulses from individual embryos according to a percentile
% cutoff - quartiles (only one supported right now).
%
% SYNOPSIS: sorted = sorted_pulse(pulses)
% 
% OUTPUT: sorted - a cell array, sorted{1} - 76-100
%                                sorted{2} - 51-75
%                                sorted{3} - 26-50
%                                sorted{4} - 1-25
%
% xies@mit.edu Oct 2012

% num_pulses = numel(pulses);

which = unique([pulses.embryo]);
sorted = cell(1,4);
sorted{1} = []; sorted{2} = []; sorted{3} = [];

for i = which
    
    pulses_this_embryo = pulses([pulses.embryo] == i);
    pulseID_this_embryo = find([pulses.embryo] == i);
    
    pulse_size = [pulses_this_embryo.size];
    [sorted_sizes,sortedID] = sort(pulse_size,2,'descend');
    
    cutoffs = prctile(sorted_sizes,[25 50 75]);
    sortedID = pulseID_this_embryo(sortedID);
    
    top = sortedID(1:find(sorted_sizes < cutoffs(3),1));
    top_middle = sortedID(find(sorted_sizes < cutoffs(3),1) + 1 : ...
        find(sorted_sizes < cutoffs(2),1));
    bottom_middle = sortedID(find(sorted_sizes < cutoffs(2),1) + 1 : ...
        find(sorted_sizes < cutoffs(1),1));
    bottom = sortedID(find(sorted_sizes < cutoffs(1),1) + 1:end);
    
    sorted{1} = [sorted{1} pulses(top)];
    sorted{2} = [sorted{2} pulses(top_middle)];
    sorted{3} = [sorted{3} pulses(bottom_middle)];
    sorted{4} = [sorted{4} pulses(bottom)];
    
end

end