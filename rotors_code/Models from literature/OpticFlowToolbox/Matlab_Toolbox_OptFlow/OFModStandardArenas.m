function arena=OFModStandardArenas(modus)
% This function creates the standard arenas used in the Egelhaaf Lab for
% behavioural observations. The arenas are in the same dimension as the 3D
% trajectories of the flights. It returns a model of the arena for use in 
% the OpticFlow toolbox.
%
% GETS 
%       modus = is an integer variable defining which arena is created
%               1   creates Hans van Hateren's flight arena in cm
%               2   creates B. Geurten's small Eristalis arena in mm
%               3   creates a cylindrical arena used by C. Trischler &
%                   B.Geurten in mm
%
%               feel free to add your arena / setup
%
% RETURNS
%       arena = the struct used for flight arena models in the OpticFlow
%               tool box
%
% FUNCTION CALL: arena=OFModStandardArenas(modus);
%
% see also OFModPolygon, OFModJoin, OFModSphere, OFModCube, OFModCylinder
%
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Copyright (C) 2009-2014 B.Geurten, J.P. Lindemann
%		
%   This file is part of the ivtools.
%   https://opensource.cit-ec.de/projects/ivtools
%
%   This file is part of the Optic-Flow toolbox.
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


switch modus
    case {1}
        arena = OFModCube('vHateren',37,37,37);
    case {2}
        % Defining vertices
        lfd = [  0   0   0];    % Left front down in origin of the coordinate system
        rfd = [142   0   0];    % right front down
        lbd = [  0 242   0];    % left back down
        rbd = [142 242   0];    % right back down
        lfu = [-4  -3  172];    % left front up
        rfu = [146 -3  172];    % right front up
        lbu = [-4  245 172];    % left front up
        rbu = [146 245 172];    % right front up

        %building arena walls and joining model
        arena = OFModPolygon('front',lfd,rfd,rfu,lfu);
        arena = OFModJoin(arena, OFModPolygon('left',lfd,lbd,lbu,lfu));
        arena = OFModJoin(arena, OFModPolygon('back',lbd,rbd,rbu,lbu));
        arena = OFModJoin(arena, OFModPolygon('right',rfd,rbd,rbu,rfu));
        arena = OFModJoin(arena, OFModPolygon('ceil',lfu,rfu,rbu,lbu));
        arena = OFModJoin(arena, OFModPolygon('floor',lfd,rfd,rbd,lbd));
    case{3}
        arena = OFModCylinder('CT_cyl',200,700,100);
        %tranlate the arena so that the arena is only in positive
        %coordinates, as was done during the calibration for recordings
        arena = OFModTranslate(arena,200,200,350);
    otherwise
        arena = [];
        disp('The modus was invalid type help OFModStandardArenas to see valid arenas!')
end


