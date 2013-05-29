%% cta_clustering Cluster cta embryo by area (constricting v. expanding)

cta_areas8 = areas(:,[IDs.which] == 8);
cta_areas9 = areas(:,[IDs.which] == 9);
cta_areas10 = areas(:,[IDs.which] == 10);

%%

D8 = pdist( cta_areas8(:,:)' ,@nan_eucdist);
D9 = pdist( cta_areas9(:,:)' ,@nan_eucdist);
D10 = pdist( cta_areas10(:,:)' ,@nan_eucdist);

Z8 = linkage(D8,'complete'); Z9 = linkage(D9,'complete'); Z10 = linkage(D10,'complete');

c8 = cluster(Z8,'maxclust',2);
c9 = cluster(Z9,'maxclust',2);
c10 = cluster(Z10,'maxclust',2);

figure, pcolor( cat(2,cta_areas8(:,c8==1),cta_areas8(:,c8==2))' ), shading flat
figure, pcolor( cat(2,cta_areas9(:,c9==1),cta_areas9(:,c9==2))' ), shading flat
figure, pcolor( cat(2,cta_areas10(:,c10==1),cta_areas10(:,c10==2))' ), shading flat

%%

