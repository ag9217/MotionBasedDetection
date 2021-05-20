function [ model ] = OFModRing( label, r, h, density )
%OFMODRING returns a circular ring made from rectangles
%
%Input:
%   label - String to label the model
%   r - gives the radius of the circle
%   h - the height of the rectangles
%   density - (opional) gives the number of rectangles to aproximate
%       the ring
%
%Output:
%   A model containing the ring.
%   The ring forms a single object.
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


ring=struct('vert', 'tri', 'poly', 'label');

if(nargin==3)
    d=6;
elseif(nargin==4)
    d=density;
end

%   divides an unitcircle into n (density) equal parts
t = 0:pi/(d/2):2*pi;

% computes the vertices:
V=[];
for v=t(1:length(t)-1),
    V=[V;sin(v)*r cos(v)*r -h/2; sin(v)*r cos(v)*r h/2];
end

% computes the triangles and squares:
T=[length(V)-1 length(V) 1; length(V) 2 1]; %closing the ring (overlap)
P={[length(V)-1 length(V) 2 1]}; % closing the ring (overlap)
m=1;
for i=2:length(V)/2,
    T=[T;m m+1 m+3; m m+3 m+2]; %two triangles
    P=[P {[m m+2 m+3 m+1]}]; % one square
    m=m+2;  
end
ring.vert=V;
ring.tri=T;
ring.poly=P;
ring.label=label;
model={ring};
end

