clear all
totalResult = [];
avetime=[];
result = [];

for j = 1: 20
    
    [dataGreenChannel,nFrames,groundTruth]=sizeMotion('blank', 'horizontal', 5,j*0.05);
    %%%%%%%%%%% Path to the code %%%%%%%%%%%%%%%
    codeDirectory=['D:\OneDrive - Imperial College London\IRP\AutoCar\IIT_Model'];
    cd(codeDirectory)
    X_C=0;
    Y_C=0;
    image_size_m = size(dataGreenChannel,1);                         %number of rows
    image_size_n = size(dataGreenChannel,2);
    degrees_in_image = 60;
    pixels_per_degree = image_size_n/degrees_in_image;                          %pixels_per_degree = #horiz. pixels in output / horizontal degrees (97.84)
    pixel2PR = ceil(pixels_per_degree);    %ratio of pixels to photoreceptors in the bio-mimetic model (1 deg spatial sampling...
%     pixel2PR = 1;
    sigma_deg = 1.4/2.35;
    sigma_pixel = sigma_deg*pixels_per_degree;                                  %sigma = (sigma in degrees (0.59))*pixels_per_degree
    kernel_size = 2*(ceil(sigma_pixel));
    ParameterResize=ceil(image_size_m/pixel2PR);
    K1=1:pixel2PR:image_size_m;
    K2=1:pixel2PR:image_size_n;
    YDim=length(K1);
    XDim=length(K2);
    Facilitation_Mode='off';
    Ts1 = 0.001;
    Ts2 = 0.5;
    FacilitationGain =25; %root of facilitation kernel gain
    RC_wb = 5;
    parameter.RC_fac_wb = 1;
    Threshold = 0.01;
    Facilitation_Matrix=ones(YDim, XDim);
    TargetLocationRow=zeros(nFrames,1);
    TargetLocationCol=zeros(nFrames,1);
    framePTime=zeros(nFrames,1);
    blurPTime=zeros(nFrames,1);
    Delay=10; % allowing the facilitation to build up in the target region for 200 ms prior to the start of the experiment.
    %%
    colData=[];
    rowData=[];
    region=zeros(1,4);
    HoriArray = [];
    VerArray = [];
    strength = [];
    maxResponse = [];
    for i=1:nFrames+Delay
        if i>=1
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
%            SubSampledGreen=Subsample(opticOut, pixel2PR);%Resize picture to eye size
        SubSampledGreen=Subsample(opticOut, pixel2PR);%Without blurring
        %SubSampledGreen=Subsample(Input, pixel2PR);
        PR_Output=PhotoReceptor(SubSampledGreen, XDim, YDim);
        LMC_Output=LMC(PR_Output, XDim,YDim);
        RTC_Output=RTC(LMC_Output, Ts1);
        RTC_Output2=RTC2(LMC_Output, Ts2);
        tFrame=toc;
    end
    result = [result;max(max(RTC_Output)),max(max(RTC_Output2)),(max(max(RTC_Output2))^2/max(max(RTC_Output)))^2];
    clear RTC2
    clear PhotoReceptor
    clear dataGreenChannel
end
