cellID = 61;

D = 3;
N = 1e2;

noise_levels = linspace(1,5,D);
noisy_cell_area = nan(num_frames,D,N);
new_areas = noisy_cell_area;

for t = 1:num_frames
    for i = 1:D
        for j = 1:N
            vx = vertices_x{t,cellID};vy = vertices_y{t,cellID};
            if ~isnan(vx)
            [noisy_cell_area(t,i,j),new_areas(t,i,j)] = ...
                add_noise_vertex(vx,vy,noise_levels(i));
            else
                noisy_cell_area(t,i,j) = NaN;
                new_areas(t,i,j) = NaN;
            end
        end
    end
    
%     keyboard
%     noisy_cell_area(:,i,:) = noisy_cell_area(:,i,:)/areas_sm(t,cellID);
        
end

%%

figure(400)
errorbar(nanmean(noisy_cell_area(:,1,:),3), ...
    nanstd(noisy_cell_area(:,1,:),[],3));
