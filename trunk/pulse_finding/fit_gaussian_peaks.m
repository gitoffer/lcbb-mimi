function [pulse,varargout] = fit_gaussian_peaks(Y,master_time,timeframe,IDs,opt)
%FIT_GAUSSIAN_PEAKS Fits peaks as Gaussians, and puts the information into
%a useful format.
%
% pulse = fit_gaussian_peaks(Y,time,timeframe,IDs);
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

alpha = opt.alpha;
bg = opt.bg;

l = opt.left_margin; r = opt.right_margin;

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

[cells(1:num_cells).params] = deal([]);
[cells(1:num_cells).num_peaks] = deal([]);
[cells(1:num_cells).colorized] = deal([]);
[cells(1:num_cells).fit] = deal([]);
[cells(1:num_cells).pulseID] = deal([]);

for i = 1:num_cells
    
    % Need to convert frame to actual time using the time bounds given
    t = master_time(IDs(i).which).aligned_time';
    f0 = find(min_t < t, 1, 'first');
    ff = find(max_t > t, 1, 'last');
%     frame = f0:ff;
    
    % Generate "true time" vector, t
    t = t(min_t < t & t < max_t);
    
    % Crop the curve using time bounds
    y = Y(f0:ff,i);
    
    % Reject any curves without at least 20 data points
    if numel(y(~isnan(y))) > 20 && any(y > 0)
        
        % Interpolate and rectify
        [y,start] = interp_and_truncate_nan(y);
        y(y < 0) = 0;
        t = t(start:start+numel(y)-1)';
        
        % Establish the lower bounds of the constraints
        lb = [0;t(1)+10;opt.sigma_lb];
        ub = [nanmax(y);t(end)-30;opt.sigma_ub];
        
        [gauss_p,residuals] = iterative_gaussian_fit(y,t,alpha,lb,ub,bg);
        
        if cell_fit
%             if ff - f0 + 1 ~= size(t)
%                 ff = ff - (ff+f0-1-numel(t));
%             end
%             fits(f0:(f0+numel(t) - 1),i) = this_fit;
            if background %If we have a BG model... handles parameter count differently
                this_fit = synthesize_gaussians(gauss_p(:,2:end),t);
                P = plot_peak_color(gauss_p(:,2:end),t);
                cells(i).params = gauss_p(:,2:end);
                cells(i).num_peaks = size(gauss_p,2) - 1;
                cells(i).bg = lsq_exponential(gauss_p(:,1),t);
                cells(i).fit = this_fit + lsq_exponential(gauss_p(:,1),t);
                cells(i).colorized = P;
                cells(i).signal = this_fit;
                cells(i).time = t;
                cells(i).residual = residuals;
            else % If it's Gaussians only.
                this_fit = synthesize_gaussians(gauss_p,t);
                P = plot_peak_color(gauss_p(:,1:end),t);
                cells(i).params = gauss_p;
                cells(i).num_peaks = size(gauss_p,2);
                cells(i).colorized = P;
                cells(i).signal = this_fit;
                cells(i).time = t;
                cells(i).residual = residuals;
            end
        end
        
        if background, idx = 2; else idx = 1; end
        
        for j = idx:size(gauss_p,2)
            if gauss_p(2,j) > -300
                
                time = master_time(IDs(i).which).aligned_time';
                
                num_peaks = num_peaks + 1;
                shift = findnearest(t(1),time) - 1;
                left = max(shift + findnearest(gauss_p(2,j),t) - l,1);
                right = min(shift + findnearest(gauss_p(2,j),t) + r,num_frames);
                
                x = time(left:right);
                fitted_y = synthesize_gaussians(gauss_p(:,j),x);
                
                % Get curve and fitted curve
                pulse(num_peaks).raw_curve = y(left:min(right,numel(y)));
                pulse(num_peaks).curve = fitted_y;
                pulse(num_peaks).aligned_time = x - gauss_p(2,j);
                
                % Pad left
                if shift + findnearest(gauss_p(2,j),t) - l < 1
                    fitted_y = [nan(1-(shift + findnearest(gauss_p(2,j),t) - l),1);fitted_y];
                    x = [nan(1-(shift + findnearest(gauss_p(2,j),t) - l),1);x];
                end
                % Pad right
                if shift + findnearest(gauss_p(2,j),t) + r > num_frames
                    fitted_y = [fitted_y;nan((shift + findnearest(gauss_p(2,j),t) + r) - num_frames,1)];
                    x = [x;nan((shift + findnearest(gauss_p(2,j),t) + r) - num_frames,1)];
                end
                
                % Which cell (recorded three ways)
                pulse(num_peaks).cell = i;
                pulse(num_peaks).cellID = IDs(i).cellID;
                pulse(num_peaks).embryo = IDs(i).which;
                % Size, center, and time-frames of pulse
                pulse(num_peaks).curve_padded = fitted_y;
                pulse(num_peaks).size = gauss_p(1,j);
                pulse(num_peaks).center = gauss_p(2,j);
                pulse(num_peaks).center_frame = findnearest(gauss_p(2,j),t);
                pulse(num_peaks).frame = left:right;
                pulse(num_peaks).aligned_time_padded = x;
                pulse(num_peaks).pulseID = num_peaks;
                
                if cell_fit
                    cells(i).pulseID = [cells(i).pulseID num_peaks];
                end
                
            end
        end 
    end    
end

if cell_fit
    varargout{1} = cells;
end
