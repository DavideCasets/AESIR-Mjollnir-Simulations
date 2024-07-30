function P_ex = exhaust_pressure(comp)
% Compute the exhaust pressure (see Sutton, 2017, p. 49).


gamma = comp.gamma_combustion_products;

if comp.P_cc == comp.P_ext
    P_ex = comp.P_ext;
else
    P_ex = comp.P_cc * (1 + (gamma - 1) * comp.M_ex^2 / 2)^(gamma / (1 - gamma));
end
end
