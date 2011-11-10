function bg = estimate_background(image)

% Need to vectorize!

lower_left = floor(size(image,1)/20);
lower_right = floor(size(image,2)/20);
upper_left = size(image,1) - lower_left;
upper_right = size(image,2) - lower_right;

n = numel(1:lower_left)*numel(1:size(image,2)) + ...
    numel(upper_left:size(image,1))*numel(1:size(image,2)) + ...
    numel(1:lower_right)*numel(lower_left+1:upper_left-1) + ...
    numel(upper_right:size(image,2))*numel(lower_right+1:upper_right-1);


offset = sum(sum(image(1:lower_left,1:size(image,2),:))) + ...
    sum(sum(image(upper_left:size(image,1),1:size(image,2),:))) + ...
    sum(sum(image(lower_left+1:upper_left-1,1:lower_right,:))) + ...
    sum(sum(image(lower_right+1:upper_right-1,upper_right:size(image,2),:)));
offset = offset/n;

bg = offset;

% T = size(image,3);
% bg = zeros(1,T);
% 
% for t = 1:T
%     lower_left = floor(size(image,1)/20);
%     lower_right = floor(size(image,2)/20);
%     upper_left = size(image,1) - lower_left;
%     upper_right = size(image,2) - lower_right;
%     offset = 0;
%     n = 0;
%     for i=1:lower_left
%         for j=1:size(image,2)
%             offset=offset+image(i,j,1);
%             n=n+1;
%         end
%     end
%     for i=upper_left:size(image,1)
%         for j=1:size(image,2)
%             offset=offset+image(i,j,1);
%             n=n+1;
%         end
%     end
%     for j=1:lower_right
%         for i=lower_left+1:upper_left-1
%             offset=offset+image(i,j,1);
%             n=n+1;
%         end
%     end
%     for j=upper_right:size(image,2)
%         for i=lower_right+1:upper_right-1
%             offset=offset+image(i,j,1);
%             n=n+1;
%         end
%     end
%     
%     offset=offset/n;
%     bg(t)=offset;
% end
