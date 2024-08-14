function [idx,gaze_direction,Kmeans,original,head] = gazepoint_capture_function2(gazefile,origin_time,cluster_num,head_rotation)
%%% this version is for the gaze mapping model considering head rotation (face normal change)
%%% equitriangular projection
%%%%% extract and convert gaze direction%%%%%
% convert camera coordinates (XYZ) into the right hand coordinate (XZY)
x=gazefile(:,1);y=gazefile(:,2);z=gazefile(:,3);
r=(x.^2+y.^2+z.^2).^0.5;X=x./r;Y=y./r;Z=z./r;% normalized XYZ coordinates
Xo=X(origin_time,:);Yo=Y(origin_time,:);Zo=Z(origin_time,:);camera_coordiante=[X Z Y];yaw=atan(-Xo/Zo);pitch=atan(-Yo/(Xo*sin(yaw)-Zo*cos(yaw)));
rotation1=[cos(yaw) -sin(yaw) 0;sin(yaw) cos(yaw) 0;0 0 1];rotation2=[1 0 0; 0 cos(pitch) -sin(pitch);0 sin(pitch) cos(pitch)];
Eye_coordinate=camera_coordiante*rotation1*rotation2;
% convert back to camera coordinate system
X=Eye_coordinate(:,1);Y=Eye_coordinate(:,3);Z=Eye_coordinate(:,2);
%%%%%%gaze cordinates%%%%
x2=zeros(size(x));y2=zeros(size(y));%%%%map the original gaze point
r=180/pi;
for i=1:length(x)
    latitude = asin(Y(i));
    if Z(i)>=0
    longitude = atan(X(i)/Z(i));
    elseif Z(i)<0, X(i)>= 0
    longitude = atan(X(i)/Z(i)) + pi;
    elseif Z(i)<0, X(i) < 0
    longitude = atan(X(i)/Z(i)) - pi;
    end
    x2(i) = (longitude + head_rotation(:,2))*r;% head rotation is a radian
    y2(i) = (latitude + head_rotation(:,1))*r;
end
xg=x2;yg=y2;gazemap=[x2 y2];
face_normal=head_rotation.*r; % latitude and longitude of face normal
% calculate the K means of gaze positions
[idx,C]=kmeans(gazemap,cluster_num);xc=C(:,1);yc=C(:,2);
theta_gaze2=zeros(size(xc));
alpha_gaze2=zeros(size(xc));
head_rotation2=zeros(size(C));
% convert K-mean coordinates into alpha and theta angle
for i=1:length(xc)
    latitude2 = yc(i)/r - head_rotation(:,1);%%convert to gaze coordinate latitude and longitude
    longitude2 = xc(i)/r - head_rotation(:,2);
    Y=sin(latitude2);
    Z=cos(latitude2)./sqrt((1+tan(longitude2).^2));
    X=Z*tan(longitude2);
    theta_gaze2(i)=acos(Z);
        if X > 0 && Y >= 0
            alpha_gaze2(i)=atan(Y/X);
        elseif X < 0
            alpha_gaze2(i)=atan(Y/X)+pi;
        elseif X > 0 && Y < 0
            alpha_gaze2(i)=atan(Y/X)+2*pi;
        elseif X==0 && Y >=0
            alpha_gaze2=0.5*pi;
        elseif X(i)==0 && Y(i)<0
            alpha_gaze2(i)=1.5*pi;
        end
    head_rotation2(i,1)= face_normal(:,1);head_rotation2(i,2)= face_normal(:,2);
    gaze_direction=[alpha_gaze2,theta_gaze2,head_rotation2];
end
    head_x=face_normal(:,2);head_y=face_normal(:,1);head=[head_y,head_x];
    Kmeans=[xc,yc];original=[xg,yg];
end

