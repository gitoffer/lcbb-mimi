function imsequence_color( imsequence)

num_frame = size(imsequence,3);
max_pix_value = max(max(max(imsequence)));
min_pix_value = min(min(min(imsequence)));
%%%set image play size
figure(102)
for j = 1:num_frame
    A= imsequence(:,:,j);
    surfc(A,'EdgeColor', 'none', 'FaceColor', 'flat');
    set(gcf, 'Renderer', 'zbuffer');
    axis equal;
    %axis normal;
    %axis tight;
    
    %set(gca, 'view', [-45 45]);
    set(gca, 'view', [0 90]);

    F(j) = getframe;
end
%movie2avi(F,'movie8.avi','compression','none')