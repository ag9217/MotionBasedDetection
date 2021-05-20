function RTC_Output=RTC(LMC_Output, Ts)

    %Seperating ON and OFF channel
    ON_Channel=LMC_Output>0;
    ON_Channel=ON_Channel.*LMC_Output;

    OFF_Channel=LMC_Output<0;
    OFF_Channel=-(OFF_Channel.*LMC_Output);

    %Apply the fast depolarization slow repolarization
    persistent On_Delayed_Channel
    persistent Off_Delayed_Channel

    if isempty(On_Delayed_Channel)
        On_Delayed_Channel=zeros(size(ON_Channel));
    end

    if isempty(Off_Delayed_Channel)
        Off_Delayed_Channel=zeros(size(OFF_Channel));
    end

    ON_Difference=ON_Channel-On_Delayed_Channel;
    OFF_Difference=OFF_Channel-Off_Delayed_Channel;

    On_Delayed_Channel=ON_Channel;
    Off_Delayed_Channel=OFF_Channel;

    %ON Channel fast depolarization slow repolarization

    Tau1_ON=Gradient_CheckON(ON_Difference);
    ON_Filter1=NewFilter1(ON_Channel, Tau1_ON);
    persistent  ON_Filtered_Delayed

    if isempty(ON_Filtered_Delayed)
        ON_Filtered_Delayed=zeros(size(ON_Channel));
    end

    ON_Filter2=NewFilter2(ON_Filtered_Delayed,Tau1_ON);
    ON_Filtered=ON_Filter1+ON_Filter2;
    Subtracted_ON_Channel=ON_Channel-ON_Filtered_Delayed;
    ON_Filtered_Delayed=ON_Filtered;

    %OFF Channel fast depolarization slow repolarization
    Tau1_OFF=Gradient_CheckOFF(OFF_Difference);
    OFF_Filter1=NewFilter1(OFF_Channel, Tau1_OFF);
    persistent  OFF_Filtered_Delayed

    if isempty(OFF_Filtered_Delayed)
        OFF_Filtered_Delayed=zeros(size(OFF_Channel));
    end

    OFF_Filter2=NewFilter2(OFF_Filtered_Delayed,Tau1_OFF);
    OFF_Filtered=OFF_Filter1+OFF_Filter2;
    Subtracted_OFF_Channel=OFF_Channel-OFF_Filtered_Delayed;
    OFF_Filtered_Delayed=OFF_Filtered;

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
    persistent ONbuffer
    if isempty(ONbuffer)
       ONbuffer=zeros(m,n,length(b));
    end
    [ON_Dlayed_Output,ONbuffer]=IIRFilter(b,a,ON_Spatial_Dead2,ONbuffer);


    persistent OFFbuffer
    if isempty(OFFbuffer)
       OFFbuffer=zeros(m,n,length(b));
    end
    [OFF_Dlayed_Output,OFFbuffer]=IIRFilter(b,a,OFF_Spatial_Dead2,OFFbuffer);

    %Correlation between ON and OFF Channel

    Correlate_ON_OFF=ON_Spatial_Dead2.*OFF_Dlayed_Output;
    Correlate_OFF_ON= OFF_Spatial_Dead2.*ON_Dlayed_Output;
    RTC_Output=Correlate_ON_OFF+Correlate_OFF_ON;
end