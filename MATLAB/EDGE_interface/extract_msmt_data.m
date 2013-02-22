function [data,varargout] = extract_msmt_data(m_array,name_to_extract,convert, ...
    input)
%EXTRACT_MSMT_DATA (from EDGE). Extracts a specific measurement from an
%array of EDGE measurement structures.
%
% SYNOPSIS:
%  data = extract_msmt_data(m_array,'anisotropy','off',input_structure)
%
% INPUT: m_array - EDGE measurements
%        name_to_extract - measurement name
%        convert - 'on'/'off' converts from cell to numerical.
%        input_structure
%        Will cause errors if measurements are not the same size across
%        cells and time frames (e.g. vertex).
%
% See also load_edge_data, stitch_embryo
%
% xies@mit.edu 10/2011.

num_embryos = size(m_array,1);
num_cells = zeros(num_embryos,1);

x = cell(1,num_embryos);

for i = 1:num_embryos
		
		% Extract the correct name with the right fieldname
    m = m_array(i,strcmpi({m_array(i,:).name},name_to_extract));
    
		% Get rid of other zslices
    slice_range = input(i).zslice;
    
		% Convert to numerical array if needed
    if ~isempty(m)
        if strcmpi(convert,'on')
            data = cell2mat(m.data);
            data(:,input(i).ignore_list) = nan;
        else
            data = m.data;
        end
    else
        warning('edge:msmt_not_found',['Found no measurement called ' name_to_extract])
        data = [];
        varargout{1} = 0;
    end
    
    % Special case for neighborID -- need to re-index the cellIDs
    if strcmpi(name_to_extract,'identity of neighbors')
        data = cellfun(@(x) x+sum(num_cells), data,'UniformOutput',false);
    end
    
    num_cells(i) = size(data,3);
    if nargin <= 3, slice_range = 1; end
    
		% Squeeze out zslice if singleton
    if numel(slice_range) == 1
        data = squeeze(data(:,slice_range,:));
    % Track with z-slice
    elseif numel(slice_range) == size(data,1)
        possible_z = unique(slice_range);
        if ~iscell(data)
            foo = zeros([size(data,1),size(data,3)]);
        else
            foo = cell([size(data,1),size(data,3)]);
        end
        for j = 1:numel(possible_z)
            this_index = slice_range == possible_z(j);
            foo(this_index,:) = ...
                squeeze(data(this_index,possible_z(j),:));
        end
        data = foo;
    else
        error('Input slice range needs to be 1 slice or a vector of length equal to the number of frames');
    end
  	
		% Put data in cell array  
    x{i} = data;
    
end

% Stitch together multiple embryos
[data,time] = stitch_embryos(x,input);

% Construct the time structure
if nargout > 1
        % Record the identity of each cell
        %   .cellID = the EDGE-based cellID in the original numbering
        %             scheme
        %   .which = which embryo the cell belongs to
        
        % Preallocate
        [IDs(1:sum(num_cells)).cellID] = deal(0);
        % Get which embryo
        c = [];
        for i = 1:num_embryos
            c = cat(2,c,i*ones(1,num_cells(i)));
        end
        % Get cellID
        for i = 1:sum(num_cells)
            IDs(i).which = c(i);
            if c(i) == 1
                IDs(i).cellID = i;
            else
                IDs(i).cellID = i - sum(num_cells(1:c(i)-1));
            end
        end
        
        varargout{1} = IDs;
        
    if nargout > 2
        % Record the various time/indices associated with each cell, at
        % each sampling frame
        %   .time = the 'aligned' time
        %   .frame = the actual frame number
        
        % Preallocate
        [t(1:num_embryos).frame] = deal(0);
        [t(1:num_embryos).time] = deal(0);
        
        max_tref = max([input.tref]);
        lag = max_tref - [input.tref];
        for i = 1:num_embryos
            % Construct the dev_time structure
            t(i).time = time*input(i).dt;
            t(i).frame = nan(size(time));
            
            t(i).frame(lag(i)+ 1:lag(i)+input(i).T - input(i).t0) = ...
                1:input(i).T - input(i).t0;
            
        end
        
        varargout{2} = t;
    end
end

end
