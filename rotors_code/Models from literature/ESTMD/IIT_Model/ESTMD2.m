function ESTMD_OUT2=ESTMD2(RTC_OUT, Threshold)
    RTC_OUT=(RTC_OUT*6);
    RTC_OUT2=RTC_OUT-Threshold;%0.1 is the threshold value
    RTC_Out_Dead= RTC_OUT2>0; %you can change the threshold value here
    RTC_Out_Dead=RTC_Out_Dead.* RTC_OUT2;
        % Soft saturation
    ESTMD_OUT2=tanh(RTC_Out_Dead);
end