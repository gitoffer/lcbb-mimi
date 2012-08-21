cellID = 61;

D = 10;
N = 1e3;

noise_levels = linspace(1,10,D);
noisy_cell_area = nan(num_frames,D,N);
new_areas = noisy_cell_area;

for t = 1:num_frames
    for i = 1:D
        for j = 1:N
            vx = vertices_x{t,cellID};vy = vertices_y{t,cellID};
            if ~isnan(vx)
            [~,new_areas(t,i,j)] = ...
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

figure(400),clf
errorbar(nanmean(new_areas(:,5,:),3), ...
    nanstd(new_areas(:,5,:),[],3));
hold on,
plot(areas_sm(:,cellID)/.1803^2,'r-');

figure(401)
plot(noise_levels,nanstd(new_areas(1,:,:),[],3)/(areas_sm(1,cellID)/.1803^2))
