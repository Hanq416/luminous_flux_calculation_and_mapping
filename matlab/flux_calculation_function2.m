function [fluxmap,totalflux] = flux_calculation_function2(L,D_pupil,projection_type)
%Stile_crawford = 1-0.0106*D_pupil^2+0.0000419*D_pupil^4;
Stile_crawford = 1;
if projection_type == 1 %dual fisheye image
    pixel_solid_angle = 1.2512e-06;%4.1707e-07;
    f=1789/2;
elseif projection_type == 2 %equirectangular
    pixel_solid_angle = 1.0055e-04;%3.3516e-05;
    f=100;
end
fluxmap=zeros(size(L));[r,c]=size(L);
A_pupil=pi*(D_pupil/2*10^(-3))^2;
for i=1:r
    for j=1:c
    xc=j-(r/2);yc=i-(c/2);
    theta=2*asin(sqrt(xc^2+yc^2)/(2*f));
    pupil_ellipticity=1-1.0947*10^(-4)*(theta/pi*180)^2+1.8698*10^(-9)*(theta/pi*180)^4;
    if pupil_ellipticity>=0
    fluxmap(i,j)=L(i,j)*A_pupil*pupil_ellipticity*Stile_crawford*pixel_solid_angle;
    else
    fluxmap(i,j)=0;
    end
    end
end
totalflux = sum(sum(fluxmap));
end

