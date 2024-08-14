function [alpha,theta] = gazedg2ta(longitude,latitude)% transform gaze angle in degree to theta and alpha
latitude2  = latitude*pi/180;%%convert to gaze coordinate latitude and longitude
longitude2 = longitude*pi/180;
alpha      = zeros(size(longitude));
theta      = zeros(size(longitude));
for i = 1:length(longitude)
Y  = sin(latitude2(i));
Z  = cos(latitude2(i))/sqrt((1+tan(longitude2(i))^2));
X  = Z*tan(longitude2(i));
theta(i) = acos(Z);
if X > 0 && Y >0
    alpha(i) = atan(Y/X);
elseif X < 0 && Y >0
    alpha(i) = atan(Y/X)+pi;
elseif X < 0 && Y <0
    alpha(i) = atan(Y/X)+pi;
elseif X > 0 && Y < 0
    alpha(i) = atan(Y/X)+2*pi;
elseif X == 0 && Y >0
    alpha(i) = 0.5*pi;
elseif X == 0 && Y<0
    alpha(i) = 1.5*pi;
elseif X == 0 && Y == 0
    alpha(i) = 0;
elseif X > 0 && Y == 0
    alpha(i) = 0;
elseif X < 0 && Y == 0
    alpha(i) = pi;
end
end
end

