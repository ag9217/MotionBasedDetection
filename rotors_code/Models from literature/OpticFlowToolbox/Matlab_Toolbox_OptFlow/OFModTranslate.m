function [ model ] = OFModTranslate( mod, x, y, z )
%OFMODTRANSLATE returns the given model
%   moved by translation vector (x,y,z)
%
%Input:
%   mod - is an model of object structs
%   x - the translation along the x axis
%   y - the translation along the y axis
%   z - the translation along the z axis
%
%Output:
%   the translated model
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


for k=1:length(mod) % for all objects in model
    mod{k}.vert(:,1)=mod{k}.vert(:,1)+x;
    mod{k}.vert(:,2)=mod{k}.vert(:,2)+y;
    mod{k}.vert(:,3)=mod{k}.vert(:,3)+z;
end
model=mod;
end

