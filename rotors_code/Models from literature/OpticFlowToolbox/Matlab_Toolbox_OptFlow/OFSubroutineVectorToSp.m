function [ sp ] = OFSubroutineVectorToSp( vector )
%OFSUBROUTINEVECTORTOSP converts an 3dim vector to spheric coordinates
%
%Input:
%   vector a Sx3 matrix with the 3d coordinates
%
%Output:
%   sphericCoord - a Sx2 matrix with spheric coordinates
%
%NOTE: this is NOT the normal spheic coordinate system!
%   azimuth (Longitude) 
%   zenith (Latitude) given in geographic coordinate system in radian
%   [pi/2 0]= [0 1 0] left, [3*pi/2 0]= [0 -1 0] right,
%   [0 pi/2]= [0 0 1] top,  [0 -pi/2]= [0 0 -1] bottom
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Copyright (C) 2009-2014 J.P. Lindemann, C. Strub
%		
%   This file is part of the ivtools.
%   https://opensource.cit-ec.de/projects/ivtools
%
%   the Optic-Flow toolbox is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%   the Optic-Flow toolbox is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


sp = zeros( [ size(vector,1) 2 ]);
for k=1:size(vector,1)
    % to prevent a devision by 0:
    if~(vector(k,1)==0&&vector(k,2)==0)
        % to prevent of geting an negative azimuth angle:
        if(vector(k,2)>=0)
            sp(k,1)=acos(vector(k,1)/sqrt(vector(k,1)^2+vector(k,2)^2));
        else
            sp(k,1)=2*pi-acos(vector(k,1)/sqrt(vector(k,1)^2+vector(k,2)^2));
        end
        sp(k,2)=atan(vector(k,3)/sqrt(vector(k,1)^2+vector(k,2)^2));
    else % x and y coordinates of vector are 0 so:
        sp(k,1)=0;
        sp(k,2)=sign(vector(k,3))*pi/2;
    end
end
end

