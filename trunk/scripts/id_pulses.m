%%ID_PULSES

%% Interpolate, and fit Gaussians for single cells
cellID = randi(sum(num_cells(1)));
% cellID = 56;
% cellID = 78;

myosin_sm = myosins(1:end,cellID);
myosin_rate = myosins_rate(1:end,cellID);
myosin_interp = interp_and_truncate_nan(myosin_sm);
% myosin_nobg = bgsutract4myosin(myosin_interp,'gaussian',{x});
myosin_nobg = myosin_interp;
myosin_nobg_rect = myosin_nobg;
myosin_nobg_rect(myosin_nobg < 0) = 0;

% time domain
t = ((1:numel(myosin_interp))-input(1).tref)*input(1).dt;

lb = [0;t(1);10];
ub = [Inf;t(end);20];
gauss_p = iterative_gaussian_fit(myosin_interp,t,0.01,lb,ub,'on');
fitted_y = synthesize_gaussians(gauss_p,t);
%%

n_peaks = size(gauss_p,2)-1
x = ((1:60)-input(1).tref)*input(1).dt;

figure;
subplot(2,1,1)
h1 = plot(x,myosin_sm,'r-');
title(['Original myosin time-series in cell #' num2str(cellID)]);
subplot(2,1,2)
h2 = plot(t,myosin_interp,'k-');
hold on,plot(t,lsq_exponential(gauss_p(:,1),t),'k-');
hold on,plot(t,synthesize_gaussians_withbg(gauss_p,t),'r-');

% Plot individual peaks
C = varycolor(n_peaks);
C = C(randperm(n_peaks),:);
for i = 1:n_peaks
    hold on
    plot(t,synthesize_gaussians(gauss_p(:,1+i),t),'Color',C(i,:));
end
% hold on,plot(x,cell_fits(:,cellID));
% legend('Myosin rate','Rate rectified',['Fitted peaks (' num2str(n_peaks) ')'])
title(['Myosin rate in cell #' num2str(cellID)]);

%% Make movie
figure
P = plot_peak_color(gauss_p(:,2:end),t);
F = make_cell_img(vertices_x,vertices_y,1:60,4,IDs(cellID),input(c(cellID)),{'Membranes','Myosin'},P);
movie2avi(F,['~/Desktop/EDGE processed/Embryo 4/cell_movies/cell_' num2str(cellID) '_1-60']);

%%

figure,
normplot((myosin_nobg_rect-synthesize_gaussians(gauss_p,t)).^2);
% plotyy(1:30,areas_rate(1:30,cellID),1:300,areas_sm(1:30,cellID))
% legend('Constriction rate','Area')
saveas(h1,['~/Desktop/EDGE Processed/Embryo 4/peak_gauss/cells/cell_' num2str(cellID)]);

%% Fit for all cells

[pulse,cell_fits] = fit_gaussian_peaks(myosins,time_mat,[-300 1000],IDs,c,'on');
num_peaks = numel(pulse);

%% Try to correlate self peaks and neighbor peaks?

wt = 7;
neighbor_peak_hand = neighbor_msmt(peaks_hand,neighborID);
peaks_corr = nan(num_cells,2*wt+1);

for cellID = 1:num_cells
    
    if any(neighbor_peak_hand{cellID} ~= 0)
        
        p_neighb = sum(neighbor_peak_hand{cellID},2)/size(neighbor_peak_hand{cellID},2);
        
        peaks_corr(cellID,:) = nanxcorr(peaks_hand(:,cellID),p_neighb,wt);
        
    end
end

figure,pcolor(-wt:wt,1:num_cells,peaks_corr),colorbar

%% Posterior probability?

p_neighb_me = nan(num_cells,10);
coupling = zeros(num_cells);

