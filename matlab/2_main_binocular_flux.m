% -----------------------------------Purpose-------------------------------
%    Using the gaze behaviour data and the really-captured or rendered HDR
%    images to calculate the real-time luminous flux entering human eyes
%    and the total light exposure of binocular vision

% ------------------------------- input variables -------------------------
projection_type=1;%1 = hdr photo dual fisheye; 2 = rendering HDRI equirectangular
%gazemap=load('gazemap.txt');
gaze_longtitude=gazemap(:,1);gaze_latitude=-gazemap(:,2);head_longtitude=gazemap(:,3);head_latitude=gazemap(:,4);
[gaze_alpha,gaze_theta] = gazedg2ta(gaze_longtitude,gaze_latitude);
%gaze_alpha=gaze_alpha';
Total_gaze_direction=[gaze_alpha,gaze_theta,head_latitude,head_longtitude];
%% --------------------------- input hdr images ---------------------------
[fn,pn] = uigetfile('*.hdr','select an panoramic hdr image');str = [pn,fn];
I = hdrread(str);
if projection_type == 1
    cf = input('Please input the calibration factor for the image:');
    I = imresize(I,0.125);
elseif projection_type == 2
    Diva_cf = GetExpValue(str);cf=1/Diva_cf;
end
%% binocular flux calculation
binocular_flux_list=zeros(length(Total_gaze_direction(:,1)),4);% 1==left flux,2==right flux,3==binocular flux, 4==pupil diameter
    for i=1:length(Total_gaze_direction(:,1))
        [fluxmap_left,fluxmap_right,bino_fluxmap,D_pupil,CV] = bino_flux_function2(I,Total_gaze_direction(i,1),Total_gaze_direction(i,2),Total_gaze_direction(i,3),Total_gaze_direction(i,4),cf,projection_type);
        binocular_flux_list(i,1)=sum(sum(fluxmap_left));binocular_flux_list(i,2)=sum(sum(fluxmap_right));
        binocular_flux_list(i,3)=sum(sum(bino_fluxmap));binocular_flux_list(i,4)=D_pupil;
        totalflux_bino=sum(sum(bino_fluxmap));
        CV2= std(bino_fluxmap(:))/mean(bino_fluxmap(:));
        %Flux_gradient(bino_fluxmap,CV2,totalflux_bino,i);
        %name=['gaze_point' num2str(i)];
        %saveas(gcf,name,'jpg')
    end
% Q_light=binocular_flux_list(:,3).*period;
% Qv_final=sum(Q_light)
%% calculate a single gaze point
i=11;%input your target gaze index
[fluxmap_left,fluxmap_right,bino_fluxmap,D_pupil,CV] = bino_flux_function2(I,Total_gaze_direction(i,1),Total_gaze_direction(i,2),Total_gaze_direction(i,3),Total_gaze_direction(i,4),cf,projection_type);
left_flux=sum(sum(fluxmap_left));right_flux=sum(sum(fluxmap_right));totalflux_bino=sum(sum(bino_fluxmap));
CV= std(bino_fluxmap(:))/mean(bino_fluxmap(:));Flux_gradient(bino_fluxmap,CV,totalflux_bino,i);