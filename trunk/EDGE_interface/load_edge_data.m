function m = load_edge_data(folder_name)

p = pwd;
cd(folder_name);
mat_files = what(pwd);
mat_files = mat_files.mat;
if isempty(mat_files)
    'No .mat files found'
else
    for i = 1:numel(mat_files)
        this_mat = mat_files{i};
        load(this_mat);
        m(i).data = data;
        m(i).name = name;
        m(i).unit = unit;
    end
end

cd(p);