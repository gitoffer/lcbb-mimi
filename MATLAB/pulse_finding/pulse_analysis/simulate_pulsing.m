function [pulses,simulated_sequence] = simulate_pulsing(cells,fits,frequency)
%SIMULATE_PULSING

Nembryos = numel(unique([fits.embryoID]));

Npulses = numel(fits);

pulses(Npulses).center = [];
pulses(Npulses).fitID = [];
pulses(Npulses).cluster_label = [];
pulses(Npulses).stackID = [];
pulses(Npulses).embryoID = [];
pulses(Npulses).centroid_x = [];
pulses(Npulses).centroid_y = [];

total_fit = 0;

simulated_sequence = [];

for embryoID = 1:Nembryos
    
    pulses_in_embryo = fits.get_embryoID(embryoID).sort('center');
    cells_in_embryo = cells.get_stackID( unique([pulses_in_embryo.stackID]) );
    
    Ncells = numel(cells_in_embryo);
    seq = cell(1,Ncells);
    
    for i = 1:numel(pulses_in_embryo)
        
        accept = 0;
        this_pulse = pulses_in_embryo(i);
        
        while ~accept
            
            randomID = randi(Ncells);
            already_seen = seq{randomID};
            
            if isempty(already_seen)
                
                frame = findnearest( cells_in_embryo(randomID).dev_time, this_pulse.center);
                if numel(frame) > 1, frame = frame(1); end
                
                if isnan(cells_in_embryo(randomID).centroid_x(frame))
                    accept = 0;
                    
                else
                    seq{randomID} = ...
                        [seq{randomID}, this_pulse.center];
                    total_fit = total_fit + 1;
                    pulses(total_fit).fitID = this_pulse.fitID;
                    pulses(total_fit).cluster_label = this_pulse.cluster_label;
                    pulses(total_fit).center = this_pulse.center;
                    pulses(total_fit).stackID = cells_in_embryo(randomID).stackID;
                    pulses(total_fit).centroid_x = cells_in_embryo(randomID).centroid_x(frame);
                    pulses(total_fit).centroid_y = cells_in_embryo(randomID).centroid_y(frame);
                    pulses(total_fit).embryoID = embryoID;
                    accept = 1;
                    
                end
                
            else
                
                f = this_pulse.center - already_seen(end);
                
                frame = findnearest( cells_in_embryo(randomID).dev_time, this_pulse.center);
                if numel(frame) > 1, frame = frame(1); end
                
                if isnan(cells_in_embryo(randomID).centroid_x(frame))
                    accept = 0;
                else
                    % Figure out if input frequency is a histogram or not
                    if isfield(frequency,'bin') && ~isfield(frequency,'fun')
                        idx = findnearest(frequency.bin,f);
                        p = frequency.prob(idx);
                    elseif ~isfield(frequency,'bin') && isfield(frequency,'fun')
                        p = feval(frequency.fun,f);
                    end
                    % How to accept?
                    x = rand;
                    if x >= p,
                        accept = 0;
                    else
                        seq{randomID} = ...
                            [seq{randomID}, this_pulse.center];
                        total_fit = total_fit + 1;
                        pulses(total_fit).fitID = this_pulse.fitID;
                        pulses(total_fit).cluster_label = this_pulse.cluster_label;
                        pulses(total_fit).center = this_pulse.center;
                        pulses(total_fit).stackID = cells_in_embryo(randomID).stackID;
                        pulses(total_fit).centroid_x = cells_in_embryo(randomID).centroid_x(frame);
                        pulses(total_fit).centroid_y = cells_in_embryo(randomID).centroid_y(frame);
                        pulses(total_fit).embryoID = embryoID;
                        accept = 1;
                        
                    end % accept
                    
                end % isNaN
                
            end
            
        end
        
        if any(isnan( [pulses.centroid_x] )),
            keyboard;
        end
        
    end
    
    simulated_sequence = [simulated_sequence seq];
    
end
