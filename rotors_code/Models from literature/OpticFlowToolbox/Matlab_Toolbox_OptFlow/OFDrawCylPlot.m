function [ ] = OFDrawCylPlot( sp, hof, vof, t, varargin)
%OFDRAWCYLPLOT draws a cylindric (planar) Flow field from hof and vof
% at position t
%
%Input:
% sp - Sx2 matrix with sample points
% hof, vof - Horizontal and vertical components of the OpticFlow
%   to receive hof and vof: OFCalcOpticFlow
% t - trajectory position of the Optoc Flow
% OPTIONAL (need to be in this order):
%   scale - scales the flow vectors and is analog to scale in function quiver:
%       1= no scale, 0.5= half length, 2= double length (default=1)
%   overlap - bool that determines if the borderoverlapp (2pi-0) is
%       split into two seperate flow vectors x->2pi; 0->y (default=true)
%
%Output:
% Plots a cylindric flow field
% Flow near zenith seem big because of projection from sphere to cylinder
% the FlowField has been translated, so that:
% the SamplePoint [0 0] is in the middle of the "rectangle"
% from there to the left edge [pi _ ] 
% and from the right to the middle [pi _ ] til [ 2*pi _ ]
%
% see also OFCalcOpticFlow 
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


optargin=size(varargin,2);
if(optargin==1)
    scale=varargin{1};
    overlap=true;
elseif(optargin==2)
    scale=varargin{1};
    overlap=varargin{2};
else
    if(optargin>2)
        error('to many input arguments, max scale and overlap');
    end
    scale=1;
    overlap=true;
end

    if(t>size(hof,1)||t<0)
        error('chosen trajectory position t is out of range');
    end
    xOverl=[];
    yOverl=[];
    uOverl=[];
    vOverl=[];

    %swap flow field around because of mathematicaly [pi/2 0] is [0 1 0]
    % (left-rotation)
    %but intuitiv [pi/2 0] would rotate right to [0 -1 0] (right-rotation)
    x=2*pi-sp(:,1)';
    hof(t,:)=2*pi-hof(t,:);

    y=sp(:,2)';
    
    % shift the flow field to make [0 0] the middle
    x=x+pi;
    hof(t,:)=hof(t,:)+pi;
    for k=1:size(hof,2)
        if(x(k)>2*pi)
            x(k)=x(k)-2*pi;
        end
        if(hof(t,k)>2*pi)
            hof(t,k)=hof(t,k)-2*pi;
        end
    end    
    
    %compute the flowVector
    n=1;

    for k=1:length(x)
        u(k)=-x(k)+hof(t,k);
        v(k)=-y(k)+vof(t,k);
        %correct the vectors that exceed the 360° field of view
        
        %if horizontal overlap would be shorter than vertical overlap
%        if((2*pi-abs(u(i))<pi/2-y(i)+pi/2-vof(t,i))&&(2*pi-abs(u(i))<pi/2+y(i)+pi/2+vof(t,i)))||abs(u(i))>pi
        if(overlap==true)
            % left to right overlap
            if(u(k)>pi)
                % gradient of the new Flow-vectors
                m=(vof(t,k)-y(k))/(2*pi-u(k));
                
                xOverl(n)=2*pi;
                uOverl(n)=-xOverl(n)+hof(t,k);
                
                yOverl(n)=vof(t,k)+m*uOverl(n);
                vOverl(n)=-yOverl(n)+vof(t,k);
                
                n=n+1;
                u(k)=-x(k);
                v(k)=y(k)-(y(k)-m*x(k));
            end
            %right to left overlap
            if(u(k)<-pi)
                % gradient of the new Flow-vectors
                m=(vof(t,k)-y(k))/(2*pi+u(k));
                
                xOverl(n)=0;
                uOverl(n)=hof(t,k);
                
                yOverl(n)=vof(t,k)-m*uOverl(n);
                vOverl(n)=-yOverl(n)+vof(t,k);
                
                n=n+1;
                u(k)=-x(k)+2*pi;
                v(k)=y(k)-(y(k)-m*u(k));
            end
        end
%--------------------------------------------------------------------            
% a desperate try to control the Optic Flow near pole's... probably error in reasoning           
%         else %vertical overlap
%             % over the top [0 pi/2]
%             if(pi/2-y(i)+pi/2-vof(t,i)<abs(u(i)))
%                 x(i)
%                 y(i)
%                 u(i)
%                 hof(t,i)
%                 dif=u(i);
%                 % dif is positive -> left to right
%                 u(i)=sign(dif)*(pi/2-y(i))/tan(abs(dif)/2);
%                 v(i)=-y(i)+pi/2;
%                 xOverl(j)=hof(t,i)-sign(dif)*((pi/2-vof(t,i))/tan(abs(dif)/2));
%                 yOverl(j)=pi/2;
%                 uOverl(j)=sign(dif)*(-xOverl(j)+hof(t,i));
%                 vOverl(j)=-pi/2+vof(t,i);                  
%                 j=j+1; 
%             end
%             %over the bottom [0 -pi/2]
%             if(pi/2+y(i)+pi/2+vof(t,i)<abs(u(i)))
%                 dif=u(i);
%                 % dif is positive -> left to right
%                 u(i)=sign(dif)*(-pi/2-y(i))/tan(abs(dif)/2);
%                 v(i)=(-y(i)-pi/2);
%                 xOverl(j)=hof(t,i)-sign(dif)*((-pi/2-vof(t,i))/tan(abs(dif)/2));
%                 yOverl(j)=-pi/2;
%                 uOverl(j)=sign(dif)*(-xOverl(j)+hof(t,i));
%                 vOverl(j)=pi/2+vof(t,i);                  
%                 j=j+1;                
%             end
%         end
%------------------------------------------------------------
    end

    x=[x, xOverl];
    u=[u, uOverl];
    u=u*scale;
    y=[y, yOverl];
    v=[v, vOverl];
    v=v*scale;
    figure('Name','CylOpticFlow');
    quiver(x,y,u,v,0);

end

