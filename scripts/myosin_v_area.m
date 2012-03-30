
%% Generate correlations

areas_sm = smooth2a(squeeze(areas(:,zslice,:)),1,0);
myosins_sm = smooth2a(squeeze(myosins(:,zslice,:)),1,0);
major = squeeze(majors(:,zslice,:));
minor = squeeze(minors(:,zslice,:));
orientation = squeeze(orientations(:,zslice,:));
anisotropy = squeeze(anisotropies(:,zslice,:));

areas_rate = -central_diff_multi(areas_sm,1,1);
myosins_rate = central_diff_multi(myosins_sm);

wt = 7;
correlations = nanxcorr(myosins_rate,areas_rate,wt,1);
%% Scatter plots of myosin versus area
signal = myosins_sm;
signal2 = areas_sm;

Xext = 1000;
Yext = 400;
um_per_px = .19;

% Make all leading 0's NaN
for i = 1:num_cells
    foo = signal(:,i);
    I = find(foo>0,1);
    signal(1:I,i) = NaN;
    signal2(1:I,i) = NaN;
end

rate = central_diff_multi(signal,1,1);
rate2 = -central_diff_multi(signal2,1,1);

% Plot scatter plots/2D histograms
scatter(signal(:),rate2(:)),xlabel('Myosin'),ylabel('Constriction rate')
figure,scatter(myosins_sm(:),rate2(:)),xlabel('Myosin rate'),ylabel('Constriction rate')
scatter(rate(:),rate2(:)),xlabel('Myosin rate'),ylabel('Constriction rate')

[histmat,xedges,yedges] = hist2(signal(:),rate2(:));
figure,pcolor(xedges,yedges,histmat');
colorbar;xlabel('Myosin'),ylabel('Constriction rate');
keyboard
[histmat,xedges,yedges] = hist2(rate(:),rate2(:));
figure,pcolor(xedges,yedges,histmat');
colorbar;xlabel('Myosin rate'),ylabel('Constriction rate');

[histmat,xedges,yedges] = hist2(signal(:),signal2(:));
figure,pcolor(xedges,yedges,histmat');
colorbar;xlabel('Myosin'),ylabel('Area');

%% Scatter plots of myosin versus area
signal = major;
signal2 = minor;

% Make all leading 0's NaN
for i = 1:num_cells
    foo = signal(:,i);
    I = find(foo>0,1);
    signal(1:I,i) = NaN;
    signal2(1:I,i) = NaN;
end

rate = central_diff_multi(signal,1,1);
rate2 = -central_diff_multi(signal2,1,1);

% Plot scatter plots/2D histograms
[histmat,xedges,yedges] = hist2(signal(:),rate2(:));
figure,pcolor(xedges,yedges,histmat');
colorbar;xlabel('Myosin'),ylabel('Constriction rate');

[histmat,xedges,yedges] = hist2(rate(:),rate2(:));
figure,pcolor(xedges,yedges,histmat');
colorbar;xlabel('Myosin rate'),ylabel('Constriction rate');

[histmat,xedges,yedges] = hist2(signal(:),signal2(:));
figure,pcolor(xedges,yedges,histmat');
colorbar;xlabel('Myosin'),ylabel('Area');

%%
for t = 20:40
    clf
    feature_vec = cat(2, ...
        squeeze(areas_sm(t,:))', ...
        squeeze(areas_rate(t,:))', ...
        squeeze(myosins_sm(t,:))', ...
        squeeze(myosins_rate(t,:))', ...
        squeeze(anisotropy(t,:))', ...
        squeeze(orientation(t,:))', ...
        squeeze(major(t,:))', ...
        squeeze(minor(t,:))');
    
    [Idx,centers,sumd] = kmeans(feature_vec,2);
    
    for i = 1:num_cells
        if Idx(i) == 1
            patch(vx{t,i},vy{t,i},'r');axis ij equal;
        else
            patch(vx{t,i},vy{t,i},'b');axis ij equal;
        end
    end
    F(t-19) = getframe;
    
end
