%ID_PULSES
%% Generate correlations
% areas = areas(40:end,:,:);
% myosin = myosin(40:end,:,:);

wt = 10;
correlations = nanxcorr(myosins_rate,areas_rate,wt,1);
pcolor(correlations)
figure,errorbar(-wt:wt,nanmean(correlations,1),nanstd(correlations,1,1));

%% Get individual correlations
cellID = 80;

area_sm = smooth2a(squeeze(areas(:,cellID)),1,0);
myosin_sm = smooth2a(squeeze(myosins(:,cellID)),1,0);

area_rate = -central_diff_multi(area_sm,1,1);
myosin_rate = central_diff_multi(myosin_sm,1,1);

wt = 20;
correlation = nanxcorr(area_rate,myosin_rate,wt,1);

%% Plot individual correlations
figure,showsub(@plot,{1:num_frames,area_sm},['Cell area for cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames,myosin_sm},['Myosin found in cell #' num2str(cellID)],'' ...
    );
figure,showsub(@plot,{1:num_frames,area_rate,'r-'}, ...
    ['Constriction in cell #' num2str(cellID)],'', ...
    @plot,{1:num_frames,myosin_rate,'r-'}, ...
    ['Myosin change in cell #' num2str(cellID)],'' ...
    );

figure,plot(-wt:wt,correlation);
title('Cross correlation between constriction rate and myosin')

%% Interpolate, bg subtract, and fit Gaussians
cellID = 61;
myosin_sm = myosins_sm(:,cellID);
myosin_interp = interp_and_truncate_nan(myosin_sm);
x = 1:numel(myosin_interp);
myosin_nobg = bgsutract4myosin(myosin_interp,'gaussian',{x});
% myosin_nobg = myosin_nobg - min(myosin_nobg(:));

lb = [0 0 0];
ub = [Inf num_frames 20];
gauss_p = iterative_gaussian_fit(myosin_nobg,x,0.1,lb,ub);
figure;
h = plot(myosin_interp,'r-');
hold on,plot(myosin_nobg,'g-');
hold on,plot(synthesize_gaussians(1:59,gauss_p));
legend('Fitted peaks','Original signal','BG subtraction')
title(['Cell #' num2str(cellID)]);
saveas(h,['~/Desktop/Pulse finding/cell_' num2str(cellID)]);

%% Fit Gaussians for all
peaks = zeros(size(myosins_sm));
for i = 1:num_cells
    myosin_sm = myosins_sm(:,i);
    if numel(myosin_sm(~isnan(myosin_sm))) > 1 && any(myosin_sm > 0)
        myosin_interp = interp_and_truncate_nan(myosin_sm);
        x = 1:numel(myosin_interp);
        myosin_nobg = bgsutract4myosin(myosin_interp,'gaussian',{x});
%         myosin_nobg = myosin_nobg - min(myosin_nobg(:));
        
        lb = [0 0 0];
        ub = [Inf num_frames 20];
        gauss_p = iterative_gaussian_fit(myosin_nobg,x,0.1,lb,ub);
        left = max(fix(gauss_p(2,:)) - fix(gauss_p(3,:)),1);
        right = min(fix(gauss_p(2,:)) + fix(gauss_p(3,:)),num_frames);
%         if i == 61
%             keyboard
%         end
        for j = 1:numel(left)
            %             keyboard
            peaks(left(j):right(j),i) = 1;
        end
        
    end
end

%% Plot peaks and the neighbors' peaks

cellID =60;
neighbors = neighborID{1,cellID};
% plot(peaks(:,center),'k-');
% hold on;
figure
subplot(2,1,1);
plot(peaks(:,cellID));
hold on
p_neighb = sum(peaks(:,neighbors),2)./6;
plot(p_neighb,'r-');
subplot(2,1,2);
pcolor(peaks(:,neighbors)');

%%

peaks = logical(peaks);

response = areas_rate.*peaks;
response(response == 0) = NaN;








