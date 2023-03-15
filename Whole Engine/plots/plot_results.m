%% Plots combustion, flight, and thrust plots.

disp("---------------------------------")
disp("Plotting...") 
disp("---------------------------------")
disp(" ")

close all
combustion_plot();
thrust_plot();
flight_plot();

% sensor_plot;

% figure(4)
% Isp = Tr./(opts.g.*mf_throat);
% plot(OF, Isp)
% xlabel("OF")
% ylabel("Isp (s)")
