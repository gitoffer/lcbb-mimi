function [pulses,simulated_sequence] = simulate_pulsing(cells,fits,frequency,pulse_count)
%SIMULATE_PULSING
%
% xies@mit.edu

Nembryos = numel(unique([fits.embryoID]));

Npulses = numel(fits);

% Initialize pulse
pulses(Npulses).center = [];
pulses(Npulses).fitID = [];
pulses(Npulses).cluster_label = [];
pulses(Npulses).stackID = [];
pulses(Npulses).embryoID = [];
pulses(Npulses).centroid_x = [];
pulses(Npulses).centroid_y = [];
total_fit = 0;
simulated_sequence = [];

% Scatter all pulses amongst pulses
for embryoID = 1:Nembryos
    
    % Sort pulses by their center of occurence
    pulses_in_embryo = fits.get_embryoID(embryoID).sort('center');
    cells_in_embryo = cells.get_stackID( unique([pulses_in_embryo.stackID]) );
    
    % Initialize
    Ncells = numel(cells_in_embryo);
    seq = cell(1,Ncells);
	
    for i = 1:numel(pulses_in_embryo)
        
        accept = 0;
        this_pulse = pulses_in_embryo(i);
        
        while ~accept
            
            % Find candidate
            randomID = randi(Ncells);
            already_seen = seq{randomID};
            
            this_count = numel(already_seen); %number of pulses in this cell already
            
            if rand >= pulse_count(this_count + 1);
                accept = 0;
            else
                
                if isempty(already_seen) % TODO: need to change here
                    
                    frame = findnearest( cells_in_embryo(randomID).dev_time, this_pulse.center);
                    if numel(frame) > 1, frame = frame(1); end
                    
                    if isnan(cells_in_embryo(randomID).centroid_x(frame))
                        accept = 0;
                        
                    else
                        % Accept this move
                        seq{randomID} = ...
                            [seq{randomID}, this_pulse.center];
                        total_fit = total_fit + 1;
                        accept = 1;
                        pulses = accept_pulse( pulses, total_fit, ...
                            this_pulse, cells_in_embryo(randomID) );
                    end
                    
                else
                    % If there is already a
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
                        if rand >= p %rand generates a random uniform number [0,1]
                            accept = 0;
                        else
                            % Accept this move
                            seq{randomID} = ...
                                [seq{randomID}, this_pulse.center];
                            total_fit = total_fit + 1;
                            pulses = accept_pulse( pulses, total_fit, ...
                                this_pulse, cells_in_embryo(randomID) );
                            accept = 1;
                            
                        end % whether to accept based on random number
                        
                    end % Make sure cell is non-NAN
                    
                end % Condition on distribution of intervals
                
            end % Condition on distribution of pulses
            
        end
        
        if any(isnan( [pulses.centroid_x] )),
            keyboard;
        end
        
    end
    
    simulated_sequence = [simulated_sequence seq];
    
end

end

function pulses = accept_pulse(pulses,idx,this_pulse,this_cell)
%ACCEPT_PULSES Input pulse into the array

	pulses(idx).fitID = this_pulse.fitID;
	pulses(idx).cluster_label = this_pulse.cluster_label;
	pulses(idx).center = this_pulse.center;
	pulses(idx).stackID = this_cell.stackID;
	frame = findnearest( this_cell.dev_time, this_pulse.center );
    if numel(frame) > 1, frame = frame(1); end
	pulses(idx).centroid_x = this_cell.centroid_x(frame);
	pulses(idx).centroid_y = this_cell.centroid_y(frame);
	pulses(idx).embryoID = this_pulse.embryoID;
	
end
