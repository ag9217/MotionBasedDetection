function [ ] = OFModWriteInventor( mod, filename)
%OFMODWRITEINVENTOR writes the given model to an inventor file
%
%Input:
%   mod - is a model of object structs
%   filename - the name of the file to be written
%
%Output:
%   An inventor file containing the geometry of the model
%
% Known bug: For inventor the order of vertices in a polygon defines 
%            front/backface. This is not consistently handled by OFMod 
%            generator routines. The order of some coordIndices may need 
%            changes.
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


    % open the file and initialize the structure
    file=fopen(filename, 'w');
    fprintf (file, '#Inventor V1.0 ascii\n\n');
    fprintf (file, ...
        '# generated by OFModWriteInventor (matlab optic flow toolbox)\n');
    fprintf (file, 'Separator {\n\n');

    for k=1:length(mod),
        V=mod{k}.vert;
        P=mod{k}.poly;
        L=mod{k}.label;
        
        fprintf (file, ['  #' L '\n']);
        fprintf (file, '  Separator {\n');
        fprintf (file, '    Coordinate3 {\n');
        fprintf (file, '      point [\n');
        fprintf (file, '        %e %e %e,\n', V');
        fprintf (file, '      ]\n');
        fprintf (file, '    }\n');
        fprintf (file, '    IndexedFaceSet {\n');
        fprintf (file, '      coordIndex [\n');
        for p_ind=1:length(P);
            fprintf (file, '        ');
            fprintf (file, '%d, ', P{p_ind}-1);
            fprintf (file, '-1,\n');
        end
        fprintf (file, '     ]\n');
        fprintf (file, '    }\n');
        fprintf (file, '  }\n\n');
    end   
    
    % finish the file and close it.
    fprintf (file, '}\n');
    fclose (file);
end
