function [freq,edges,tc] = hist_within_timeframe(data, time, ti, tf, nbins)
% HISTOGRAMAREA 
% creates a histogram illustrating the area distribution of embryo 1 within a given
%   time interval 
% USAGE: compiled_hist_graphs_script is helpful in displaying several
% graphs over time
% INPUT: ti - the first time interval (sec)
%        tf - the end time interval (sec)
%        data set  - a matrix in form (time, area) denoting some variable of a cell
%        over a given time 
%        time - dev_time.aligned_time if you must 
% OUTPUT: edges - thresholds for bins- necessary for bar graph 
%         freq - frequency of data expression per bin 
%         tc - total cells counted 
%         note this is produced in vector form 
% elenad@mit.edu February 2013

logvec1 = (time > ti) ; 
logvec2 = (time < tf); 
logvec3  = logvec1 & logvec2; 

desired_time = time.*logvec3 ;
indices = find(desired_time); 
int = length(indices); 

areaInTime = data(indices(1): indices(int),:); % takes the areas across the given inputs of time 
areaInTime = areaInTime(:); %linearize matrix to form vector

min1= nanmin(areaInTime); % finds the minimum area
max1 = nanmax(areaInTime); % finds the maximum area

edges = linspace(min1,max1,nbins); % creates a vector of 10 intervals between min1 and max1
tc =length(~isnan(areaInTime));
freq = histc(areaInTime, edges); % counts the number of areas for each time interval within each size interval 

end

 