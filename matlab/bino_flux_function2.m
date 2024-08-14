function [fluxmap_left,fluxmap_right,bino_fluxmap,D_u,CV] = bino_flux_function2(I,alpha_gaze,theta_gaze,latitude_head,longitude_head,cf,projection_type)
% for multiple face normals (head orientation) version
%%%%% put on masks %%%%%%%
[dynamic_FOV_left,dynamic_FOV_right] = dynamic_binocular_FOV_function(alpha_gaze,theta_gaze);
[mask_left]   = auotomative_FOVmask_function(dynamic_FOV_left);%1=left side
[mask_right]  = auotomative_FOVmask_function(dynamic_FOV_right);%2=right side
%%%%%imaging processing%%%%%%
[tilt,aiming] = spatial_angle_trans2(alpha_gaze,theta_gaze);
 tilt         = tilt - latitude_head; 
 aiming       = aiming + longitude_head;% take face normal into consideration
if projection_type     == 1 %dual fisheye image
    pano   = imgstiching_hdr(I);IF_hdr=imequ2fish_hdr(pano,tilt,aiming+180,90);
elseif projection_type == 2 % equirectangular
    IF_hdr = imequ2fish_hdr2(I,tilt,aiming+180,0);
end
 cf_hdr    =  IF_hdr.*cf;
[r,c,L]    = ImageCoordinatesFunction(cf_hdr);[lumimap,CV]=coordinates2image(r,c,L);
[v,w]      = size(lumimap);
mask_left  = imresize(mask_left,[v w]);
mask_right = imresize(mask_right,[v w]);
L_left     = lumimap.*mask_left;
L_right    = lumimap.*mask_right;

%%%%%%flux calculation
mask_bino = mask_left + mask_right;
for i     = 1: length(mask_bino)
    for j = 1: length(mask_bino)
        if mask_bino(i,j) ~= 0
            mask_bino(i,j) = 1;
        else
            mask_bino(i,j) = 0;
        end
    end
end
L_bino = lumimap.*mask_bino;
 D_u   = pupil_area_function (L_bino,size(lumimap),projection_type);
[fluxmap_left,flux_left]   = flux_calculation_function(L_left,D_u,projection_type);
[fluxmap_right,flux_right] = flux_calculation_function(L_right,D_u,projection_type);
 bino_fluxmap              = fluxmap_left+fluxmap_right;
 flux_bino                 = flux_left+flux_right;
end

function [mask_filled] = auotomative_FOVmask_function(dynamicFOV_SingleSide)
dynamicFOV_SingleSide(size(dynamicFOV_SingleSide,1),:)   = [];
dynamicFOV_SingleSide = round(dynamicFOV_SingleSide.*1000);
%processing
dynamicFOV_SingleSide([69:91,182:191,272:294,341:361],:) = [];
r    = 1414; %diameter of 180 degree
dynamicFOV_SingleSide = dynamicFOV_SingleSide + r;
Iraw = single(zeros([r*2,r*2]));
x    = dynamicFOV_SingleSide(:,1); 
y    = dynamicFOV_SingleSide(:,2);
mask_filled = roipoly(Iraw,x,y);
mask_filled = flip(mask_filled);
end

function [tilt, aiming] = spatial_angle_trans2(alpha_gaze,theta_gaze)
yaw   = atan(-tan(theta_gaze))*cos(alpha_gaze);
pitch = atan(-sin(alpha_gaze)/(cos(alpha_gaze)*sin(yaw)-cot(theta_gaze)*cos(yaw)));
tilt  = -pitch*180/pi;aiming=-yaw*180/pi+180;
end

function [x,y,L] = ImageCoordinatesFunction(image)
image     = im2double(image);
  R       = image(:,:,1);
  G       = image(:,:,2);
  B       = image(:,:,3);
imagesize = size(image);
  xi      = 1:imagesize(:,2);
  yi      = 1:imagesize(:,1);
[y1,x1]   = meshgrid(yi,xi);x = x1(:);y = y1(:);
Lmap      = zeros([imagesize(:,1),imagesize(:,2)]);
for i     = 1:length(xi)
    for j = 1:length(yi)
        Lmap(i,j) = 179*(0.2127*R(i,j)+0.7152*G(i,j)+0.0722*B(i,j));
    end
end
  L    = Lmap(:);
 XYL   = [x,y,L];[r,c] = size(XYL);
 index = 1:r;all(XYL');
 XYL   = XYL(index(all(XYL')),:);
  x    = XYL(:,1);
  y    = XYL(:,2);
  L    = XYL(:,3);
end

function [image,CV] = coordinates2image(r,c,L)
image = zeros(max(r),max(c));
for i = 1:length(r)
    x = r(i);
    y = c(i);
    image(x,y) = L(i);
end
CV = std(L)/mean(L);
end

function [D_u] = pupil_area_function (FOV,image_size,projection_type)
  xi    = 1:image_size(:,2);
  yi    = 1:image_size(:,1);
[y1,x1] = meshgrid(yi,xi);
  x     = x1(:);
  y     = y1(:);
L = FOV(:);FOV = [x,y,L]; [r,~] = size(FOV);index = 1:r; 
all(FOV');FOV  = FOV(index(all(FOV')),:);
L     = FOV(:,3);
L_sum = sum(L);
if projection_type     == 1 %dual fisheye image
    pixel_solid_angle  = 1.2512e-06*64;%4.1707e-07;
elseif projection_type == 2 %equirectangular
    pixel_solid_angle  = 1.01e-04;%3.3516e-05
end
flux_density = pixel_solid_angle*(180/pi)^2*L_sum;
    f        = flux_density^0.41;
    y        = 25;%input age
if y >= 20
    D_u = (18.5172+0.122165*f-0.105569*y+0.000138645*f*y)/(2+0.0630635*f);%%%united diameter equation
else
    D_u = (16.4674+exp(-0.208269*y*(-3.96868+0.00521209*f))+0.124857*f)/(2+0.0630635*f);
end
end

function [fluxmap,totalflux] = flux_calculation_function(L,D_pupil,projection_type)
Stile_crawford = 1-0.0106*D_pupil^2+0.0000419*D_pupil^4;
if projection_type     == 1 %dual fisheye image
    pixel_solid_angle  = 1.2512e-06*64;%4.1707e-07;
       f               = 894*0.125;
elseif projection_type == 2 %equirectangular
    pixel_solid_angle  = 1.01e-04;%3.3516e-05;
       f               = 100;
end
fluxmap = zeros(size(L)); [r,c] = size(L);
A_pupil = pi*(D_pupil/2*10^(-3))^2;
for i = 1:r
    for j  = 1:c
      xc   = j-(r/2); yc = i-(c/2);
     theta = 2*asin(sqrt(xc^2+yc^2)/(2*f));
     pupil_ellipticity   = 1-1.0947*10^(-4)*(theta/pi*180)^2+1.8698*10^(-9)...
         *(theta/pi*180)^4;
    if pupil_ellipticity >= 0
        fluxmap(i,j)     = L(i,j)*A_pupil*pupil_ellipticity*Stile_crawford...
            *pixel_solid_angle;
    else
        fluxmap(i,j)     = 0;
    end
    end
end
totalflux = sum(sum(fluxmap));
end