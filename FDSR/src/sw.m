function [res] = sw(x)
x = abs(x);
if x>=0 && x<=1
    res = 1.5*x^3 - 2.5*x^2 + 1;
elseif x>1 && x<=2
    res = -0.5*x^3 + 2.5*x^2 -4*x + 2;
else
    res = 0;
end
end