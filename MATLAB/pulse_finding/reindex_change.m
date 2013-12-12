function changes = reindex_change(changes,embryoID)

categories = {'tracksMadeFromFit','fitIDRemoved','fitsMadeFromTrack','trackIDRemoved'};

for j = 1:numel(categories)
    
    if ~isfield(changes, categories{j})
        continue
    end
        
    this_change = changes.( categories{j} );
    
    for i = 1:numel(this_change)
        
        if isstruct( this_change(i) )

            if isfield(this_change(i),'fitID')

                oldID = this_change(i).fitID;
                base = floor( log10(oldID) );
                old_embryoID = num2str(oldID);
                old_embryoID = str2double(old_embryoID( find(old_embryoID > '0', 1) ));
                this_change(i).fitID = oldID - (old_embryoID * 10^base) + (embryoID * 10^base);
            end

            if isfield(this_change(i),'trackID')
                oldID = this_change(i).trackID;
                base = floor( log10(oldID) );
                old_embryoID = num2str(oldID);
                old_embryoID = str2double(old_embryoID( find(old_embryoID > '0', 1) ));
                this_change(i).trackID = oldID - (old_embryoID * 10^base) + (embryoID * 10^base);
            end
            
        else
            
            oldID = this_change(i);
            base = floor( log10(oldID) );
            old_embryoID = num2str(oldID);
            old_embryoID = str2double(old_embryoID( find(old_embryoID > '0', 1) ));
            this_change(i) = oldID - (old_embryoID * 10^base) + (embryoID * 10^base);
            
        end
        
    end
    
    changes.(categories{j}) = this_change;
    
end

end