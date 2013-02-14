function tracks = read_mdf(name)
%READ_MDF Reads data from a .mdf file created by the MTrackJ plugin in
% ImageJ.  The file can contain an arbitrary number of tracks, but only 
%  one assembly and one cluster.
%
%  USAGE: tracks = read_mdf('path_to_file')
% 
%  INPUT: name = name of the file (include the .mdf extension)
%  
%  OUTPUT: tracks = matrix in which each row is a point in a track and the
%  columns correspond to the track number, the point number within the
%  track, the x coordinate, y coordinate, z coordinate, and t coordinate
%  (z and t coordinates are typically slice numbers)
%
%  Sample track matrix:
%   Track ID  Point in  X coord  Y coord   Z coord   Time in
%             track								     the movie
%
%   1         1         22.2     98.5      1         2.3
%   1         2         28.4     101.2     1         4.6
%   1         3         32.4     96.1      1         6.9
%   2         1         56.3     3.2       1         2.3
%   2         1         49.9     5.3       1         4.6
%
%	This matrix contains two tracks where track 1 is longer than track 2.
%
%  Created 6/18/09 by Nilah@MIT.
%  Modified for QBio Workshop, MIT 2012 by xies@mit.

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
        tracks = [tracks; pointVector];                         % add this point to tracks matrix
    end
end

fclose(fin);

%  End of read_mdf.m
