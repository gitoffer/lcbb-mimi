function F = pulses2cells(pulses,handle)

% num_embryos = handle.num_embryos;
% num_cells = handle.num_cells;
% num_frames = handle.num_frames;
IDs = handle.IDs;
master_time = handle.master_time;
measurement = handle.measurement;

num_embryos = numel(master_time);

F = cell(1,num_embryos);
t = cell(1,num_embryos);
num_cells = zeros(1,num_embryos);

if numel(measurement) ~= numel(pulses)
    error('Input measurement should be indexed by pulseID!');
end

% Initialize output
for i = 1:num_embryos
    t{i} = master_time(i).frame;
    num_cells(i) = numel(find([IDs.which] == i));
    F{i} = zeros(numel(t{i}(~isnan(t{i}))),num_cells(i));
end

for i = 1:numel(pulses)
    
%     this_embyro()
    embryoID = pulses(i).embryo;
    time = t{embryoID};
    pulsing_time = time(pulses(i).frame);
    pulsing_time = pulsing_time(~isnan(pulsing_time));

    F{embryoID}(pulsing_time,pulses(i).cellID) = ...
        measurement(i);
    
end