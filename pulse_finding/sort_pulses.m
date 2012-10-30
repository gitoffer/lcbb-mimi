function sorted = sort_pulses(pulses)
%SORT_PULSES Sorts pulses from individual embryos according to a percentile
% cutoffs.
%
% SYNOPSIS: sorted = sorted_pulse(pulses)
% 
% OUTPUT: sorted - a cell array, sorted{1} - Top
%                                sorted{2} - Middle
%                                sorted{3} - Bottom
%
% xies@mit.edu Oct 2012

% num_pulses = numel(pulses);

which = unique([pulses.embryo]);
sorted = cell(1,3);
sorted{1} = []; sorted{2} = []; sorted{3} = [];

for i = which
    
    pulses_this_embryo = pulses([pulses.embryo] == i);
    pulseID_this_embryo = find([pulses.embryo] == i);
    
    pulse_size = [pulses_this_embryo.size];
    [sorted_sizes,sortedID] = sort(pulse_size,2,'descend');
    
    cutoffs = prctile(sorted_sizes,[25 75]);
    sortedID = pulseID_this_embryo(sortedID);
    
    top = sortedID(1:find(sorted_sizes < cutoffs(2),1));
    middle = sortedID(find(sorted_sizes < cutoffs(2),1) + 1 : ...
        find(sorted_sizes < cutoffs(1),1));
    bottom = sortedID(find(sorted_sizes < cutoffs(1),1) + 1:end);
    
    sorted{1} = [sorted{1} pulses(top)];
    sorted{2} = [sorted{2} pulses(middle)];
    sorted{3} = [sorted{3} pulses(bottom)];
    
end

end