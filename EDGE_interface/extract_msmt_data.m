function [data,varargout] = extract_msmt_data(m_array,name_to_extract,convert, ...
    input)
%EXTRACT_MSMT_DATA (from EDGE). Extracts a specific measurement from an
%array of EDGE measurement structures.
%
% SYNOPSIS:
%  data = extract_msmt_data(m_array,'anisotropy','off')
% [data,unit] = extract_msmt_data(m_array,'anisotropy','off')
%
% INPUT: m_array - EDGE measurements
%        name_to_extract - measurement name
%        convert - 'on'/'off' converts from cell to numerical.
%        Will cause errors if measurements are not the same size across
%        cells and time frames (e.g. vertex).
%
% See also load_edge_data
%
% xies@mit.edu 10/2011.

num_embryos = size(m_array,1);
num_cells = zeros(num_embryos,1);

for i = 1:num_embryos
    m = m_array(i,strcmpi({m_array(i,:).name},name_to_extract));
    
    slice_range = input(i).zslice;
    
    if ~isempty(m)
        if strcmpi(convert,'on')
            data = cell2mat(m.data);
            data(:,input(i).ignore_list) = nan;
        else
            data = m.data;
%             data(:,input(i).ignore_list) = {nan};
        end
    else
        warning('edge:msmt_not_found',['Found no measurement called ' name_to_extract])
        data = [];
        varargout{1} = 0;
    end
    
    [~,num_slices,num_cells(i)] = size(data);
    if nargin <= 3
        slice_range = 1:num_slices;
    end
    
    data = squeeze(data(:,slice_range,:));
    x{i} = data;
    
end

data = stitch_embryos(x,input);

switch nargout
    case 2, varargout{1} = num_cells;
    case 3
        varargout{1} = num_cells;
        c = [];
        for i = 1:num_embryos
            c = cat(2,c,i*ones(1,num_cells(i)));
        end
        varargout{2} = c;
end

end