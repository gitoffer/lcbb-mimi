%%

binSize = 1; % microns^2
edges = nanmin(areas(:)) : binSize : nanmax(areas(:));

xmax = 80;
ymax = 85; 
data_type = areas(:,[IDs.which]==2\3);
tint = 70;
time = dev_time(3, :);
time = time(~isnan(time)); 
last = length(time);
totalseconds = floor(time(last));
num_of_figures = floor(totalseconds / tint);

for i = 1:num_of_figures
    
   [freq, edges, tc] = hist_within_timeframe(areas,time, 1+(tint * (i-1)), i*tint , edges) ;
   %[freq1, edges1, tc1] = hist_within_timeframe(oct, time, 1+(tint * (i-1)), i*tint, nbins);
    figure(2)
    subplot(num_of_figures/2, 2, i)
    bar(edges, freq), xlabel('cta:  \mum^2'), ylabel(['Counts ' num2str(tc)]); ylim([0, ymax]), xlim([0,xmax]), title([num2str(1+(tint *(i-1))) 's to ' num2str(i*tint) 's']);
end

%%
%binSize = 1; % microns^2
%edges = nanmin(areas(:)) : bicomnSize : nanmax(areas(:));

%xmax = 80;
%ymax = 85; 
%data_type = areas(:,[IDs.which]==2);
%tint = 50;
%time = dev_time(2, :);
%time = time(~isnan(time)); 
%last = length(time);
%totalseconds = floor(time(last));
%num_of_figures = floor(totalseconds / tint);



%for i = 1:num_of_figures
 %   
  % [freq, edges, tc] = hist_within_timeframe(areas,time, 1+(tint * (i-1)), i*tint , edges) ;
   %[freq1, edges1, tc1] = hist_within_timeframe(oct, time, 1+(tint * (i-1)), i*tint, nbins);
  %  figure(2)
   % subplot(6, 1, i)
   %bar(edges, freq), xlabel('Wild Type:  \mum^2'), ylabel(['Counts ' num2str(tc)]); ylim([0, ymax]), xlim([0,xmax]), title([num2str(1+(tint *(i-1))) 's to ' num2str(i*tint) 's']);
%end
