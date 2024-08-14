function [D_u,flux_density] = pupil_area_function2 (FOV,image_size,projection_type)
% xi=1:image_size(:,2);yi=1:image_size(:,1);[y1,x1]=meshgrid(yi,xi);x=x1(:);y=y1(:);
% L=FOV(:);FOV=[x,y,L];[r,~]=size(FOV);index=1:r;all(FOV');FOV=FOV(index(all(FOV')),:);
% L=FOV(:,3);
% L_sum=sum(L);
L_sum=sum(sum(FOV));
if projection_type == 1 %dual fisheye image
    pixel_solid_angle=1.2512e-06;
elseif projection_type == 2 %equirectangular
    pixel_solid_angle=1.0055e-04;
end
flux_density=pixel_solid_angle*(180/pi)^2*L_sum;
f=flux_density^0.41;

y=25;%input age2.0109e-05
if y>=20
    D_u=(18.5172+0.122165*f-0.105569*y+0.000138645*f*y)/(2+0.0630635*f);%%%united diameter equation
else
    D_u=(16.4674+exp(-0.208269*y*(-3.96868+0.00521209*f))+0.124857*f)/(2+0.0630635*f);
end
end

