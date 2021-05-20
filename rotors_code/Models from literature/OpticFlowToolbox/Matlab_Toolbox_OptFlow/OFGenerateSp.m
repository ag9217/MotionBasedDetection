function [ sp ] = OFGenerateSp( left, right, top, bottom, varargin )
%OFGENERATESP generates a samplepoint matrix acording to user
%specifications:
%azimuth
%              Pi= front
%                 _
%                 ^
%             /   |   \
% Pi/2 =left      |       3*Pi/2 = right
%             \   |   /
%                 _
%             0 = back
%---------------------------------------------
%elevation
%              Pi/2 = top
%                 _
%                 
%             /       \
%             ------------>  0 = front
%             \       /
%                 _
%             -Pi/2 = bottom
%
%Input:
%   left - the left border of the sp [pi - 0]
%   right - the right border of the sp [pi - 2*pi]
%   top - the top border of the sp [0 - pi/2]
%   bottom - the bottom border of sp [0 - pi/2]
%Optional:
%   density azimuth - number of sp Columns
%   density elevation - number of sp Rows. if no elevationdensity is given,
%       elevation = azimuth density
%   if no density is given, azimuth and elevation density will be set to 8.
%   the first sp will be placed on the left and the right sp on the right
%   border. the "rest" will be placed (equaly spaced) in between.
%
%Output:
% an sp matrix with numberxnumber samplepoints within the borders
%
%Caution: left and right borders schould not exceed  0 or 2pi
%
%Example:
%
% OFGenerateSp( 0,2*pi,0,0) would make 64 samplepoints 0-360°on the horizon
%       but always 8 of them lie on top of each other.
%
% OFGenerateSp( pi/2 ,5*pi/4,pi/4,-pi/4,11) would make 221 samplepoints
%   in an area 90° left to 45° right and 45° top to 45° bottom relative to
%   front viewing direction (11 columns and 11 rows)
%
% OFGenerateSp( pi/3 ,5*pi/3,pi/2,-pi/2,12,6) would make 221 samplepoints
%   in an area 60° left to 60° right and 90° top to 90° bottom relative to
%   front viewing direction (12 columns and 6 rows)
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


optargin=size(varargin,2);
if(optargin==1)
    densityAZI=varargin{1};
    densityELE=varargin{1};
elseif(optargin==2)
    densityAZI=varargin{1};
    densityELE=varargin{2};
else
    densityAZI=8;
    densityELE=8;    
end

azimuth = repmat(linspace(left,right,densityAZI)', densityELE , 1);
elevation = repmat(linspace(left,right,densityAZI)', densityELE , 1);

azimuth=azimuth+pi;
for k=1:size(azimuth,1)
    if azimuth(k)>(2*pi)
        azimuth(k)=azimuth(k)-(2*pi);
    end
end

l=1;
for k=1:size(azimuth,1)
    azimuth(k)=2*pi-azimuth(k);
    if(l==densityAZI)
        azimuth(k-l+1:k)=flipdim(azimuth(k-l+1:k),1);
        l=0;
    end
    l=l+1;
end

temp = linspace(top,bottom,densityELE);
for k = 1:densityELE,
    for l=1:densityAZI,
        elevation(l + (densityAZI*(k-1)) , 1 ) = temp(k);
    end;
end
sp = [azimuth elevation];
end

