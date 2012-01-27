function m = load_edge_data(folder_name,varargin)

if nargin > 1
    N = numel(varargin);
    index = 0;
end

p = pwd;
cd(folder_name);
mat_files = what(pwd);
mat_files = mat_files.mat;
if isempty(mat_files)
    'No .mat files found'
else
    for i = 1:numel(mat_files)
        if nargin < 2
            this_mat = mat_files{i};
            load(this_mat);
            m(i).data = data;
            m(i).name = name;
            m(i).unit = unit;
        else
            for j = 1:N
                this_string = varargin{j};
                if ~isempty(regexpi(mat_files{i},this_string))
                    index = index + 1;
                    load(mat_files{i});
                    m(index).data = data;
                    m(index).name = name;
                    m(index).unit = unit;
                end
            end
        end
    end
end

cd(p);