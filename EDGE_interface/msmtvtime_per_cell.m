function msmtvtime_per_cell(measurement,cellID,varargin)

if isempty(varargin)
    z = 1;
end

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