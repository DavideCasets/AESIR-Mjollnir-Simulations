function rocket = equations_of_motion(rocket)
% computing the motion of the rocket.

rocket.attitude = orthonormalize(rocket.attitude);

% Forces & moments

force_sum  = rocket.attitude* cellsum(cellfun(@(force)  rocket.forces .(force ).vec , ...
                                              fieldnames(rocket.forces),  "UniformOutput",false));
moment_sum = rocket.attitude*(cellsum(cellfun(@(moment) rocket.moments.(moment).vec , ...
                                              fieldnames(rocket.moments), "UniformOutput",false)) + ...
                              cellsum(cellfun(@(force)  cross(rocket.forces.(force).pos - rocket.rigid_body.center_of_mass, rocket.forces.(force).vec),   ...
                                              fieldnames(rocket.forces),  "UniformOutput",false)));



% Stepping velocity


rocket.derivative("position") = rocket.velocity;
rocket.derivative("velocity") = force_sum/rocket.mass;


% Stepping angular shit
rocket.rotation_rate = (rocket.attitude*rocket.rigid_body.moment_of_inertia*(rocket.attitude'))\rocket.angular_momentum; 

rotation_rate_tensor = [  0                       -rocket.rotation_rate(3)        rocket.rotation_rate(2);
                          rocket.rotation_rate(3)  0                             -rocket.rotation_rate(1);
                         -rocket.rotation_rate(2)  rocket.rotation_rate(1)        0               ];

attitude_derivative = rotation_rate_tensor*rocket.attitude;


rocket.derivative("angular_momentum")   = moment_sum;
rocket.derivative("attitude")           = attitude_derivative;

end