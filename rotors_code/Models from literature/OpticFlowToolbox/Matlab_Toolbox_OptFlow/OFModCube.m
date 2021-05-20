function [ model ] = OFModCube( label, w, h, l )
%OFMODCUBE returns a model of an cube
%
%Input:
%   label - String to label the model
%   h - height
%   w - width 
%   l - length
%
%Output:
%   a model containing the cube
%   the cube forms a single object constructed from rectangles
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


cube = struct('vert','tri','poly','label');

cube.vert=[-w/2 -l/2 -h/2; -w/2 l/2 -h/2; w/2 l/2 -h/2; w/2 -l/2 -h/2;
            -w/2 -l/2 h/2; -w/2 l/2 h/2; w/2 l/2 h/2; w/2 -l/2 h/2];
        
cube.tri=[1 2 3; 1 3 4; 1 2 6; 1 6 5; 2 3 7; 2 7 6; 3 4 8; 3 8 7;
                    4 1 5; 4 5 8; 5 6 7; 5 7 8];
                
cube.poly={[1 2 3 4],[1 2 6 5],[2 3 7 6],[3 4 8 7],[4 1 5 8],[5 6 7 8]};
cube.label=label;
model={cube};
end

