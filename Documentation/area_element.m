set(groot, 'defaultAxesTickLabelInterpreter','latex'); set(groot, 'defaultLegendInterpreter','latex');
addpath('../../animation_toolbox/');addpath('../../colorthemes/');addpath('../STLRead/');
fig = figure;
ax = axes(fig); dark_mode2; plot3(ax, 0,0,0); ax.DataAspectRatio = [1,1,1]; 
annotation(fig, "rectangle","EdgeColor", [1,1,1]*0.13, "Position", [0.35 0.1 0.3 0.8]);
ax.XLim = [-50,50];ax.YLim = [-10,10];ax.ZLim = [-50,50]; axis off
light(ax);
mesh = stlread("../Assets/AM_00 Mjollnir Full CAD v79 low_poly 0.03.stl");
mesh.vertices = mesh.vertices - [0 0 (max(mesh.vertices(3,:)) + min(mesh.vertices(3,:)))*0.5] - [0 0 10];





area_mesh = mesh;
area_mesh.vertices = area_mesh.vertices.*[0 1 1];


patch(ax, mesh, ...
                              'FaceColor',       ColorMap(70,:), ...
                              'EdgeColor',       'none',        ...
                              'FaceLighting',    'gouraud',     ...
                              'AmbientStrength', 0.3, ...
                              'FaceAlpha',       0.1);
hold on

patch(ax, area_mesh, ...
                              'FaceColor',       [1,0.5,0], ...
                              'EdgeColor',       'none',        ...
                              'FaceLighting',    'gouraud',     ...
                              'AmbientStrength', 1, ...
                              'FaceAlpha',       0.2);

text(ax, 10,0,30,"$\partial A$", "Color", [1,0.5,0], "Interpreter","latex")