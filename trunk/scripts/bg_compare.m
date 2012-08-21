%%

folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/spiderGFP/Measurements';handle.io.save_dir = '~/Desktop/Embryo 4';zslice = 1; tref = 1; ignorelist = [];
msmts2make = {'area','vertex-x','vertex-y', ...
    'neighbors','centroid'};
EDGEstack_bg = load_edge_data(folder2load,msmts2make{:});

%%

bg_areas = extract_msmt_data(EDGEstack_bg,'area','on',zslice);
bg_areas_sm = smooth2a(bg_areas,1,0);
[bg_num_frames,~] = size(bg_areas);
bg_areas_rate = -central_diff_multi(bg_areas_sm,1:bg_num_frames);

xi = linspace(-15,15,201);
[bg,x] = hist(bg_areas_rate(:),xi);
[cr,x] = hist(areas_rate(:),xi);
bg = bg + 1; cr = cr + 1; % pseudocounts
relative = cr./bg;
relative_sm = smooth(relative);

significant_cr = zeros(num_frames,num_cells);
for j = 1:num_cells
    for i = 1:num_frames
        idx = findnearest(areas_rate(i,j), xi);
        if relative_sm(idx) > 3
            significant_cr(i,j) = areas_rate(i,j);
        end
    end
end

%%
areas = [];
mean_int = [];

for i = 1:num_cells
    stats{i} = regionprops(logical(significant_cr(1:15,i)), ...
        significant_cr(1:15,i),{'MeanIntensity','Area'});
    areas = [areas stats{i}.Area];
    number(i) = numel(stats{i});
    mean_int = [mean_int stats{i}.MeanIntensity];
end
