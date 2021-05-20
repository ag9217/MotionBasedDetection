function Out2=NewFilter2(u,tau, Ts)
    Ts = 0.05;
    Out2 = (exp(-(Ts./tau))).*u;
end