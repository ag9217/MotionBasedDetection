function [ model ] = OFModCylinder( label, r, h, density )
%OFMODCYLINDER creates a ring and closes it whith two discs.
%
%Input:
%   label - String to label the model
%   r - the radius of the ring and the discs
%   h - the height of the ring
%   density - optional parameter density which defines the amount of
%       surfaces used.
%
%Output:
% a model containing the cylinder
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


if(nargin==3)
    d=6;
elseif(nargin==4)
    d=density;
end

%creating the needed models
modRing=OFModRing('ring',r,h,d);
modDiscTop=OFModDisc('top',r,d);
modDiscBottom=OFModDisc('bottom',r,d);

DiscBottom=modDiscBottom{1};
Ring=modRing{1};
DiscTop=modDiscTop{1};

%moving the discs to the needed height
DiscTop.vert(:,3)=DiscTop.vert(:,3)+h/2;
DiscBottom.vert(:,3)=DiscBottom.vert(:,3)-h/2;
 
%joining the discs with the ring
tempObj=OFObjJoin('temp',Ring,DiscTop);
cylinder=OFObjJoin(label,tempObj,DiscBottom);

model={cylinder};
end

