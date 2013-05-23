function embryo_structs = edge2embryo(EDGEstack,input,num_cells)
%EDGE2EMBRYO Convers an EDGEstack (output of LOAD_EDGE_DATA) into an embryo-
% centric structure. The fields are the abbreviated names of each measurement
% and the field contents are the respective measurements.
%
% SYNOPSIS: embryo_structs = edge2embryo(EDGEstack,IDs);
%
% INPUT: EDGEstack - a NxM array of EDGE structure, where N is the number of
% 									 embryos and M the number of measurements
%
% OUTPUT: embryo_structs - a N-dimensional vector of structs
%						.(measurement) - the fieldnames are the measurement
%                       .input = input structure
%                       .num_cell - the number of cells in embryo
%                       .dev_time - multiple-embryo aligned-time
%                       .dev_frame - multiple-embryo aligned-frames
%
% xies@mit.edu

[num_embryos,num_meas] = size(EDGEstack);

% Preallocate structures
meas_names = {EDGEstack(1,:).name};
meas_fieldnames = make_valid_fieldname({EDGEstack(1,:).name});
[embryo_structs(1:num_embryos)] = ...
    deal( cell2struct(cell(1,num_meas),meas_fieldnames,2) );

x = cell(num_embryos,numel(meas_fieldnames));
data = cell(1,num_embryos);
for j = 1:numel(meas_fieldnames)
    IDs = [];
    for i = 1:num_embryos
        % Collect the same measurement (e.g. myosin)
        m = EDGEstack(i,strcmpi({EDGEstack(i,:).name},meas_names{j})).data;
        m = squeeze(m(:,input(i).zslice,:));
        % If possible convert to mat array
        try m = cell2mat(m);
        catch err
        end
        
        % Construct embryoID/cellID/stackID
        x{i,j} = m;
        IDs = cat(2,IDs,i * ones( 1,num_cells(i) ));
        
    end
    
    [foo,time] = stitch_embryos(x(:,j),input);
    data{j} = foo;
    
end

for i = 1:num_embryos
    for j = 1:numel(meas_fieldnames)
        % Construct the struct
        embryo_structs(i).(meas_fieldnames{j}) = ...
            data{j}(:, IDs == i );
        
    end
end

[embryo_structs(1:num_embryos).num_cell] = deal([]);
[embryo_structs(1:num_embryos).input] = deal([]);
[embryo_structs(1:num_embryos).dev_time] = deal([]);

% Collect other house-keeping non-EDGE data
for i = 1:num_embryos
    embryo_structs(i).num_cell = num_cells(i);
    embryo_structs(i).input = input(i);
    embryo_structs(i).dev_time = time(i,:);
    embryo_structs(i).num_frame = numel( nonans(time(i,:)) );
end

% frame = nan(num_embryos,numel(time)); t = nan(num_embryos,numel(time));
% max_tref = max([input.tref]); lag = max_tref - [input.tref];

% for i = 1:num_embryos
%     for j = 1:numel(meas_fieldnames)
%         embryo_structs(i).(meas_fieldnames{j}) = ...
%             data{j}(:,IDs == i);
%     end
%     % Construct the dev_time
%     t(i,:) = time*input(i).dt;
%     frame(i,lag(i)+1:lag(i)+input(i).T) = 1:input(i).T;
% end


end
