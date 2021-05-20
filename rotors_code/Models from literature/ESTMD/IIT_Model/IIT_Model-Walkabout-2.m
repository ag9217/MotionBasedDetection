clc
clear all
%  Bagheri Z.B., Wiederman S.D., Cazzolato B.S., Grainger S., O'Carroll
%  D.C. (2017) "Performance of an Insect-Inspired Target Tracker in Natural Conditions"
%  
%
%  This MATLAB code implements an insect-inspired target tracking (IIT) model. 

%  It is free for research use. If you find it useful, please acknowledge the paper
%  above with a reference.

%  This function takes care of setting up parameters, loading video
%  information and computing precisions.

%%%%%%%%%%% path to the videos %%%%%%%%%%%%
%choose background and motion path
%Background: road, blank, noise
%Motion Path: horizontal, vertical, sinosoid
% [dataGreenChannel,nFrames,groundTruth]=bgMotion('blank','horizontal');
% [dataGreenChannel,nFrames,groundTruth]=bgMotion;
[dataGreenChannel,nFrames,groundTruth]=createMotion('blank','horizontal', 10);
%%%%%%%%%%% Path to the code %%%%%%%%%%%%%%%
codeDirectory=['D:\OneDrive - Imperial College London\IRP\AutoCar\IIT_Model'];
cd(codeDirectory)

%%%%%%%%%%% Set the Parameters %%%%%%%%%%%%

%Center of the target in the first frame
% X_C=(groundTruth(1,1)+groundTruth(1,3)/2);   
% Y_C=groundTruth(1,2)+groundTruth(1,4)/2;  
X_C=0;
Y_C=0;
%Image size
image_size_m = size(dataGreenChannel,1) ;                         %number of rows
image_size_n = size(dataGreenChannel,2);                         %number of columns
% Prompt1='Please enter the horizontal field of view (degrees): ';
% degrees_in_image =input(Prompt1); % Facilitation time constant
% if isempty(degrees_in_image )
%     degrees_in_image = 50;                    %field of view horizontally
% end
degrees_in_image = 60; 
pixels_per_degree = image_size_n/degrees_in_image;                          %pixels_per_degree = #horiz. pixels in output / horizontal degrees (97.84)
pixel2PR = ceil(pixels_per_degree);                                         %ratio of pixels to photoreceptors in the bio-mimetic model (1 deg spatial sampling...                                                                
sigma_deg = 1.4/2.35; 
sigma_pixel = sigma_deg*pixels_per_degree;                                  %sigma = (sigma in degrees (0.59))*pixels_per_degree
kernel_size = 2*(ceil(sigma_pixel));
ParameterResize=ceil(image_size_m/pixel2PR);
K1=1:pixel2PR:image_size_m;
K2=1:pixel2PR:image_size_n;
YDim=length(K1);
XDim=length(K2);
Facilitation_Mode='off';

%Initial target location in the subsampled image
% initialCol=ceil(X_C/pixel2PR);
% initialRow=ceil(Y_C/pixel2PR);
initialCol=0;
initialRow=0;
%Facilitation parameters
Facilitation_sigma=5/2.35482;
Ts = 0.1; %Sampling time
% Prompt='Please enter the w parameter in Equation 10 to set the facilitation time constant: ';
% wb =input(Prompt); % Facilitation time constant
% if isempty(wb)
%     wb=0.05;
% end
wb=0.05;   
FacilitationGain =25; %root of facilitation kernel gain
RC_wb = 5; 
parameter.RC_fac_wb = 1;
Threshold = 0.01;
Facilitation_Matrix=ones(YDim, XDim);
TargetLocationRow=zeros(nFrames,1);
TargetLocationCol=zeros(nFrames,1);
framePTime=zeros(nFrames,1);
blurPTime=zeros(nFrames,1);
Delay=1; % allowing the facilitation to build up in the target region for 200 ms prior to the start of the experiment. 
%%
colData=[];
rowData=[];
region=zeros(1,4);
HoriArray = [];
VerArray = [];
for i=1:nFrames+Delay
   if i>=2
       test=1;
       start=1;
   else
       test=0;
       start=0;
   end  
   if i>Delay
        Input=dataGreenChannel(:,:,i-Delay);
        Input=double(Input);
        
   else
       Input=ones(image_size_m,image_size_n);
   end
   
   tStart = tic;
   opticOut=OpticBlur(Input, pixels_per_degree);
   tBlur = toc(tStart);
   tic;
   SubSampledGreen=Subsample(opticOut, pixel2PR);%Resize picture to eye size
   
   %SubSampledGreen=Subsample(Input, pixel2PR);
   PR_Output=PhotoReceptor(SubSampledGreen, XDim, YDim);
   
   
   LMC_Output=LMC(PR_Output, XDim,YDim);
   RTC_Output=RTC(LMC_Output, Ts);
   %RTC_Output=motionRTC(LMC_Output, Ts);
   %RTC_Output=regionFocus(RTC_Output,region);
   ESTMD_OUT=ESTMD(RTC_Output, Facilitation_Matrix, Facilitation_Mode, start, Threshold); 
   [Direction_Horizontal,Direction_Vertical]=Direction(ESTMD_OUT,  RC_wb, Ts,XDim, YDim);
%    HoriArray = [HoriArray, Direction_Horizontal];
%    VerArray = [VerArray, Direction_Vertical];
%    Direction_Horizontal = mean(HoriArray);
%    Direction_Vertical = mean(VerArray);
   [ col_index, row_index] = Target_Location(ESTMD_OUT, YDim);
   [default, col_index2,row_index2] = Velocity_Vector(test, col_index, row_index,Direction_Horizontal,Direction_Vertical, XDim);
   if i<=Delay
       default=1;
   end
       
   if i<Delay+1
       col_index2=initialCol;
       row_index2=initialRow;
   end
   Grid=FacilitationGrid(col_index2,row_index2, ESTMD_OUT, Facilitation_sigma, FacilitationGain);
   Facilitation_Matrix=FacilitationMatrix(Grid, col_index2, default, Ts, wb);
   tFrame=toc;
   [rs1,~]=size(Grid);
   [rs2,~]=size(Input);
   resizeVal=rs2/rs1;
   %[col_index, row_index] = delayAdaptation(col_index, row_index, Direction_Horizontal,Direction_Vertical);
   
   if i>Delay
       TargetLocationRow(i-Delay)=row_index;
       TargetLocationCol(i-Delay)=col_index;
       FM=insertShape(dataGreenChannel(:,:,i-Delay),'FilledCircle',[col_index*resizeVal row_index*resizeVal 5],'Color', 'red','Opacity',1);
       FM=imresize(FM, [480 640]);
       EO=imresize(ESTMD_OUT, [240 320]);%Magnified for 100 times for clearer visualization
       LM=imresize(LMC_Output, [1920 1080]);
       imshow(FM)
       colData=[colData, col_index*resizeVal+5];
       rowData=[rowData, row_index*resizeVal];
   end
        
   
end
% [Dist]=getError(groundTruth',colData',rowData');
%plot(Dist(40:end))
% title('Positional Error With and Without Tracking')
% xlabel('Frame')
% ylabel('Positional Error')
%Generate figure
% plot(Dist)
% title('Accuracy at Different omega in doubled moving speed - noise')
% xlabel('Frames') 
% ylabel('Distance to Object Boundary') 
% legend('0.001','0.05','1','10','100')

% title('Accuracy using Different Kernel - Radius=20')
% xlabel('Frames')
% ylabel('Distance to Object Boundary')
% legend('K1','K2','K3')
% hold on
clear functions

   
