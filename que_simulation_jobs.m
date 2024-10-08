%% This file is the main user interface.
%{
    Some notes on hyperparameter tuning:
    - Set the external temperature based on conditions during testing/launch.
    - To tune the tank pressure:
        - A higher T_tank_init tends to move the initial tank pressure up.
        - A higher Cd tends to result in a steeper slope.
    - To tune the combustion chamber pressure:
        - A higher Cd tends to move the initial combustion chamber pressure up.
        - A higher dr_thdt tends to result in a steeper slope.
    - To tune the fuel regression rate.
        - Tweak a and n.
        - This data has not been available yet, so beware that these parameters are not tuned.
%}

clc; clear; setup;



disp("Creating new jobs...")
base_simulation_job = struct();

%% User settings.
base_simulation_job.quick                  = false;                                    % True if quick simulation should be done. Less accurate, but useful for tuning.

directory = "Data/test/sims/";
if ~isfolder(directory); mkdir(directory); end

base_simulation_job.name                   = directory + "sim.mat";
base_simulation_job.overwrite              = true;
base_simulation_job.save                   = true;




base_simulation_job.mjolnir                = initiate_mjolnir;


base_simulation_job.t_max                  = 80;                                      % Final time.


try 
load("simulation_jobs.mat", "simulation_jobs");
job_index   = numel(simulation_jobs);
catch
simulation_jobs = {}; 
job_index   = 1;
end



for I_gain = 10.^(1:1:7)
    for D_gain = 10.^(1:1:7)
        job = base_simulation_job;
        job.mjolnir.guidance.I_gain = I_gain;
        job.mjolnir.guidance.D_gain = D_gain;

        
        if    job.overwrite; job.name = filename_availability(job.name, job_index);save(job.name, "job");
        else;                job.name = strrep(job.name, ".mat", "("+string(job_index)+").mat");
        end    

        
        simulation_jobs{job_index} =  job;
        job_index = job_index+1
    end
end

save("simulation_jobs.mat", "simulation_jobs");

disp("Done.")
