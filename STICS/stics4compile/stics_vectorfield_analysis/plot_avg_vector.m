function plot_avg_vector(stics_avg,scale,io)
%PLOT_AVG_VECTOR Plots the STICS vector field 'averaged' along a single
%direction for all time frames in the vector field.
%
% SYNOPSIS: plot_avg_vector(stics_avg,scale,io)
%
% INPUT: stics_avg - STICS vector field averaged along a single direction
%        scale - scaling factor for plotting vectors
%        io - (optional) If defined, will save to specified folder in
%        SticsIO object

T = numel(stics_avg);
[Y,X,~] = size(stics_avg{1});
colorset = varycolor(T);
if X == 1, which_way = 2; else which_way = 1; end

switch which_way
    case 1
        for i = 1:T
            hold on
            h = quiver((1:X),i*ones(1,X), ...
                stics_avg{i}(:,:,1),stics_avg{i}(:,:,2),scale, ...
                'color',colorset(i,:),'linewidth',1);
            title('STICS vectors averaged in the y-direction.')
            ylabel('Time (frames)');
            xlabel('Distance in x-direction (px)')
        end
        hold off
    case 2
        for i = 1:T
            hold on
            h = quiver(i*ones(1,Y),(1:Y), ...
                stics_avg{i}(:,:,1)',stics_avg{i}(:,:,2)',scale, ...
                'color',colorset(i,:),'linewidth',1);
            title('STICS vectors averaged in the x-direction.')
            xlabel('Time (frames)')
            ylabel('Distance in y-direction (px)')
        end
        hold off
end

if exist('io','var')
    switch which_way
        case 1
            saveas(h,[io.save_name '/avg_in_y'],'fig');
        case 2
            saveas(h,[io.save_name '/avg_in_x'],'fig');
    end
end

end