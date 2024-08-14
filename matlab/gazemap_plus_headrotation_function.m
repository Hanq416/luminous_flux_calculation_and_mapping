function [gazemap] = gazemap_plus_headrotation_function(gazefile,origin_time)
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
    %x2(i) = (longitude + head_rotation(i,2))*r;% head rotation is a radian
    x2(i) = longitude*r;
    %y2(i) = (latitude + head_rotation(i,1))*r;
    y2(i) = latitude*r;
end
gazemap=[x2 y2];
end

