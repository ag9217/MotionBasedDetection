function [ ] = OFDrawMesh( mod, show_tri, flags )
%OFDRAWMESH draws the patch defined by the given model
%
%Input:
%   mod - is an model of object structs
%   show_tri - boolean which determnes if the model is painted
%       with triangles or polygons.
%       if show_tri is true, the triangles instead of the polygons are drawn
%   flags - modifiers for the drawing (optional)
%           '-notransp' do not use transparencies
%
%Output:
% the 3d plot of the model
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Copyright (C) 2009-2014 J.P. Lindemann, R. Kern C. Strub
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



for k=1:length(mod),
    V=mod{k}.vert;
    tcolor = k/length(mod);
    
    % evaluate optional flags if given
    if exist ('flags', 'var') && strcmpi (flags, '-notransp')
        facealpha={};
    else
        facealpha={'FaceAlpha', 'flat'};
    end
    
    % the EventHorizon model is the one surrounding the "world", a boundary
    % in space which is painted transparent
    if  strcmpi(mod{k}.label, 'EventHorizon')
        transp=0;
    else
        transp=0.25;
        % RoK - 2011
        %        transp=0;  % if set to zero, figure is displayed accurately in AI
    end
    
    % paint triangles
    if show_tri == true
        F=mod{k}.tri; 
        patch('Faces',F,'Vertices',V,'FaceVertexCData',tcolor,...
        'FaceColor','flat', facealpha{:},'FaceVertexAlphaData',transp);
       
    % paint patches
    else P=mod{k}.poly;
        F=[];
        for m=1:length(P),
            F=P{m};
            patch('Faces',F,'Vertices',V,'FaceVertexCData',tcolor,...
            'FaceColor','flat', facealpha{:},'FaceVertexAlphaData',transp);
        end        
    end
end   
    
end

