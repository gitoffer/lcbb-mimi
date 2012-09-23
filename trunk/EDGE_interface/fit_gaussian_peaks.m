function [pulse,varargout] = fit_gaussian_peaks(Y,time,timeframe,cellID,c,bg)
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

if nargin < 6, bg = 'off'; end
if strcmpi(bg,'on'), background = 1;
else background = 0; end

[num_frames,num_cells] = size(Y);
min_t = timeframe(1);
max_t = timeframe(2);

% Keep track of total number
num_peaks = 0;

if nargout > 1, cell_fit = 1; else cell_fit = 0; end

if cell_fit
    fits = nan(size(Y));
end

for i = 1:num_cells
    
    % Need to convert frame to actual time using the time bounds given
    t = time(:,i);
    f0 = find(min_t < t, 1, 'first');
    ff = find(max_t > t, 1, 'last');
    frame = f0:ff;
    
    % Generate "true time" vector, t
    t = t(min_t < t & t < max_t);
    if any(t ~= time(frame,i)), error('Wrong time indexing... ERROR!'); end
    
    % Crop the curve using time bounds
    y = Y(f0:ff,i);
    
    % Reject any curves without at least 20 data points
    if numel(y(~isnan(y))) > 20 && any(y > 0)
        
        % Interpolate and rectify
        y = interp_and_truncate_nan(y);
        y(y < 0) = 0;
        t = t(1:numel(y))';
        
        % Establish the lower bounds of the constraints
        lb = [0;t(1)-abs(t(2)-t(1));10];
        try ub = [Inf;t(end);25];
        catch err
            keyboard
        end
        
        gauss_p = iterative_gaussian_fit(y,t,0.05,lb,ub,bg);
        
        if cell_fit
            this_fit = synthesize_gaussians(gauss_p,t);
%             if ff - f0 + 1 ~= size(t)
%                 ff = ff - (ff+f0-1-numel(t));
%             end
            fits(f0:(f0+numel(t) - 1),i) = this_fit;
        end
        
        if background, idx = 2; else, idx = 1; end
        
        for j = idx:size(gauss_p,2)
            if gauss_p(2,j) > -300
                
                l = 7;
                r = 10;
                
                num_peaks = num_peaks + 1;
                shift = findnearest(t(1),time(:,i));
                left = max(shift + findnearest(gauss_p(2,j),t) - l,1);
                right = min(shift + findnearest(gauss_p(2,j),t) + r,num_frames);
                
                x = time(left:right,i);
                fitted_y = synthesize_gaussians(gauss_p(:,j),x);
                
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
