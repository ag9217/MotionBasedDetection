function [dataGreenChannel,nFrames,groundTruth] = createMotion(background,scenario,speed)
%generate background and motion scenario
switch background
    case 'blank'
        BG=imread('blank.jpg');
    case 'road'
        BG=imread('road.jpg');
    case 'noise'
        BG=imread('noise.jpg');   
    case 'city'
        BG=imread('city.jpg'); 
    case 'largeroad'
        BG=imread('largeroad.jpg');
end
BG=imresize(BG, [240 320]);
%[m,n]=size(BG);
switch scenario
    case 'horizontal'
        x_coord=[10:(speed^2)*0.05:300];
        x2_coord=[10:(speed^2)*0.02:300];
        y_coord=150*ones(1,length(x_coord));
        y2_coord=90*ones(1,length(x2_coord));
%     case 'horizontal'
%         x_coord=[10:(300-10)/(200):300];
%         y_coord=150*ones(1,length(x_coord));
    case 'vertical'
        y_coord=[20:(200-20)/200:200]; 
        x_coord=200*ones(1,length(y_coord));
    case 'sinosoid'
        x_coord=[20:(300-20)/200:300];
        y_coord=sin(x_coord/50)*50+100;
    case 'lock'
        x_coord=160*ones(1,200);
        y_coord=200*ones(1,length(x_coord));
end
%Multi motion
% x_2=160*ones(1,200);
% y_2=80*ones(1,length(x_coord));
%Generate green channel picture with moving point
for IN=1:length(x_coord)
     Frame = insertShape(BG,'FilledRectangle',[x_coord(IN) y_coord(IN) 20, 20],'Color', 'red','Opacity',1);
     Frame = insertShape(Frame,'FilledRectangle',[x2_coord(IN) y2_coord(IN) 20, 20],'Color', 'red','Opacity',1);
%    motionBG = BG(:, IN*3:(IN*3+320), :);
%    Frame = insertShape(motionBG,'FilledCircle',[x_coord(IN) y_coord(IN) 10],'Color', 'red','Opacity',1);
%      Frame = insertShape(Frame,'FilledCircle',[x_2(IN) y_2(IN) 10],'Color', 'red','Opacity',1);
    dataGreenChannel(:,:,IN)=Frame(:,:,2);
end  
nFrames=length(x_coord);
groundTruth(1,:)=x_coord;
groundTruth(2,:)=y_coord;