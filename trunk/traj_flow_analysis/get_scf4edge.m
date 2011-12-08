function [C,R] = get_scf4edge(m,frameID,dR,Rmax,opt)

nbins = numel(0:dR:Rmax);

[x,y] = get_cell_trajectory(m,1,frameID);
[vx,vy] = centroid_velocity(x,y);

C = zeros(1,nbins);
for i = 1:frameID(end)-1
    centroids = cat(2,x(i,:)',y(i,:)');
    V = cat(2,vx(i,:)',vy(i,:)');
    tic
    [C(i,:),R] = spatial_correlation_function(V,centroids,dR,Rmax,opt);
end
end