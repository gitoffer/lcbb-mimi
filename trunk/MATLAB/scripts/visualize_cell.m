ID = cellID;

% if nargin > 1, h = varargin{1}; end

nonantime = ~isnan(master_time(IDs(ID).which).frame);
time = master_time(IDs(ID).which).aligned_time;
time = time(nonantime);

% cell_fits( 

% Plot raw data and fits
h = plotyy(time,myosins_sm(nonantime,ID),...
    time,areas_sm(nonantime,ID));
set(h(2),'Xlim',[min(master_time(IDs(ID).which).aligned_time) ...
    max(master_time(IDs(ID).which).aligned_time)]);
hold on
plot(cell_fits(ID).time,cell_fits(ID).signal,'c-')
plot(cell_fits(ID).time,cell_fits(ID).bg,'r-')
plot(cell_fits(ID).time,cell_fits(ID).signal + cell_fits(ID).bg,'k-');
hold off

title(['Cell #' num2str(ID)])
set(h(1),'Xlim',[min(master_time(IDs(ID).which).aligned_time) ...
    max(master_time(IDs(ID).which).aligned_time)]);

% end