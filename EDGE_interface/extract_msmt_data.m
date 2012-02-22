function [data,varargout] = extract_msmt_data(m_array,name_to_extract,convert)
%EXTRACT_MSMT_DATA (from EDGE). Extracts a specific measurement from an
%array of EDGE measurement structures.
%
% SYNOPSOS: 
%  data = extract_msmt_data(m_array,'anisotropy','off')
% [data,unit] = extract_msmt_data(m_array,'anisotropy','off')
%
% INPUT: m_array - EDGE measurements
%        name_to_extract - measurement name
%        convert - 'on'/'off' converts from cell to numerical. Default on.
%        Will cause errors if measurements are not the same size across
%        cells and time frames (e.g. vertex).
%
% xies@mit.edu 10/2011.

if ~exist('convert','var'), convert = 'on'; end

m = m_array(strcmpi({m_array.name},name_to_extract));
if ~isempty(m)
    if strcmpi(convert,'on')
        data = cell2mat(m.data);
    else
        data = m.data;
    end
else
    error('edge:msmt_not_found','Found nothing.')
end

if nargout > 1, varargout{1} = m.unit; end