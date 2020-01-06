function [ dh,dv ] = get_dh_dv( x , y )
    if (y<=1)
        dv = y;
        dh = 5-x;
    elseif (y<=2)
        dh = 6-x;
        if (x>=5)
            dv = y-1;
        else
            dv = y;
        end
    elseif (y<=3)
        dh = 7-x;
        if (x<=5)
            dv = y;
        elseif (x<=6)
            dv = y-1;
        elseif (x<=7)
            dv = y-2;
        end
    else
        dh=11-x;
        if (x<=5)
            dv = y;
        elseif (x<=6)
            dv = y-1;
        elseif (x<=7)
            dv = y-2;
        else
            dv = y-3;
        end
    end
    
    
    if (dh>=1)
        dh=1;
    end
    if (dv >= 1)
        dv = 1;
    end
end

