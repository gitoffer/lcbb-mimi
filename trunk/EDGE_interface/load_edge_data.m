function m = load_edge_data(folder_name,varargin)

if nargin > 1
    N = numel(varargin);
    index = 0;
end

p = pwd;
cd(folder_name);
mat_filenames = what(pwd);
mat_filenames = mat_filenames.mat;
if isempty(mat_filenames)
    display('No .mat files found');
    return
end

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
            if ~isempty(regexpi(this_filename,this_measurement_name))
                index = index + 1;
                load(this_filename);
                m(index).data = data;
                m(index).name = name;
                m(index).unit = unit;
                display(['Loaded: ' this_filename]);
            end
        end
    end
end

cd(p);