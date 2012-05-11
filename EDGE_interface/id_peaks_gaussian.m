function peaks = id_peaks_gaussian(myosins_sm)
[num_frames,num_cells] = size(myosins_sm);

% Fit Gaussians for all
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
        all = synthesize_gaussians(1:num_frames,gauss_p);
        peaks(:,i) = all > 200;
%         left = max(fix(gauss_p(2,:)) - fix(gauss_p(3,:)),1);
%         right = min(fix(gauss_p(2,:)) + fix(gauss_p(3,:)),num_frames);
%         %         if i == 61
%         %             keyboard
%         %         end
%         for j = 1:numel(left)
%             peaks(left(j):right(j),i) = 1;
%         end
        
    end
end


end