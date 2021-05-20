function [ model ] = OFModRotate( mod, axis, angle )
%OFMODROTATE returns the model rotated by an given axis and angle
%
%Input:
%   mod - is an model of object structs
%   axis - rotation axis given as threedim vector
%   angle - given as radian
%
%Output:
%   model - the rotated mod
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


for k=1:length(mod) % for every object in the model
    for m=1:length(mod{k}.vert)
       vec=mod{k}.vert(m,:);
       vecr=OFSubroutineRotate(vec,axis,angle); 
       mod{k}.vert(m,:)=vecr;
    end
end
model=mod;

end

