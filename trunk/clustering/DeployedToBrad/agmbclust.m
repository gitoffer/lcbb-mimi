function Z = agmbclust(X);

% AGGLOMERATIVE MODEL BASED CLUSTERING - NO INITIAL PARTITION
%
% This function does the agglomerative model-based clustering
% of Fraley. NOTE that this one does the MB agglomerative 
% clustering from the FULL data set.
%
%   Z = AGMBCLUST(X)
%
%   The output Z contains the cluster array that MATLAB expects.
%   This can be used in the DENDROGRAM or the RECTPLOT plotting 
%   functions.

%   Model-based Clustering Toolbox, January 2003


% NOTE THAT THIS ONE DOES THE IMPLEMENTATION OF CHRIS IN THE
% PAPER GIVEN IN THE CLASS NOTES. THIS EQUATION IS SLIGHTLY 
% DIFFERENT THAN THE ONE IN THE PUBLISHED PAPER. 
% NOTE ALSO THAT THIS MODIFIED TERM IS NEEDED WHEN THE INITIAL
% PARTITION IS SINGLETONS.

% NOTE THAT WE ARE GOING TO USE THE STRUCTURE OF THE CLUSTERING
% THAT COMES FROM MATLAB - SO WE CAN DO THE DENDROGRAM.

[n,p] = size(X);
% Get script W - sample cross-product matrix - all data.
Ws = cov(X)*(n-1);
% Get the trace of it.
trWs = trace(Ws);
% Get the constant term.
cons = trWs/(n*p);

% Matrix to store the resulting cluster structure. This matches MATLAB's.
Z = zeros(n-1,3);   % first two cols are cluster numbers, 3rd is criterion.

G = n;	% initially there are n singleton clusters.

% set up some storage space.
nk = ones(1,G);	% Store the number in each cluster
sk = X;				% Store the sum of the observations in each cluster.
trWk = zeros(1,G);	% Store the trace of each cluster.
detWk = zeros(1,G);	% Store the determinant of each cluster.
Wk = cell(1,G);		% Store the cross-product matrices in each.
tmp = zeros(G);		% This will be used to temporarily store the delta_ij
obf = zeros(1,n); % This will store the value of the objective function.
% Note that the first element corresponds to the initial value. Then each
% successive element is the value of the ojbective function after merging
% two clusters.

% Initial partition is each point in its own cluster.
clabs = 1:n;
ucl = unique(clabs);

% Initial sample-cross product matrices are all zeros.
for i = 1:G
    Wk{i} = zeros(p);
end

% Get the indices for the initial delij.
% These will be the indices for the upper part of the delta_ij matrix.
pp = (n-1):-1:2;
I = zeros(n*(n-1)/2,1);
I(cumsum([1 pp])) = 1;
I = cumsum(I);
J = ones(n*(n-1)/2,1);
J(cumsum(pp)+1) = 2-pp;
J(1)=2;
J = cumsum(J);
% Place to store the delta's for the objective function.
delij = zeros(length(I),1);
% This will store the indices to the pointers to the clusters.
% It is the lowest index of the observations in the cluster.
% Note that I and J are cluster numbers, while ptrij are pointers to
% the cluster index where stuff is stored.
ptrij = [I,J];

% Initialize the delta_ij 
for g = 1:length(I)
	i = I(g);
	j = J(g);
	Wkt = cov(X([i,j],:));
	delij(g) = 2*log(det(Wkt/2) + trace(Wkt/2) + cons) - 2*log(cons);
end

% Initial value of the objective function.
obf(1) = n*log(cons);

% Must do n-1 links
for k = 1:(n-2)
    disp(['Merging clusters ... step ' int2str(k)])

	
