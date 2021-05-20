function [ model ] = OFModDisc( label,r, density )
%OFMODDISC returns a planar circular disc
%
%Input:
%Input:
%   label - String to label the model
%   r - the radius of the ring and the discs
%   h - the height of the ring
%   density - optional parameter density gives the number of vertices used
%       to aproximate the circle
%
%Output:
%   a model containing the disc
%   the disc forms a single polygon
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


disc=struct('vert', 'tri', 'poly', 'label');

if(nargin==2)
    d=6;
elseif(nargin==3)
    d=density;
end

%   divides an unitcircle into n (density) equal parts
t = 0:pi/(d/2):2*pi;

%   computes the vertices and forms the triangles and the polygon:
V=[0 0 0];
T=[1 length(t) 2];  % the "overlap" triangle to close the disc
P=[];
k=2;
for a=t(1:length(t)-1),
    V=[V;sin(a)*r cos(a)*r 0]; % computes the actual point
    T=[T;1 k k+1];  % forms an triangle with center, actual and next pointIndex
    P=[P k];    % extends the polygon with new pointIndex
    k=k+1;
end

T(length(T),:)=[];  % deletes the last triangle because j+1 in loop is out of range
disc.vert=V;
disc.poly={P};
disc.tri=T;
disc.label=label;
model={disc};

end

