%%

input_bg.folder2load = '~/Documents/MATLAB/EDGE/DATA_GUI/spiderGFP/Measurements';
input_bg.zslice = 1; input_bg.tref = 1; input_bg.ignore_list = [];
msmts2make = {'myosin','membranes--basic_2d--area', ...
    'Membranes--vertices--Vertex-y','Membranes--vertices--Vertex-x',...
    'Membranes--basic_2d--Centroid-x','Membranes--basic_2d--Centroid-y',...
    'Membranes--vertices--Identity of neighbors'};
EDGEstack_bg = load_edge_data({input_bg.folder2load},msmts2make{:});

%%

bg_areas = extract_msmt_data(EDGEstack_bg,'area','on',input_bg);
bg_areas_sm = smooth2a(bg_areas,1,0);
[bg_num_frames,~] = size(bg_areas);
bg_areas_rate = -central_diff_multi(bg_areas_sm,1:bg_num_frames);


%%

nbins = 201;
bins = linspace(-15,15,201);
[bg] = hist(areas_rate_cellularizing(:),bins);
[cr] = hist(areas_rate(:),bins);
bg = bg + 1; cr = cr + 1; % pseudocounts
bg = bg/sum(bg); cr = cr/sum(cr); % normalize
lut = cr./bg;
lut_sm = smooth(relative);

%%

likelihood_ratio = nan(size(corrected_area_rate));

for j = 1:size(corrected_area_rate,2)
    for i = 1:size(corrected_area_rate,1)
        
        datum = corrected_area_rate(i,j);
        if ~isnan(datum)
            value = lut(findnearest(datum , bins));
        end
        
        if ~isnan(value) && ~isinf(value)
            likelihood_ratio(i,j) = value;
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
