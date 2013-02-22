function visualize_cell(cells,ID,handle)
%VISUALIZE_CELL Plots the raw area and myosin data for a given cell as well
% as its fitted pulses, if applicable.
%
% USAGE: h = visualize_cell(cells,stackID)
%
% xies@mit.edu Feb 2013

% Extract cell
this_cell = cells(ID);

nonan_frame = this_cell.dev_frame;
nonan_frame = ~isnan(nonan_frame);
time = this_cell.dev_time( nonan_frame );

if nargin < 3, handle = gca; end

% Plot raw data: myosin + area
[h,fig1,fig2] = plotyy(handle, time, this_cell.myosin_sm(nonan_frame), ...
    time, this_cell.area_sm(nonan_frame) );

set(fig1,'Color','g'); set(fig2,'Color','k')

% set x-axis limits
set(h(2) , 'Xlim', [min(time) max(time)] );

if this_cell.flag_fitted
    
    hold(handle,'on');
    
    plot(handle,this_cell.fit_time, this_cell.fit_colorized);
    plot(handle,this_cell.fit_time, this_cell.fit_bg, 'c-');
    plot(handle,this_cell.fit_time, this_cell.fit_curve, 'm-');
    
    hold(handle,'off');
    
    title(handle,['EDGE #' num2str(this_cell.cellID)])
    
end

set(handle,'Xlim',[min(this_cell.dev_time) max(this_cell.dev_time)]);

% if nargout > 0, varargout{1} = h; end

end