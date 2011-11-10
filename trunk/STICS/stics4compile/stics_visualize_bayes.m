% load('')

%% Find most likely model

T = numel(stics_img);
[X,Y,~] = size(stics_img{1});
most_probable_model(T,X,Y) = BayesModels;

for i = 1:T
    sorted_array = sort_models(stics_img{i});
    most_probable_model(i,:,:) = sorted_array(:,:,1);
end

%% Visualize velocities (from convection or mixed)

bvector = get_velocities(most_probable_model);

F = stics_movie(imcropped,stics_opt,bvector,500);
movie2avi(F,[io.sticsSaveName])