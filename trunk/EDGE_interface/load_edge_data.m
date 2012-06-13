function m = load_edge_data(folder_name,varargin)
%LOAD_EDGE_DATA Given the EDGE folder location, and the names of
% measurements of interest, load all EDGE measurements into a single
% structure array.
%
% SYNOPSIS: EDGEstack = load_edge_data(folder_name,'myosin','shape',...);
% INPUT: FOLDER_NAME - folder to load from
%        VARARGIN - substrings of interest (e.g. 'myosin')
% OUTPUT: EDGEstack.name - name of measurement (e.g. 'Centroid-x')
%         EDGEstack.data - the actual data (cell-array, time-by-num_cells)
%         EDGEstack.unit - relevant units to data
%
% See also extract_msmt_data
%
% xies@mit.edu Dec 2012.


if nargin > 1
    N = numel(varargin);
    index = 0;
end
display(['Loading folder ' folder_name]);

p = pwd;
cd(folder_name);
mat_filenames = what(pwd);
mat_filenames = mat_filenames.mat;
if isempty(mat_filenames)
    display('No .mat files found');
    return
end

already_loaded = {'blah'};
for i = 1:numel(mat_filenames)
    this_filename = mat_filenames{i};
    if nargin == 1
        load(this_filename);
        m(i).data = data;
        m(i).name = name;
        m(i).unit = unit;
    else
        for j = 1:N
            this_measurement_name = varargin{j};
            % If the file name has a substring match to an input string,
            % AND that file has not been loaded before, then load that file
            if ~isempty(regexpi(this_filename,this_measurement_name)) && ...
                (~any(strcmpi(this_filename,already_loaded)))
                index = index + 1;
                load(this_filename);
                m(index).data = data;
                m(index).name = name;
                m(index).unit = unit;
                display(['Loaded: ' this_filename]);
                already_loaded = {already_loaded,this_filename};
            end
        end
    end
end

cd(p);