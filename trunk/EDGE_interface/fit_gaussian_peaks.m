function [pulse,varargout] = fit_gaussian_peaks(Y,time,timeframe,cellID,c)
%FIT_GAUSSIAN_PEAKS Fits peaks as Gaussians, and puts the information into
%a useful format.
%
% pulse = fit_gaussian_peaks(Y,time,timeofinterest);
%
% INPUT: Y - to be fitted
%        time - the time frame corresponding to Y
%        timeofinterest - [t0 tf]
%
% OUTPUT: pulse.cell - the cell ID
%         pulse.curve - the actual fitted curve
%         pulse.size - height of the pulse
%         pulse.center - center of the pulse
%         pulse.frame - frame (index)
%         pulse.time - the actual real-time
%
% xies@mit.edu Aug 2012.

[num_frames,num_cells] = size(Y);
min_t = timeframe(1);
max_t = timeframe(2);

num_peaks = 0;

if nargout > 1, cell_fit = 1; else cell_fit = 0; end

if cell_fit
    fits = nan(size(Y));
end

for i = 1:num_cells
    
    t = time(:,i);
    f0 = find(min_t < t, 1, 'first');
    ff = find(max_t > t, 1, 'last');
    frame = f0:ff;
    
    t = t(min_t < t & t < max_t);
    if any(t ~= time(frame,i)), error('Wrong time indexing... ERROR!'); end
    
    y = Y(f0:ff,i);
    
    if numel(y(~isnan(y))) > 20 && any(y > 0)
        
        y = interp_and_truncate_nan(y);
        y = y.*(y>0);
        t = t(1:numel(y))';
        
        lb = [0 t(1) 0];
        ub = [Inf t(end) t(4)-t(1)];
        
        gauss_p = iterative_gaussian_fit(y,t,0.2,lb,ub);
        if cell_fit
            this_fit = synthesize_gaussians(t,gauss_p);
%             if ff - f0 + 1 ~= size(t)
%                 ff = ff - (ff+f0-1-numel(t));
%             end
            fits(f0:(f0+numel(t) - 1),i) = this_fit;
        end
        
        for j = 1:size(gauss_p,2)
            if gauss_p(2,j) > -300
                
                l = 5;
                r = 10;
                
                num_peaks = num_peaks + 1;
                shift = findnearest(t(1),time(:,i));
                left = max(shift + findnearest(gauss_p(2,j),t) - l,1);
                right = min(shift + findnearest(gauss_p(2,j),t) + r,num_frames);
                
                x = time(left:right,i);
                fitted_y = synthesize_gaussians(x,gauss_p(:,j));
                
                pulse(num_peaks).curve = fitted_y;
                pulse(num_peaks).aligned_time = x - gauss_p(2,j);
                
                if shift + findnearest(gauss_p(2,j),t) - l < 1
                    fitted_y = [nan(1-(shift + findnearest(gauss_p(2,j),t) - l),1);fitted_y];
                    x = [nan(1-(shift + findnearest(gauss_p(2,j),t) - l),1);x];
                end
                
                if shift + findnearest(gauss_p(2,j),t) + r > num_frames
                    fitted_y = [fitted_y;nan((shift + findnearest(gauss_p(2,j),t) + r) - num_frames,1)];
                    x = [x;nan((shift + findnearest(gauss_p(2,j),t) + r) - num_frames,1)];
                end
                
                pulse(num_peaks).cell = i;
                pulse(num_peaks).cellID = cellID(i);
                pulse(num_peaks).embryo = c(i);
                pulse(num_peaks).curve_padded = fitted_y;
                pulse(num_peaks).size = gauss_p(1,j);
                pulse(num_peaks).center = gauss_p(2,j);
                pulse(num_peaks).center_frame = findnearest(gauss_p(2,j),t);
                pulse(num_peaks).frame = left:right;
                pulse(num_peaks).aligned_time_padded = x;
                
            end
        end 
    end    
end

if cell_fit
    varargout{1} = fits;
end