% Find the smallest one. Store the value in the Z matrix.
	[iv,im] = min(delij);
    
    % Get the new value of the objective function.
    obf(k+1) = obf(k) + iv;
	
    % These are the two groups that will be merged.
    groupi = I(im);
    groupj = J(im);
	% Put the clusters in the Z matrix.
    Z(k,1:2) = sort([groupi, groupj]);
    Z(k,3) = obf(k+1);

    % Find all of the points belonging to these two groups and reassign labels.
    indi = find(clabs == groupi);
    indj = find(clabs == groupj);	
	clusnum = k+n;
    clabs(indi) = clusnum;		% Recall that clabs is 1-1 with observations.
    clabs(indj) = clusnum;
	% The storage index for the new group is the smallest one.
	indij = min([indi(:);indj(:)]);

	% Update the I and the J values to reflect the new cluster assignment.
	% Recall that I and J correspond to the cluster numbers in the delij and ptrij arrays.
	indi = find(I == groupi | I == groupj);
	indj = find(J == groupi | J == groupj);
	I(indi) = clusnum;
	J(indj) = clusnum;

	% Update the nk, sk, trWk, detWk
	it = ptrij(im,1);	% pointer to the i cluster stuff
	jt = ptrij(im,2);	% pointer to the j cluster stuff
	ni = nk(it); 
	nj = nk(jt);
	nij = sqrt(ni/(nj*(ni+nj)));
	nji = sqrt(nj/(ni*(nj+ni)));
	up =  nji*sk(it,:) - nij*sk(jt,:);
    
    % Now do the actual updates.
    nk(indij) = ni + nj;
	Wk{indij} = Wk{it} + Wk{jt} + up(:)*up(:)';
	detWk(indij) = det(Wk{indij}/nk(indij));
	trWk(indij) = trace(Wk{indij}/nk(indij));
	sk(indij,:) = sk(it,:) + sk(jt,:);

    % Then delete the row in delij and ptrij and I and J.
    % This one is the one that will be combined.
	% Note that I and J will contain the cluster numbers.
	delij(im) = [];
	ptrij(im,:) = [];
    I(im) = [];
    J(im) = [];
	
%	indel = delobs2(I,J);
	
	indel = delobs(I,J,clusnum)';	% subfunction below
    
    % Delete those rows.
    I(indel) = [];
    J(indel) = [];
    delij(indel) = [];
    ptrij(indel,:) = [];
	

    % Find all of the guys that belong to the new cluster.
	indi = find(I==clusnum);
	indj = find(J==clusnum);
	% Update the ptrij to point to where the new cluster info is stored.
	ptrij(indi,1) = indij;
	ptrij(indj,2) = indij;
	
	% Update the delij.
	% First find all of the 'I clusters' that belong to the new cluster
	% and update their delta_ij and ptrij.
	for i = 1:length(indi);
        it = ptrij(indi(i),1);
		jt = ptrij(indi(i),2);	% pointer to the j cluster stuff.
		% First update Wij - this would combine the new cluster plus
        % the j cluster.
        nj = nk(jt);
        ni = nk(it);
        nt = ni + nj;
        st = sk(it,:) + sk(jt,:);
        nij = sqrt(ni/(nj*nt));
        nji = sqrt(nj/(ni*nt));
        up =  nji*sk(it,:) - nij*sk(jt,:);
        Wkt = Wk{it} + Wk{jt} + up(:)*up(:)';
        detWkt = det(Wkt/nt);
        trWkt = trace(Wkt/nt);
		% Then get O(Wij) - O(Wi) - O(Wj)
		delij(indi(i)) = nt*log(detWkt + trWkt + cons) - ...
			ni*log(detWk(it) + trWk(it) + cons) - ...
            nj*log(detWk(jt) + trWk(jt) + cons);
    end
    % Then find all of the 'J clusters' that belong to group i or groupj
    % and update their delta_ij and ptrij.
    for i = 1:length(indj)
        it = ptrij(indj(i),1);
		jt = ptrij(indj(i),2);	% pointer to the j cluster stuff.
		% First update Wij - this would combine the new cluster plus
        % the j cluster.
        ni = nk(it);
        nj = nk(jt);
        nt = ni + nj;
        st = sk(it,:) + sk(jt,:);
        nij = sqrt(ni/(nj*nt));
        nji = sqrt(nj/(ni*nt));
        up =  nji*sk(it,:) - nij*sk(jt,:);
        Wkt = Wk{jt} + Wk{it} + up(:)*up(:)';
        detWkt = det(Wkt/nt);
        trWkt = trace(Wkt/nt);
		% Then get O(Wij) - O(Wi) - O(Wj)
		delij(indj(i)) = nt*log(detWkt + trWkt + cons) - ...
			ni*log(detWk(it) + trWk(it) + cons) - ...
            nj*log(detWk(jt) + trWk(jt) + cons);
    end
    
  
end

% Now do the last one.
% Find the smallest one. Store the value in the Z matrix.
% Get the new value of the objective function.
%[iv,im] = min(delij);
obf(n) = obf(n-1) + delij;
% Put the clusters in the Z matrix.
% These are the last two that can be clustered.
Z(n-1,1:2) = sort([I J]);
Z(n-1,3) = obf(n);


%%%%%%%%%%%%%%%%%%%  FUNCTION - DELOBS %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% Check the other way to find deleted observations.
function indel = delobs(I,J,clusnum)

IJ = [I,J];
[n,p] = size(IJ);

inds = find(I==clusnum | J==clusnum);

tmp = IJ(inds,:);	% put into one matrix
ts = sort(tmp,2);	% sort each row

% find the unique rows. These should be the indices we keep.
[b,i,j] = unique(ts,'rows');

% find the ones to delete.
indt = setdiff(1:length(inds) , i);

indel = inds(indt);