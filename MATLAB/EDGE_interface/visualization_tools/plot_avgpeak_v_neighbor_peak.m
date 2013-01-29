function plot_avgpeak_v_neighbor_peak(peaks,neighborID)

[~,num_cells] = size(peaks);
total_peak_prob = nansum(peaks,2)/num_cells;

p_neighb = zeros(size(total_peak_prob));

index = 0;
for i = 1:num_cells
    neighbors = neighborID{10,1,i};
    if ~isnan(neighbors)
        index = index + 1;
        p_neighb = p_neighb + sum(peaks(:,neighbors),2)/numel(neighbors);
    end
end
p_neighb = p_neighb/index;

figure, plot(total_peak_prob)
hold on, plot(p_neighb,'r-');
figure,plot(p_neighb-total_peak_prob)