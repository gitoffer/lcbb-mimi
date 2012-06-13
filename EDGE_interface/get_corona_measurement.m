function corona_measurement = get_corona_measurement(measurement,neighborID,tref,nanflag)

if nargin < 3, tref = 1; nanflag = 0;
elseif nargin < 4, nanflag = 0; end

[num_frames,num_cells] = size(measurement);

corona_measurement = nan(num_frames,num_cells);

for t = 1:num_frames
    for i = 1:num_cells
        if ~isnan(neighborID{tref,i})
            if nanflag
                corona_measurement(t,i) = nansum(measurement(t,neighborID{tref,i}));
            else
                corona_measurement(t,i) = sum(measurement(t,neighborID{tref,i}));
            end
        end
    end
end
