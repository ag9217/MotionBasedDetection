function [ ] = OFDrawPoE_PoC( PoE, PoC )
%OFDRAWPOC_POE draws the PoE / PoC into the exsisting cylindric Optic Flow
%   drawn by OFDrwaCylPlot
%Input:
%   PoE - nx2 matrix which contains the PoE's computated by OFCalcPoE_PoC
%   PoC - nx2 matrix which contains the PoC's computated by OFCalcPoE_PoC
%
%Output:
%   plots the PoC as green circles and the PoE as red x into the last plot
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

  
  hold on
  if(~isempty(PoE))
    PoE(:,1)=2*pi-PoE(:,1);
    % shift the flow field to make [0 0] the middle
    PoE(:,1)=PoE(:,1)+pi;
    for k=1:size(PoE,1)
        if(PoE(k,1)>2*pi)
            PoE(k,1)=PoE(k,1)-2*pi;
        end
        plot(PoE(k,1),PoE(k,2),'rx');
    end
  end
   
  if(~isempty(PoC))
    PoC(:,1)=2*pi-PoC(:,1);
    % shift the flow field to make [0 0] the middle
    PoC(:,1)=PoC(:,1)+pi;
    for k=1:size(PoC,1)
        if(PoC(k,1)>2*pi)
            PoC(k,1)=PoC(k,1)-2*pi;
        end
        plot(PoC(k,1),PoC(k,2),'go');
    end     
  end
    hold off
    

end

