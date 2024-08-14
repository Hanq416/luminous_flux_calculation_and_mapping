function [alpha,theta] = gaze_coordinates_function (x,y)
 %input coordinates of gaze points
xc=x-(5184/2);yc=y-(3456/2);f=4.5*5184/22.3;
theta=2*asin(sqrt(xc^2+yc^2)/(2*f));
if xc>=0 && yc>=0
    alpha=atan(yc/xc);
    elseif xc<0 
    alpha=pi+atan(yc/xc);
    else
    alpha=2*pi+atan(yc/xc);
end
alpha=2*pi-alpha;
end

