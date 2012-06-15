%% Pairwise mutual information

nbins = 20;

MIk = nan(num_cells);
MIh = nan(num_cells);

for i = 1:num_cells
    for j = 1:num_cells
        if count_nans(myosins_rate(:,i)) > 5 && count_nans(myosins_rate(:,j)) > 5
            MIk(i,j) = kernelmi(myosins_rate(:,i)',myosins_rate(:,j)');
            pXY = get_joint_dist(myosins_rate(:,i),myosins_rate(:,j),nbins,nbins);
            MIh(i,j) = mutual_info(pXY);
        end
    end
end
MIk(logical(eye(num_cells))) = NaN;
MIh(logical(eye(num_cells))) = NaN;

%% Plot results

scatter(MIk(:),MIh(:))