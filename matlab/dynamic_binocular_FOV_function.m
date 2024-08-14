function [dynamic_FOV_left,dynamic_FOV_right] = dynamic_binocular_FOV_function(alpha_r,theta_r)
originalFOV          = load('originalFOV_angular.txt');
originalFOV_circular = load('originalFOV_Equisolid.txt');
originalFOV          = originalFOV.*pi/180;

alpha_FOV            = originalFOV(:,1);
theta_FOV            = originalFOV(:,2);%introduce FOV in radian
last_alpha_FOV       = originalFOV(1,1);
last_theta_FOV       = originalFOV(1,2);%connect the last point to the 1st point
alpha_FOV            = [alpha_FOV;last_alpha_FOV];
theta_FOV            = [theta_FOV;last_theta_FOV];
xoFOV_circular       = originalFOV_circular(:,1);
yoFOV_circular       = originalFOV_circular(:,2);%introduce FOV in equisolid-angle projection
last_xoFOV_circular  = xoFOV_circular(1:1);
last_yoFOV_circular  = yoFOV_circular(1:2);
xoFOV_circular       = [xoFOV_circular;last_xoFOV_circular];
yoFOV_circular       = [yoFOV_circular;last_yoFOV_circular];
%%%%%%% left eye %%%%%%%
pitch  = -asin(-sin(theta_r)*sin(alpha_r));
yaw    = -atan(tan(theta_r)*cos(alpha_r));
FOVmax = 107/180*pi;
x_dynamicFOV1 = zeros(size(alpha_FOV));
y_dynamicFOV1 = zeros(size(alpha_FOV));%for rotation
alpha_rr1     = zeros(size(alpha_FOV));
theta_rr1     = zeros(size(alpha_FOV));
for i = 1:length(alpha_FOV)
    X_WCS   = sin(theta_FOV(i))*cos(alpha_FOV(i));
    Y_WCS   = cos(theta_FOV(i));
    Z_WCS   = sin(theta_FOV(i))*sin(alpha_FOV(i));
    FOV_WCS = [X_WCS Y_WCS Z_WCS];
    if  xoFOV_circular(i) >= 0 && yoFOV_circular(i) >= 0 %nasal upper side (yaw angle)
        rotation_m     = [cos(yaw) -sin(yaw) 0;sin(yaw) cos(yaw) 0;0 0 1];% rotation matrix
        dynamicFOV_WCS = FOV_WCS*rotation_m;
        X_WCS_r        = dynamicFOV_WCS(:,1);
        Y_WCS_r        = dynamicFOV_WCS(:,2);
        Z_WCS_r        = dynamicFOV_WCS(:,3);
        theta_rr1(i)   = acos(Y_WCS_r);
        alpha_rr1(i)   = atan(Z_WCS_r/X_WCS_r);
        if theta_rr1(i) < FOVmax
            x_dynamicFOV1(i) = sqrt(2/(1+tan(alpha_rr1(i))^2))*sin(theta_rr1(i)/2);
            y_dynamicFOV1(i) = abs(x_dynamicFOV1(i)*tan(alpha_rr1(i)));
        else
            x_dynamicFOV1(i) = sqrt(2/(1+tan(alpha_rr1(i))^2))*sin(FOVmax/2);
            y_dynamicFOV1(i) = abs(x_dynamicFOV1(i)*tan(alpha_rr1(i)));
        end
    elseif xoFOV_circular(i) >= 0 && yoFOV_circular(i) < 0% nasal lower side (yaw and pitch angle)
        rotation_m     = [cos(yaw) -sin(yaw) 0; cos(pitch)*sin(yaw) cos(pitch)*cos(yaw) -sin(pitch); sin(pitch)*sin(yaw) sin(pitch)*cos(yaw) cos(pitch)];
        dynamicFOV_WCS = FOV_WCS*rotation_m;
        X_WCS_r        = dynamicFOV_WCS(:,1);
        Y_WCS_r        = dynamicFOV_WCS(:,2);
        Z_WCS_r        = dynamicFOV_WCS(:,3);
        theta_rr1(i)   = acos(Y_WCS_r);
        alpha_rr1(i)   = atan(Z_WCS_r/X_WCS_r);
        if theta_rr1(i) < FOVmax
            x_dynamicFOV1(i) = sqrt(2/(1+tan(alpha_rr1(i))^2))*sin(theta_rr1(i)/2);
            y_dynamicFOV1(i) = -abs(x_dynamicFOV1(i)*tan(alpha_rr1(i)));
        else
            x_dynamicFOV1(i) = sqrt(2/(1+tan(alpha_rr1(i))^2))*sin(FOVmax/2);
            y_dynamicFOV1(i) = -abs(x_dynamicFOV1(i)*tan(alpha_rr1(i)));
        end
    elseif xoFOV_circular(i) < 0 && yoFOV_circular(i) < 0% temporal lower side (pitch angle)
        rotation_m     = [1 0 0; 0 cos(pitch) -sin(pitch); 0 sin(pitch) cos(pitch)];
        dynamicFOV_WCS = FOV_WCS*rotation_m;
        X_WCS_r        = dynamicFOV_WCS(:,1);
        Y_WCS_r        = dynamicFOV_WCS(:,2);
        Z_WCS_r        = dynamicFOV_WCS(:,3);
        theta_rr1(i)   = acos(Y_WCS_r);
        alpha_rr1(i)   = atan(Z_WCS_r/X_WCS_r);
        if theta_rr1(i) < FOVmax
            x_dynamicFOV1(i) = -sqrt(2/(1+tan(alpha_rr1(i))^2))*sin(theta_rr1(i)/2);
            y_dynamicFOV1(i) = x_dynamicFOV1(i)*tan(alpha_rr1(i));
        else
            x_dynamicFOV1(i) = -sqrt(2/(1+tan(alpha_rr1(i))^2))*sin(FOVmax/2);
            y_dynamicFOV1(i) = x_dynamicFOV1(i)*tan(alpha_rr1(i));
        end
    elseif xoFOV_circular(i) < 0 && yoFOV_circular(i) >= 0 %temporal upper part
        x_dynamicFOV1(i)     = xoFOV_circular(i);
        y_dynamicFOV1(i)     = yoFOV_circular(i);
        theta_rr1(i)         = theta_FOV(i);alpha_rr1(i)=alpha_FOV(i);
    end
