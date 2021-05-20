function [ spHMat, spVMat ] = OFGenerateSpMatrix( sp )
%OFGENERATESPMATRIX converts the sp list to an sp-matrix, where thetop-left
%element is located in the top left corner from the viewer
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


hsp=sp(:,1);
vsp=sp(:,2);
n=size(sp,1);
    
%find the dimensions of the sp-matrices
for i=1:n,
    if(vsp(i)~=vsp(1))
        col=i-1;
        row=n/(i-1);
        if(row~=floor(row))
            error('sp not generated with OFGenerateSp');
        end
        break;
    end
end
    
    
%transform optic flow from lists to matrices
spHMat=reshape(hsp,col,row)';
spHMat=flipdim(spHMat,2);
spVMat=reshape(vsp,col,row)';


end

