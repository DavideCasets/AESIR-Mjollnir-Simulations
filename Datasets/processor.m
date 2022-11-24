% 2022-11-12 Ludwig Karlsson, AESIR
% Usage:
% 1. set TARGET to be the target data set
% 2. assure that column names match the csv values
% 3. specify starting time T0 in ms since boot
% 4. specify capture duration from starting time in seconds
% 5. run script, the resulting data is exported

% #### PARAMETERS ####

% target data set
%     the data set should be a Matlab imported table from a CSV-file
%     contain all Edda data in nice format.
TARGET = shortht21;
OUTPUT_NAME = "ht21.mat";

% starting time [ms]
T0_ms = 3113254;
% ignition time, has to be read from data
T_IGNITION = 3207.49;
% time duration [s]
T = 120;

% prune flag, if not 0 data will be processed
PRUNE = 1;
% pruning tolerances
PRUNE_TOLX = 5.0;
PRUNE_TOLY = 0.2; % relative

% set this to 1 to import FMV data, otherwise 0
%     FMV data is not pruned or processed since their timestamps and data
%     is perfect.
FMV_IMPORT_DATA = 1;
% Target fmv data set
%     The target should be a Nx3 double matrix containing time
%     in FMV_TARGET(:, 1), and the two load cell measurements
%     in FMV_TARGET(:, 2) and FMV_TARGET(:, 3).
%     The data can be imported from the processed txt/csv generated by
%     the converter.py script from the fmv raw .txt data.
FMV_TARGET = outtest001;
% time range must be different since the recorded time range is different
FMV_T0 = 9.5;  % starting time
FMV_T_IGNITION = 11.153;  % read from data
FMV_T = 10;    % duration


% column names
SERIES.TIME_MS = ["ms_since_boot_x", "ms_since_boot_y"];
SERIES.BLEED_VALVE = ["sindri_bleed_valve_current_ampere_x", "sindri_bleed_valve_current_ampere_y"];
SERIES.MAIN_VALVE = ["sindri_main_valve_current_ampere_x", "sindri_main_valve_current_ampere_y"];
SERIES.TANK_WEIGHT = ["sindri_oxidizer_tank_weight_kilogram_x", "sindri_oxidizer_tank_weight_kilogram_y" ];
SERIES.PTRAN_1 = ["sindri_transducer_01_pressure_bar_x", "sindri_transducer_01_pressure_bar_y"];
SERIES.PTRAN_2 = ["sindri_transducer_02_pressure_bar_x", "sindri_transducer_02_pressure_bar_y"];
SERIES.PTRAN_3 = ["sindri_transducer_03_pressure_bar_x", "sindri_transducer_03_pressure_bar_y"];
SERIES.PTRAN_4 = ["sindri_transducer_04_pressure_bar_x", "sindri_transducer_04_pressure_bar_y"];
SERIES.RTD_1 = ["sindri_rtd_01_temperature_celsius_x", "sindri_rtd_01_temperature_celsius_y"];
SERIES.RTD_2 = ["sindri_rtd_02_temperature_celsius_x", "sindri_rtd_02_temperature_celsius_y"];
SERIES.THERM_1 = ["sindri_therm_01_temperature_celsius_x", "sindri_therm_01_temperature_celsius_y"];
SERIES.THERM_2 = ["sindri_therm_02_temperature_celsius_x", "sindri_therm_02_temperature_celsius_y"];
SERIES.THERM_3 = ["sindri_therm_03_temperature_celsius_x", "sindri_therm_03_temperature_celsius_y"];
SERIES.THERM_4 = ["sindri_therm_04_temperature_celsius_x", "sindri_therm_04_temperature_celsius_y"];
SERIES.THERM_5 = ["sindri_therm_05_temperature_celsius_x", "sindri_therm_05_temperature_celsius_y"];
SERIES.THERM_6 = ["sindri_therm_06_temperature_celsius_x", "sindri_therm_06_temperature_celsius_y"];
SERIES.THERM_7 = ["sindri_therm_07_temperature_celsius_x", "sindri_therm_07_temperature_celsius_y"];
SERIES.THERM_8 = ["sindri_therm_08_temperature_celsius_x", "sindri_therm_08_temperature_celsius_y"];
SERIES.THERM_9 = ["sindri_therm_09_temperature_celsius_x", "sindri_therm_09_temperature_celsius_y"];
SERIES.THERM_10 = ["sindri_therm_10_temperature_celsius_x", "sindri_therm_10_temperature_celsius_y"];
SERIES.THERM_11 = ["sindri_therm_11_temperature_celsius_x", "sindri_therm_11_temperature_celsius_y"];
SERIES.THERM_12 = ["sindri_therm_12_temperature_celsius_x", "sindri_therm_12_temperature_celsius_y"];


% #### SCRIPT ####

