function logs = plot_system(state, o, logs)
    persistent ax_handle;
    L = o.sim_box_size_um;
    try 
        axes(ax_handle);
        cla;
    catch
        figure; 
        set(gcf, 'Color', [0 0 0]);
        ax_handle = axes;
        set(ax_handle ...
            , 'xlim',[-0.1, 1.1]*L(1)...
            , 'ylim', [-0.1 1.1]*L(2) ...
            , 'Color', [0.2 0.2 0.2] ...
            , 'XColor', [0.5 0.5 0.5] ...
            , 'YColor', [0.5 0.5 0.5] ...
            , 'ydir', 'reverse' ...
            );
        box on;
        hold on;        
    end
    
    % make a box around the system
    plot([0 0 1 1 0]*L(1), [0 1 1 0 0]*L(2) ...
        , '--', 'Color', [1 1 1]*0.5 ...
        , 'LineWidth', 2 ...
        );
    
    % plot particles themselves
    plot(state.x(:,1), state.x(:,2), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 2,  'LineSmoothing', 'on');
    
    % plot the bonds
    for ii = 1:size(state.x,1)
       for jj = state.bonds(ii,1:state.nbonds(ii))
           x = state.x([ii jj],1);
           y = state.x([ii jj],2);
           x(2) = x(2) - L(1) *round(diff(x)/L(1));
           y(2) = y(2) - L(2) *round(diff(y)/L(2));
           plot(x,y, 'g-', 'LineWidth', 0.1, 'LineSmoothing', 'on');
       end
    end

    if isempty(logs.images)
        logs.images = getframe();
    else
        logs.images(end+1) = getframe();
    end
end