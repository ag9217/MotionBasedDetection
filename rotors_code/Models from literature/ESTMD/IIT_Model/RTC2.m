function RTC_Output2=RTC2(LMC_Output, Ts)

    %Seperating ON and OFF channel
    ON_Channel=LMC_Output>0;
    ON_Channel=ON_Channel.*LMC_Output;

    OFF_Channel=LMC_Output<0;
    OFF_Channel=-(OFF_Channel.*LMC_Output);
%     OFF_Channel = -OFF_Channel;

    %Apply the fast depolarization slow repolarization
    persistent On_Delayed_Channel2
    persistent Off_Delayed_Channel2

    if isempty(On_Delayed_Channel2)
        On_Delayed_Channel2=zeros(size(ON_Channel));
    end

    if isempty(Off_Delayed_Channel2)
        Off_Delayed_Channel2=zeros(size(OFF_Channel));
    end

    ON_Difference=ON_Channel-On_Delayed_Channel2;
    OFF_Difference=OFF_Channel-Off_Delayed_Channel2;

    On_Delayed_Channel2=ON_Channel;
    Off_Delayed_Channel2=OFF_Channel;

    %ON Channel fast depolarization slow repolarization

    Tau1_ON=Gradient_CheckON(ON_Difference); % Color Difference
    ON_Filter1=NewFilter1(ON_Channel, Tau1_ON, Ts);
    persistent  ON_Filtered_Delayed2

    if isempty(ON_Filtered_Delayed2)
        ON_Filtered_Delayed2=zeros(size(ON_Channel));
    end

    ON_Filter2=NewFilter2(ON_Filtered_Delayed2,Tau1_ON, Ts);
    ON_Filtered=ON_Filter1+ON_Filter2;
    Subtracted_ON_Channel=ON_Channel-ON_Filtered_Delayed2;
    ON_Filtered_Delayed2=ON_Filtered;

    %OFF Channel fast depolarization slow repolarization
    Tau1_OFF=Gradient_CheckOFF(OFF_Difference);
    OFF_Filter1=NewFilter1(OFF_Channel, Tau1_OFF, Ts);
    persistent  OFF_Filtered_Delayed2

    if isempty(OFF_Filtered_Delayed2)
        OFF_Filtered_Delayed2=zeros(size(OFF_Channel));
    end

    OFF_Filter2=NewFilter2(OFF_Filtered_Delayed2,Tau1_OFF, Ts);
    OFF_Filtered=OFF_Filter1+OFF_Filter2;
    Subtracted_OFF_Channel=OFF_Channel-OFF_Filtered_Delayed2;
    OFF_Filtered_Delayed2=OFF_Filtered;

    %Another deadzone 
    ON_Channel_Dead=Subtracted_ON_Channel>0;
    ON_Channel_Dead=ON_Channel_Dead.*Subtracted_ON_Channel;

    OFF_Channel_Dead=Subtracted_OFF_Channel>0;
    OFF_Channel_Dead=OFF_Channel_Dead.*Subtracted_OFF_Channel;

    %Applying Spatial Filtering on each Channel:
    ON_Spatial_Filtered=RTC_Spatial_Filtering(ON_Channel_Dead);
    OFF_Spatial_Filtered=RTC_Spatial_Filtering(OFF_Channel_Dead);

    %Another deadzone
    ON_Spatial_Dead2=ON_Spatial_Filtered>0;
    ON_Spatial_Dead2=ON_Spatial_Dead2.*ON_Spatial_Filtered;
    
    OFF_Spatial_Dead2=OFF_Spatial_Filtered>0;
    OFF_Spatial_Dead2=OFF_Spatial_Dead2.*OFF_Spatial_Filtered;

    %Lowpass filter each channel
    [m,n]=size(ON_Spatial_Dead2);
    b=[1/(1+2*1.25/Ts), 1/(1+2*1.25/Ts)];
    a=[1, (1-2*1.25/Ts)/(1+2*1.25/Ts)];
%     b=[1/(1+0.002*1.25/Ts), 1/(1+0.002*1.25/Ts)];
%     a=[1, (1-0.002*1.25/Ts)/(1+0.002*1.25/Ts)];
    persistent ONbuffer2
    if isempty(ONbuffer2)
       ONbuffer2=zeros(m,n,length(b));
    end
    [ON_Dlayed_Output,ONbuffer2]=IIRFilter(b,a,ON_Spatial_Dead2,ONbuffer2);


    persistent OFFbuffer2
    if isempty(OFFbuffer2)
       OFFbuffer2=zeros(m,n,length(b));
    end
    [OFF_Dlayed_Output,OFFbuffer2]=IIRFilter(b,a,OFF_Spatial_Dead2,OFFbuffer2);

    %Correlation between ON and OFF Channel

    Correlate_ON_OFF=ON_Spatial_Dead2.*OFF_Dlayed_Output;
    Correlate_OFF_ON= OFF_Spatial_Dead2.*ON_Dlayed_Output;
    RTC_Output2=Correlate_ON_OFF+Correlate_OFF_ON;
end