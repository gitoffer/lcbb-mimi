function stics_dots = getDots4Stics(vector,window,direction)
% Calculates the value of the average dotproduct between each STICS vector
% and its neighbors as specified by window. Will normalize by vector norm.

% Can specify separating XY direction.

n = length(vector);
[x,y,z] = size(vector{1}(:,:,:));
currVec = zeros(1,2);

% default windows both X and Y
if direction == 'XY'
    stics_dots = zeros(x,y,n);
    
    for i = 1:n
        
        padded = padarray(vector{i}(:,:,:),[window window]);
        for j = 1+window:x+window
            for k = 1+window:y+window
                
                currVec(:) = padded(j,k,:);
                windowSize = (2*window+1)^2;
                
                % extracts the neighbors without the self vector
                bottom = floor(windowSize/4);
                top = ceil(windowSize/2);
                neighbors = padded(j-window:j+window,k-window:k+window,:);
                neighbors = reshape(neighbors,windowSize,z);
                neighbors = cat(1,neighbors(1:bottom,:),neighbors(top+1:windowSize,:));
                % a vector of the norms of all XY-neighbors
                dots = currVec*neighbors';
                
                selfNorm = norm(currVec);
                neighborNorms = sqrt(diag(neighbors*neighbors'))';
                normalDots = dots/selfNorm./neighborNorms;
                % replaces NaN by 0 (from 0-division)
                normalDots(isnan(normalDots))=0;
                
                if sum(normalDots)/(windowSize-1) > 1
                    error('over 1')
                end
                stics_dots(x+1-(j-window),k-window,i) = sum(normalDots)/(windowSize-1);
            end
        end
    end
    
    
% user specified X or Y windowing direction    
else
    
    if direction == 'x' || direction == 'X'
        for i = 1:n
            vector{i} = permute(vector{i},[2 1 3]);
        end
        foo = x;
        x= y;
        y = foo;
        
    elseif direction == 'y' || direction == 'Y'
    else
        error(['Unrecognized dimension argument ',optargin])
    end
    
    stics_dots = zeros(x,y,n);
    
    for i = 1:n
        padded = padarray(vector{i}(:,:,:),[window window]);
        
        for j = 1+ window:x+window
            for k = 1+window:y+window
                
                currVec(:) = padded(j,k,:);
                selfNorm = norm(currVec);
                windowSize = 2*window+1;
                
                %X-neighbors
                neighbors = reshape(padded(j-window:j+window,k,:),windowSize,z);
                neighbors = cat(1,neighbors(1:floor(windowSize/2),:),neighbors(ceil(windowSize/2)+1:windowSize,:));
                neighborNorms = diag(sqrt(neighbors*neighbors'))';
                
                dots = currVec*neighbors';
                normalDots = dots/selfNorm./neighborNorms;
                normalDots(isnan(normalDots))=0;
                stics_dots(x+1-(j-window),y+1-(k-window),i) = sum(normalDots)/(windowSize-1);
                
            end
        end
    end
    if direction == 'x' || direction == 'X'
        stics_dots = permute(stics_dots,[2 1 3]);
    end
end