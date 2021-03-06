function corona_measurement = get_corona_measurement(measurement,neighborID,tref,nanflag)

if nargin < 3, tref = 1; nanflag = 0;
elseif nargin < 4, nanflag = 0; end

[num_frames,num_cells] = size(measurement);

corona_measurement = nan(num_frames,num_cells);

for t = 1:num_frames
    for i = 1:num_cells
        IDs = neighborID{tref,i};
        if ~isnan(IDs)
            IDs = IDs(IDs > 0);
            if nanflag
                corona_measurement(t,i) = nansum(measurement(t,IDs));
            else
                corona_measurement(t,i) = sum(measurement(t,IDs));
            end
        end
    end
end
