function msmtvtime_per_cell(measurement,cellID,varargin)
%Plots the measurement versus time for a given set of cells.
%
% USE: msmtvtime_per_cell(measurement,cellID);
%      msmtvtime_per_cell(measurement,cellID,z); specify the zslice to
%                                                include
%
% xies@mit.edu March 2012.

if isempty(varargin),z = 1;end

name = measurement.name;
unit = measurement.unit;

data = cell2mat(measurement.data);
data = squeeze(data(:,z,:));
% [T,Z,num_cells] = size(data);

data = data(:,cellID);

cc = jet(numel(cellID));
for i = 1:numel(cellID)
    plot(data(:,i),'color',cc(:,i));
    hold on
end

title([name 'v. time']);
xlabel('Time (frames)');
ylabel([name '(' unit ')']);