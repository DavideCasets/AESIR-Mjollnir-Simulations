function [Qdot_w_t, h_liq, h_gas] = heat_flux_wall_tank(comp)
    %This function return the flucomp.x_vap going from the wall to the tank

    %Principal inputs:
    DeltaT = comp.T_tank_wall - comp.T_tank;
    
    %Geometric parameters:
    D_int = comp.D_int_tank;
    Length = comp.L_tank;
    A = pi * D_int * Length;
    g = comp.g;  %m/s2
    
    %thermodynamic parameters liquid:
    cp_liq = py.CoolProp.CoolProp.PropsSI('C', 'P', comp.P_N2O, 'T|liquid', comp.T_tank, 'NitrousOxide'); %calorific capacity of N2O
    rho_liq = py.CoolProp.CoolProp.PropsSI('D', 'P', comp.P_N2O, 'T|liquid', comp.T_tank, 'NitrousOxide'); %density of rho
    Beta_liq = py.CoolProp.CoolProp.PropsSI('isobaric_expansion_coefficient', 'P', comp.P_N2O, 'T|liquid', comp.T_tank, 'NitrousOxide'); %isobaric coefficient of N2O
    kappa_liq = 100.1e-3; %thermal capacity of N2O  : Wm-1K-1
    L = D_int; %characteristic lenght : m
    visc_liq = 2.29e-5; %viscosity of N2O
    
    %thermodynamic parameters gaz:
    cp_gaz = py.CoolProp.CoolProp.PropsSI('C', 'P', comp.P_N2O, 'T|gas', comp.T_tank, 'NitrousOxide'); %calorific capacity of N2O
    rho_gaz = py.CoolProp.CoolProp.PropsSI('D', 'P', comp.P_N2O, 'T|gas', comp.T_tank, 'NitrousOxide'); %density of rho
    Beta_gaz = py.CoolProp.CoolProp.PropsSI('isobaric_expansion_coefficient', 'P', comp.P_N2O, 'T|gas', comp.T_tank, 'NitrousOxide'); %isobaric coefficient of N2O
    kappa_gaz = 20.6e-3; %thermal conductivity of N2O gaz : Wm-1K-1
    L = D_int; %characteristic lenght : m
    visc_gaz = 2.29e-5; %viscosity of N2O
    
    %liquid phase:
    A_liq = A * (1 - comp.x_vap); %area in contact with liquid phase
    c = 0.021; %constant parameters given in Zimmerman;
    n = 2/5; %constant parameters given in Zimmerman;
    Ra = cp_liq * rho_liq^2 * g * Beta_liq * abs(DeltaT) * L^3 / (visc_liq * kappa_liq); %Rayleigh number
    Nu = c * Ra^n; %Nusset number for liquid phase
    h_liq = Nu * kappa_liq / L; %Convection capacity for liquid phase
    Q_dot_in_liquid = h_liq * A * DeltaT; %Final heat flucomp.x_vap in
    
    %gaz phase:
    A_gaz = A * comp.x_vap; %area in contact with gaz phase
    c = 0.021; %constant parameters given in Zimmerman;
    n = 2/5; %constant parameters given in Zimmerman;
    Ra = cp_gaz * rho_gaz^2 * g * Beta_gaz * abs(DeltaT) * L^3 / (visc_gaz * kappa_gaz); %Rayleigh number
    Nu = c * Ra^n; %Nusset number for liquid phase
    h_gas = Nu * kappa_gaz / L; %Convection capacity for liquid phase
    Q_dot_in_gaz = h_gas * A * DeltaT; %Final heat flucomp.x_vap in
    
    Qdot_w_t = Q_dot_in_gaz + Q_dot_in_liquid;
end