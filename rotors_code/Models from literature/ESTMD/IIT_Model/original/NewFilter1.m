function Out1=NewFilter1(u, tau)
    Ts=0.05;
    Out1 = (1-exp(-(Ts./tau))).*u;
end