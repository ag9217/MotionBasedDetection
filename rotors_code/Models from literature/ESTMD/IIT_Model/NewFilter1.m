function Out1=NewFilter1(u, tau, Ts)
     Ts=0.05;
    Out1 = (1-exp(-(Ts./tau))).*u;
end