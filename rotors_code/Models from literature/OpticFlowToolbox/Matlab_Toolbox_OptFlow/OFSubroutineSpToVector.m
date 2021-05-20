function [ vector ] = OFSubroutineSpToVector( sphericCoord )
%OFSUBROUTINESPTOVECTOR recieves a pair of spheric coordinates and
%converts them into a 3dim vector.
%
%Input:
%   sphericCoord - a Sx2 matrix with spheric coordinates
%
%Output:
%   vector a Sx3 matrix with the transformed coordinates
%
%NOTE: this is NOT the normal spheic coordinate system!
%   spheric coordinates given as azimuth (Longitude) and
%   zenith (Latitude) given in geographic coordinate system) in radian
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


sp=sphericCoord;

vector = zeros([size(sp,1) , 3]);

for k=1:size(sp,1)
    vector(k,:)=[cos(sp(k,2))*cos(sp(k,1)) cos(sp(k,2))*sin(sp(k,1)) sin(sp(k,2))];
end