end
dynamic_FOV_left = [x_dynamicFOV1,y_dynamicFOV1];

%%%%%%% right eye %%%%%%%
if alpha_r >= 0 && alpha_r < pi
    alpha_r2 = pi-alpha_r;
else
    alpha_r2 = 3*pi-alpha_r;
end
theta_r2 = theta_r;
pitch2   = -asin(-sin(theta_r2)*sin(alpha_r2));
yaw2     = -atan(tan(theta_r2)*cos(alpha_r2));
x_dynamicFOV2 = zeros(size(alpha_FOV));
y_dynamicFOV2 = zeros(size(alpha_FOV));
alpha_rr2     = zeros(size(alpha_FOV));
theta_rr2     = zeros(size(alpha_FOV));
for i = 1:length(alpha_FOV)
    X_WCS   = sin(theta_FOV(i))*cos(alpha_FOV(i));
    Y_WCS   = cos(theta_FOV(i));
    Z_WCS   = sin(theta_FOV(i))*sin(alpha_FOV(i));
    FOV_WCS = [X_WCS Y_WCS Z_WCS];
    if  xoFOV_circular(i) >= 0 && yoFOV_circular(i) >= 0 %nasal upper side (yaw angle)
        rotation_m = [cos(yaw2) -sin(yaw2) 0;sin(yaw2) cos(yaw2) 0;0 0 1];% rotation matrix
        dynamicFOV_WCS = FOV_WCS*rotation_m;
        X_WCS_r = dynamicFOV_WCS(:,1);
        Y_WCS_r = dynamicFOV_WCS(:,2);
        Z_WCS_r = dynamicFOV_WCS(:,3);
        theta_rr2(i) = acos(Y_WCS_r);
        alpha_rr2(i) = atan(Z_WCS_r/X_WCS_r);
        if theta_rr2(i) < FOVmax
            x_dynamicFOV2(i) = sqrt(2/(1+tan(alpha_rr2(i))^2))*sin(theta_rr2(i)/2);
            y_dynamicFOV2(i) = abs(x_dynamicFOV2(i)*tan(alpha_rr2(i)));
        else
            x_dynamicFOV2(i) = sqrt(2/(1+tan(alpha_rr2(i))^2))*sin(FOVmax/2);
            y_dynamicFOV2(i) = abs(x_dynamicFOV2(i)*tan(alpha_rr2(i)));
        end
    elseif xoFOV_circular(i) >= 0 && yoFOV_circular(i) < 0% nasal lower side (yaw and pitch angle)
        rotation_m = [cos(yaw2) -sin(yaw2) 0; cos(pitch2)*sin(yaw2) cos(pitch2)*cos(yaw2) -sin(pitch2); sin(pitch2)*sin(yaw2) sin(pitch2)*cos(yaw2) cos(pitch2)];
        dynamicFOV_WCS = FOV_WCS*rotation_m;
        X_WCS_r = dynamicFOV_WCS(:,1);
        Y_WCS_r = dynamicFOV_WCS(:,2);
        Z_WCS_r = dynamicFOV_WCS(:,3);
        theta_rr2(i) = acos(Y_WCS_r);
        alpha_rr2(i) = atan(Z_WCS_r/X_WCS_r);
        if theta_rr2(i) < FOVmax
            x_dynamicFOV2(i) = sqrt(2/(1+tan(alpha_rr2(i))^2))*sin(theta_rr2(i)/2);
            y_dynamicFOV2(i) = -abs(x_dynamicFOV2(i)*tan(alpha_rr2(i)));
        else
            x_dynamicFOV2(i) = sqrt(2/(1+tan(alpha_rr2(i))^2))*sin(FOVmax/2);
            y_dynamicFOV2(i) =- abs(x_dynamicFOV2(i)*tan(alpha_rr2(i)));
        end
    elseif xoFOV_circular(i) < 0 && yoFOV_circular(i) < 0 % temporal lower side (pitch angle)
        rotation_m     = [1 0 0; 0 cos(pitch2) -sin(pitch2); 0 sin(pitch2) cos(pitch2)];
        dynamicFOV_WCS = FOV_WCS*rotation_m;
        X_WCS_r        = dynamicFOV_WCS(:,1);
        Y_WCS_r        = dynamicFOV_WCS(:,2);
        Z_WCS_r        = dynamicFOV_WCS(:,3);
        theta_rr2(i)   = acos(Y_WCS_r);
        alpha_rr2(i)   = atan(Z_WCS_r/X_WCS_r);
        if theta_rr2(i) < FOVmax
            x_dynamicFOV2(i) = -sqrt(2/(1+tan(alpha_rr2(i))^2))*sin(theta_rr2(i)/2);
            y_dynamicFOV2(i) = x_dynamicFOV2(i)*tan(alpha_rr2(i));
        else
            x_dynamicFOV2(i) = -sqrt(2/(1+tan(alpha_rr2(i))^2))*sin(FOVmax/2);
            y_dynamicFOV2(i) = x_dynamicFOV2(i)*tan(alpha_rr2(i));
        end
    elseif xoFOV_circular(i) < 0 && yoFOV_circular(i) >= 0 %temporal upper part
        x_dynamicFOV2(i) = xoFOV_circular(i);
        y_dynamicFOV2(i) = yoFOV_circular(i);
        theta_rr2(i)     = theta_FOV(i);
        alpha_rr2(i)     = alpha_rr2(i);
    end
end
x_dynamicFOV2     = -x_dynamicFOV2;
dynamic_FOV_right = [x_dynamicFOV2,y_dynamicFOV2];
end

