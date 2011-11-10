function stics_dots = getDotsTemporal(vector,window)

% Calculates the value of the average dotproduct between each STICS vector
% and its neighbors as specified by window. Will normalize by vector norm.

% Can specify separating XY direction.

n = length(vector);
[x,y,~] = size(vector{1}(:,:,:));

stics_dots = zeros(x,y,n);
currDots = zeros(x,y,2*window);

% for i = 1:n
%     fieldX(i,:,:) = vector{i}(:,:,1);
%     fieldY(i,:,:) = vector{i}(:,:,2);
% end

for i = 1:n
    currField = reshape(vector{i}(:,:,:),x*y,2);
    currNorm = sqrt(dot(currField,currField,2));
    index = 0;
    for j = i-window:i+window
        if j < 1 || j > n
            nextField = zeros(x*y,2);
            nextNorm = ones(x*y,1);
        else
            nextField = reshape(vector{j}(:,:,:),x*y,2);
            nextNorm = sqrt(dot(nextField,nextField,2));
        end
        index = index + 1;
        currDots(:,:,index) = reshape(dot(currField,nextField,2)./currNorm./nextNorm,x,y);
    end
    stics_dots(:,:,i) = mean(currDots,3);
end

end