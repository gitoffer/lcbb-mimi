function [order,labels,labels_ordered,pulses] = load_gedas_fun(name,pulses)
% LOAD_GEDAS_FUN Function to load .txt files imported from GEDAS Studio.%
%
% USAGE: [order,labels,labels_ordered,pulse] = load_gedas_fun(name,pulse);
%
% xies@mit.edu

% Load datastream
cluster_flatfile = importdata(name);
num_pulses = numel(pulses);

% Extract order + labels
order = cluster_flatfile(:,1);
labels = cluster_flatfile(:,2);
labels = labels + 1;
labels_ordered = zeros(1,num_pulses);

%modify pulse structure
for i = 1:num_pulses
    pulses(order(i)).cluster_label = labels(i);
    labels_ordered(order(i)) = labels(i);
end

end