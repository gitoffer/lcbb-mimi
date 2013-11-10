function idx = dist_sampler(data,dist,bins)
%DIST_SAMPLER
%
% idx = dist_sampler(data,dist,bins)

nbins = numel(bins);
idx = cell(1,nbins);
for i = 1:nbins
    
    I = find(data == bins(i));
    if numel(I) > 0
        idx{i} = I(randi( numel(I), 1, dist(i)));
    else
        idx{i} = [];
    end
    
end

idx = [idx{:}];

end