% find starting time global
disp("Searching for starting time...")
TIME_MS_T0_index = time_search(TARGET.(SERIES.TIME_MS(2)), T0_ms);
disp("    done!")

% if no starting time was found
if TIME_MS_T0_index == -1
    disp("Failed to find time!")
    return;
end

% store global starting time
T0 = TARGET.(SERIES.TIME_MS(1))(TIME_MS_T0_index);

% save every paramater to the object such that we know how the data
% was processed later.
data.T0 = T0;                   % record starting time
data.T_IGNITION = T_IGNITION;
data.T = T;                     % records duration
data.OUTPUT_NAME = OUTPUT_NAME; % records name of out-file
data.PRUNE_OPTS.PRUNE = PRUNE;  % records pruning flag
data.PRUNE_OPTS.TOLX = PRUNE_TOLX;
data.PRUNE_OPTS.TOLY = PRUNE_TOLY;
data.FMV_IMPORT_DATA = FMV_IMPORT_DATA;
data.FMV_T0 = FMV_T0;
data.FMV_T_IGNITION = FMV_T_IGNITION;
data.FMV_T = FMV_T;

channels = fieldnames(SERIES);
for i = 1:length(channels)
    field = channels{i};
    if field == "TIME_MS"
        continue
    end
    
    disp("Processing " + field)
    
    start_index = time_search(TARGET.(SERIES.(field)(1)), T0);
    stop_index = time_search(TARGET.(SERIES.(field)(1)), T0 + T) + 1;
    
    xvals = TARGET.(SERIES.(field)(1))(start_index:stop_index);
    yvals = TARGET.(SERIES.(field)(2))(start_index:stop_index);
    
    if PRUNE
        pruned = 0;
        iterations = 0;
        new_prunes = [1];
        
        while ~isempty(new_prunes)
            iterations = iterations + 1;
            new_prunes = prune(xvals, yvals, PRUNE_TOLX, PRUNE_TOLY*max(yvals), iterations < 3);
            pruned = pruned + length(new_prunes);
            
            xvals(new_prunes) = [];
            yvals(new_prunes) = [];
        end
        disp("    pruned " + pruned + " values (" + iterations + " iterations)")
    end
    
    xvals = xvals - T_IGNITION;
    % adds the raw data array to the data struct
    data.(field + "_DATA") = [xvals'; yvals']';
    
    % adds an associated (linear for now) interpolant
    data.(field + "_I") = griddedInterpolant(xvals, yvals);
    disp("    done!")
end

if FMV_IMPORT_DATA
    disp("Processing THRUST DATA")
    
    start_index = time_search(FMV_TARGET(:, 1), FMV_T0);
    stop_index = time_search(FMV_TARGET(:, 1), FMV_T0 + FMV_T) + 1;
    xvals = FMV_TARGET(start_index:stop_index, 1);
    yvals = FMV_TARGET(start_index:stop_index, 2) ...
                + FMV_TARGET(start_index:stop_index, 3);
    xvals = xvals - FMV_T_IGNITION;
    data.("THRUST_DATA") = [xvals'; yvals']';
    data.("THRUST_I") = griddedInterpolant(xvals, yvals);
    disp("    done!")
end

disp("Saving to disk...")
save("Datasets/" + OUTPUT_NAME, "data")
disp("    done!")

% clear temps
clear TIME_MS_T0_index
clear prunes new_prunes PRUNE_TOLY PRUNE_TOLX
clear i iterations xvals yvals test_range
clear channels field start_index stop_index
clear OUTPUT_NAME

% clear utils
clear TARGET
clear SERIES PRUNE
clear FMV_TARGET
clear T T0 T0_ms T_IGNITION
clear FMV_IMPORT_DATA FMV_T FMV_T0 FMV_T_IGNITION

disp("DONE!")

% Finds the smallest index such that times(i) <= time
% and times(i + 1) >= times(i) and times(i + 2) >= times(i).
function index = time_search(times, time)
    for i = 1:(length(times) - 3)
        if times(i) > time
            % assure that the found time is not an outlier value
            test_range = times(i:i + 2);
            if test_range(1) > test_range(2) || test_range(1) > test_range(3)
                continue
            end
            
            % hit!
            index = i - 1;
            break
        end
    end
    
    clear test_range
end

% Finds all data points such that x-series goes backwards, or where the
% difference in either series is larger than the specified tolerances.
function indices = prune(xvals, yvals, TOLX, TOLY, prune_in_y)
    indices = [];
    for i = 1:(length(xvals) - 2)
        if xvals(i + 1) - xvals(i) <= 0 || xvals(i + 1) - xvals(i) > TOLX
            indices = [indices (i + 1)];
        elseif prune_in_y && abs(yvals(i + 1) - yvals(i)) > TOLY
            indices = [indices (i + 1)];
        end
    end
end
