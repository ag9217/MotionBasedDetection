function [ model ] = OFModSphere( label, r, density )
%OFMODSPHERE returns a sphere
%
%Input:
%   label - String to label the model
%   r - radius,
%   density - opt. param. specifies the density of the mesh (default is 20)
%
%Output:
%   a model which contains the sphere
%   the sphere forms a single object
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


sph = struct('vert','tri','poly','label');

% generating a unitsphere (optional density)
dens=0;
if(nargin==2)
    [X,Y,Z]=sphere;
    dens=length(X)-1; % matrices have n+1 dimension
elseif(nargin==3)
    [X,Y,Z]=sphere(density);
    dens=length(X)-1; % matrices have n+1 dimension
end

% expanding it to given radius
X=X.*r;
Y=Y.*r;
Z=Z.*r;

%--- VERTICES ---
% defining bottom point
vertices=[X(1,1),Y(1,1),Z(1,1)];

% taking the needed 30-points from the matrices
for k=2:dens
    for m=1:dens
        vertices=[vertices;X(k,m),Y(k,m),Z(k,m)];
    end
end

% adding the top point
vertices=[vertices;X(dens+1,1),Y(dens+1,1),Z(dens+1,1)];
sph.vert=vertices;

%--- TRIANGLES | SQUARES ---
m=2;    % index of the vertices
T=[];
P={};
% computing the first bottom row of triangles
for k=1:dens-1
    %   neighbours
    T=[T;1 m m+1];
    P=[P {[1 m m+1]}];
    m=m+1;
end
%   +overlapping
T=[T;1 m m-(dens-1)];
P=[P {[1 m m-(dens-1)]}];
m=m+1;

% computing the middle row of into triangles devided squares | squaeres
for n=1:dens-2
    %   neighbours
    for k=1:dens-1
      T=[T;m-dens m m+1];
      P=[P {[m-dens m m+1 m-(dens-1)]}];
      T=[T;m-dens m+1 m-(dens-1)];
      m=m+1;
    end
    %   +overlapping
    T=[T;m-dens m m-(dens-1)];    
    T=[T;m-dens m-(dens-1) m-(2*dens-1)];
    P=[P {[m-dens m m-(dens-1) m-(2*dens-1)]}];
    m=m+1;
end

% computing the top row of triangles
for n=1:dens-1
    %   neighbours
    T=[T;m m-((dens+1)-n) m-((dens+1)-(n+1))]; 
    P=[P {[m m-((dens+1)-n) m-((dens+1)-(n+1))]}];
end
%   +overlapping
T=[T;m m-1 m-dens];
P=[P {[m m-1 m-dens]}]; 


sph.tri=T;
sph.poly=P;
sph.label=label;
model={sph};
end

