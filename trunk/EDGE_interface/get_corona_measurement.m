function corona_measurement = get_corona_measurement(measurement,neighborID,nanflag)

if nargin < 3, nanflag = 0; end

[num_frames,num_cells] = size(measurement);

corona_measurement = nan(num_frames,num_cells);

for t = 1:num_frames
    for i = 1:num_cells
        if ~isnan(neighborID{1,i})
            if nanflag
                corona_measurement(t,i) = nansum(measurement(t,neighborID{1,i}));
            else
                corona_measurement(t,i) = sum(measurement(t,neighborID{1,i}));
            end
        end
    end
end
