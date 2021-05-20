function [ model ] = OFModRectangle( label, w, h )
%OFMODRECTANGLE returns a rectangle
%
%Input:
%   label - String to label the model
%   w - width 
%   h - height
%
%Output:
%   a model containing the rectangle
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


rect = struct('vert','tri','poly','label');
rect.vert=[-w/2 -h/2 0; w/2 -h/2 0; w/2 h/2 0; -w/2 h/2 0];
rect.tri=[1 2 3;1 3 4];
rect.poly={[1 2 3 4]};
rect.label=label;
model={rect};

end

