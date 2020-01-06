function plotMFs(system)

figure;
plotmf(system, 'input',1);
title('Membership function of dv');

figure;
plotmf(system, 'input',2);
title('Membership function of dh');

figure;
plotmf(system, 'input',3);
title('Membership function of theta');

figure;
plotmf(system, 'output',1);
title('Membership function of Dtheta');

end