for cellID = 1:num_cells
    
    if any(neighbor_peak_hand{cellID} ~= 0)
        for j = 1:numel(neighborID{1,cellID})
            %         p_neighb = sum(neighbor_peak_hand{cellID},2)/size(neighbor_peak_hand{cellID},2);
            %         p_neighb = sum(any(neighbor_peak_hand{cellID},2))/num_frames;
            p_me = sum(peaks_hand(:,cellID))/num_frames;
            p_joint = sum(neighbor_peak_hand{cellID}(:,j) & peaks_hand(:,cellID))/num_frames;
            p_neighb_me(cellID,j) = p_joint/p_me;
            my_neighb = neighborID{1,cellID};
            coupling(cellID,my_neighb(j)) = p_joint/p_me;
        end
    end
    
end

plot(p_neighb_me,'b*')
figure,pcolor(coupling)


% %% Fit Gaussians for all
% max_frame = 30; t0 = 20;
% peaks = nan(max_frame,sum(num_cells));
% binary_peaks = nan(max_frame,sum(num_cells));
% % myosins_sm_norm = bsxfun(@rdivide,myosins_fuzzy_sm,nanmax(myosins_fuzzy_sm));
% % myosins_rate_norm = central_diff_multi(myosins_sm_norm,1:num_frames);
% clear individual_peaks,num_peaks = 0;
% clear peak_locations gauss_parameters peak_cells
% clear peak_sizes peak_centers pulse
% 
% for i = 1:sum(num_cells)
%     
%     myosin_sm = myosins_rate(t0+1:t0+max_frame,i);
%     
%     if numel(myosin_sm(~isnan(myosin_sm))) > 20 ...
%             && any(myosin_sm > 0)
%         
%         myosin_interp = interp_and_truncate_nan(myosin_sm);
%         x = (time(t0+1:t0+numel(myosin_interp)))*dt(c(i));
% %         x = (1:numel(myosin_interp)) + t0;
% %         myosin_nobg = bgsutract4myosin(myosin_interp,'gaussian',{x});
%         myosin_nobg = myosin_interp;
%         myosin_nobg_rect = myosin_nobg;
%         myosin_nobg_rect(myosin_nobg < 0) = 0;
%         
%         lb = [0 x(1) 0];
%         ub = [Inf x(end) 15];
%         gauss_p = iterative_gaussian_fit(myosin_nobg_rect,x,0.1,lb,ub);
%         %         left = max(fix(gauss_p(2,:)) - fix(gauss_p(3,:)),1);
%         %         right = min(fix(gauss_p(2,:)) + fix(gauss_p(3,:)),num_frames);
%         % %         if i == 61
%         % %             keyboard
%         % %         end
%         %         for j = 1:numel(left)
%         %             %             keyboard
%         %             peaks(left(j):right(j),i) = 1;
%         %         end
%         foo = synthesize_gaussians(x,gauss_p);
%         if numel(foo) ~= max_frame, foo = [foo, nan(1,max_frame-numel(foo))]; end
%         peaks(:,i) = foo;
%         gauss_parameters{i} = gauss_p;
%         
% %         keyboard
%         for j = 1:size(gauss_p,2)
%             if gauss_p(2,j) < 0
%                 
%                 num_peaks = num_peaks + 1;
% %                 left = max(fix(gauss_p(2,j) - 3*gauss_p(3,j)),1);
%                 
%                 left = max(findnearest(gauss_p(2,j),x) - 5,1);
% %                 right = min(fix(gauss_p(2,j) + 3*gauss_p(3,j)),num_frames);
%                 right = min(findnearest(gauss_p(2,j),x) + 10,num_frames);
%                 x = time(left:right)*dt(c(i));
%                 
%                 if i == 67
%                 keyboard
%                 end
%                 individual_peaks{num_peaks} = ...
%                     synthesize_gaussians(x,gauss_p(:,j));
%                 peak_locations{num_peaks} = left:right;
%                 peak_cells(num_peaks) = i;
%                 peak_sizes(num_peaks) = gauss_p(1,j);
%                 peak_centers(num_peaks) = gauss_p(2,j);
%                 
%                 pulse(num_peaks).size = gauss_p(1,j);
%                 pulse(num_peaks).center = gauss_p(2,j);
%                 pulse(num_peaks).cell = i;
% %                 pulse(num_peaks).center = gauss_p(2,j);
%                 
%             end
%         end
%     end
% end