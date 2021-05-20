function [ model ] = OFModPolygon( label, varargin )
%OFMODPOLYGON returns an konvex polygon defined by any number of vertices
%   the vertices must be planar and have to define a konvex polygon.
%
%Input:
%   label - the label of the polygon
%   varargin - variable number of 3d-vertices (at least 3)
%       which define the polygon
%
%Output:
%   returns an model containing the polygon
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


polygon = struct('vert','tri','poly','label');
polygon.label=label;


if nargin < 4
    error('you have to give at least three vertices')
end
polygon.vert=[];
% first the vertices are combined in a matrix (as long as they are 3d)
for k= 1:nargin-1
    if size(varargin{k},2)~=3
        error('verices have to be 3dim');
    else
        polygon.vert=[polygon.vert;varargin{k}];
    end
end

%now the planarity is checked
ref1=-polygon.vert(1,:)+polygon.vert(2,:);
ref2=-polygon.vert(1,:)+polygon.vert(3,:);
% find a second vertice which is not collinear
for k=4:size(polygon.vert,1)
    if(norm(cross(ref1,-polygon.vert(1,:)+polygon.vert(k,:)))~=0)
        ref2=-polygon.vert(1,:)+polygon.vert(k,:);
        break;
    end
end

% check if the vertices are all collinear
if(norm(cross(ref1,ref2))==0)
    error('vertices are all collinear or double vertices!');
end
%   if the matrix, containing three points, is singular ->all point are planar
for k=4:size(polygon.vert,1)
    refpoint=-polygon.vert(1,:)+polygon.vert(k,:);
    A=[ref1; ref2; refpoint];
    if(det(A)~=0)
        error('vertices are not planar!');
    end
end

%   rotating the plane with all points into the x-y plane and deleting the
%   z-value
nXY=[0 0 1];
nVert=cross(ref1,ref2)./norm(cross(ref1,ref2));
angle=OFSubroutineVectorToSp(nVert);
angle=pi/2+angle(2);
rotAx=cross(nVert,nXY);
if norm(rotAx)~=0
    vertR=OFSubroutineRotate(polygon.vert,rotAx,angle);
    vertR(:,3)=[];
else
    vertR=polygon.vert(:,1:2);
end

%now delaunay triangulation
polygon.tri=delaunay(vertR(:,1),vertR(:,2));
% The delaunay call originally had qhull option 'Qt','Qbb','Qc','Qz'.
% However, matlab 2010a manual says: "Qhull-specific options are no longer 
% required and are currently ignored." 2011b issues a warning here. Therefore 
% now without qhull options...

polygon.poly={1:size(vertR,1)};

model={polygon};
end

