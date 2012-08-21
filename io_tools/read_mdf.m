function tracks = read_mdf(name)
%  Reads data from a .mdf file created by the MTrackJ plugin in ImageJ
%  The file can contain an arbitrary number of tracks, but only 
%  one assembly and one cluster.
%
%  Input: name = name of the file (include the .mdf extension)
%  
%  Output: tracks = matrix in which each row is a point in a track and the
%  columns correspond to the track number, the point number within the
%  track, the x coordinate, y coordinate, z coordinate, and t coordinate
%  (z and t coordinates are typically slice numbers)
%
%  Created 6/18/09

%  Open file for input
fin = fopen(name,'r');

%  Read and discard the 4 lines of header text
for i=1:4,  buffer = fgetl(fin);  end

%  Add each point and its coordinates as a row in the matrix of tracks
tracks = [];
while true
    buffer = fgetl(fin);
    [token,remain] = strtok(buffer);        % get first word in line and remainder of line
    if strcmp(token,'End'), break; end      % end loop when last line ("End of MTrackJ data file") is reached
    if strcmp(token,'Track')                % if starting new track...
        trackIndex = str2double(strtok(remain));    % get track number from remainder
    elseif strcmp(token,'Point')            % if reading a point in a track...
        [token2,remain2] = strtok(remain);
        pointIndex = str2double(token2);            % get point number
        pointCoords = sscanf(remain2,'%f',4)';      % read x,y,z,t coordinates from the remainder of the line
        pointVector = [trackIndex, pointIndex, pointCoords];    % generate row vector containing this point's data
        pointVector(3:5) = pointVector(3:5)+1;                  % conversion between MTrackJ and Matlab indexing
        tracks = [tracks; pointVector];                         % add this point to tracks matrix
    end
end

%  End of read_mdf.m
