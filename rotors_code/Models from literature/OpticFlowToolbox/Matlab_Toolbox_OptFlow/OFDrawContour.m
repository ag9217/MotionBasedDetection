function [ peaks, vel ] = OFDrawContour( sp, hvel, vvel ,t ,percent)
%OFDRAWCONTOUR draws the contour of the velocity of the optic flow into an
%exsisting plot and returns the x-percent of the Optic Flow, where
%velocity is storngest in a binary matrix with dim of hvel
% Input:
%   sp - Sx2 matrix azimuth(0 - 2*pi), zenith(pi/2 - -pi/2
%       baisicly an spherical coordinate system but with GEOGRAPHICAL
%       LATITUDE (elevation / altitude)
%       [pi/2 0]= left, [3*pi/2 0]= right, [0 pi/2]= top, [0 -pi/2]= bottom
%
%   hvel(t,s) - horizontal velocity and
%   vvel(t,s) - the vertical velocy of the optic flow
%
%   t - the trajectory position which schold be ploted 
%
%   percent - a value which determines how much percent of the matrix
%       should be interpreted as maximum. sould be between 0 and 1
%
% Output:
%   peaks - a binary matrix of size of hvel / vvel /sp with the highest
%   x-percent of velocities. 1 is strong and 0 low velocity of the optic flow. 
%
%   vel - a matrix of size peaks whith the velocities of the optic flow.
%
% see also OFCalcOpticFlow, OFCalcVelocity
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


n=sqrt(size(hvel(t,:),2));
if (n~=floor(n))
    error('sp not generated with OFGenerateSp');
end
    %shift to make [0,0] middle -- see OFDrawCylPlot for reason
    sp(:,1)=sp(:,1)+pi;
    for k=1:size(sp,1)
        if(sp(k,1)>2*pi)
            sp(k,1)=sp(k,1)-2*pi;
        end
    end    
    %transform optic flow from lists to matrices
    x=reshape(sp(:,1)',n,n)';
    y=reshape(sp(:,2)',n,n)';
    
    h=reshape(hvel(t,:),n,n)';
    v=reshape(vvel(t,:),n,n)';
    z=(h.^2+v.^2).^0.5;
    
    peaks=z;
    peaks(:,:)=0;
    for i=1:n^2*percent,
        [C,rowMaxArray]=max(z);
        [maxValue,colMax]=max(C);
        rowMax=rowMaxArray(colMax);
        z(rowMax,colMax)=-z(rowMax,colMax);
        peaks(rowMax,colMax)=1;
    end
    z=abs(z);
    vel=z;
    
    %---plot the contours - coment form here to last "end" to disable 
    %swap sides -- see OFDrawCylPlot for reason
    for k=1:floor(n/2),
        tmp=z(:,k);
        z(:,k)=z(:,n-k+1);
        z(:,n-k+1)=tmp;
    end   
    
    hold on
    contour(x,y,z);
    hold off

end

