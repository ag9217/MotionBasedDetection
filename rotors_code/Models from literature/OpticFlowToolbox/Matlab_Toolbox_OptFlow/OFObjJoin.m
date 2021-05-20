function [ object ] = OFObjJoin(label, o1, o2 )
%OFOBJJOIN combines two objects o1 and o2, which is labeled with the new
%label. 
%
%Input:
%   label - a string with the name of the new object
%   o1 - object one
%   o2 - object two
%
%Output:
%   a object that contains both previous objects
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


object=struct('vert', 'tri', 'poly', 'label');
object.vert=[o1.vert;o2.vert];

object.tri=[o1.tri;o2.tri+length(o1.vert)];

for k=1:length(o2.poly),
    o2.poly{k}=o2.poly{k}+length(o1.vert);
end

object.poly={o1.poly{1:length(o1.poly)}, o2.poly{1:length(o2.poly)}};

object.label=label;

end

