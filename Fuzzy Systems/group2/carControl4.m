function carControl4(x0,y0,theta_init,u,xd,yd,system)

% Plot the membership function
plotMFs(system);

for i = 1:length(theta_init)
    
    x = x0;
    y = y0;
    theta = theta_init(i);
    
    flag_lost = 0; % flag to check if the car is outside
    route_x = []; % initialize to save later on
    route_y = [];
    
    while(flag_lost == 0)
        % Need to find the distances and then calculate the delta theta
        [dh, dv] =  get_dh_dv(x, y);
        
        delta_theta = evalfis([dv dh theta], system);
        
        % New angle and position of the car
        theta = theta + delta_theta;
        x = x + u * cosd(theta);
        y = y + u * sind(theta);
        
        % Update the position
        route_x = [route_x; x];
        route_y = [route_y; y]; 
        
        % Check if the car is out of the map, so to exit
        if (x < 0) || (x>10) || (y <0) || (y > 4)
            flag_lost = 1;
        end
        
    end
    
    figure;
    erx = xd - x;
    ery = yd - y;
    eucl_er = norm( [xd - x, yd - y] );

    % Set Obstacle Positions
    obstacles_x = [5; 5; 6; 6; 7; 7; 10];
    obstacles_y = [0; 1; 1; 2; 2; 3; 3];

    title(['\theta_0 : ', num2str(theta_init(i)), ' | Error_x: ', num2str(erx),' | Error_y : ', num2str(ery),' | Euclidean error : ', num2str(eucl_er)]);
    
    line(route_x, route_y , 'Color','blue');
    line(obstacles_x, obstacles_y, 'Color','red');
    
    % Mark the initial and desired points on the plot
    hold on;
    plot(xd, yd, '*');
    hold on;
    plot(x0, y0, '*');
    
end
end
