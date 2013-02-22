function m = load_edge_data(folder_names,varargin)
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

num_embryos = numel(folder_names);
p = pwd;

for embryo = 1:num_embryos
    
    folder_name = folder_names{embryo};
    
    cd(folder_name);
    
    mat_filenames = what(pwd);
    mat_filenames = mat_filenames.mat;
    if isempty(mat_filenames)
        display('No .mat files found');
        return
    end
    
    if nargin > 1
        N = numel(varargin);
        index = 0;
    else
        
    end
    
    display(['Loading folder ' folder_name]);
    
    already_loaded = {'blah'};
    for i = 1:numel(mat_filenames)
        this_filename = mat_filenames{i};
        if nargin == 1
            load(this_filename);
            m(embryo,i).data = data;
            m(embryo,i).name = name;
            m(embryo,i).unit = unit;
        else
            for j = 1:N
                this_measurement_name = varargin{j};
                [~,this_name,~] = fileparts(this_filename);
                % If the file name has a substring match to an input string,
                % AND that file has not been loaded before, then load that file
                %             if ~isempty(regexpi(this_filename,this_measurement_name)) && ...
                %                 (~any(strcmpi(this_filename,already_loaded)))
                if strcmpi(this_name,this_measurement_name) && ...
                        (~any(strcmpi(this_filename,already_loaded)))
                    index = index + 1;
                    load(this_filename);
                    m(embryo,index).data = data;
                    m(embryo,index).name = name;
                    m(embryo,index).unit = unit;
                    display(['Loaded: ' this_filename]);
                    already_loaded = {already_loaded,this_filename};
                end
            end
        end
    end
    
end

cd(p);

end
