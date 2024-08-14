
% -----------------------------------Purpose-------------------------------
%    1.integrate the data retrieved from the eye tracker inclinometer
%    2.devide the data into many pieces according to the time of
%      staying at a single spot
%    3.cluster the integrated gaze data of a single spot and visualize
%
% Developer: Siqi He, Nov.2020

% ---------------------------------Input parameter-------------------------
% First,defining the pitch angle to global calibrate the face orientation
adj_latitude = -10;
% Defining the timing that in orthomode gaze mode.
origin_time = 7;
% Calibrating the camera lens/occupants' main face normal at a single spot
% calculated yaw angle: 115(pt1),76(pt2),159(pt3),96.7(pt4),-50.77(pt5),271.80(pt6)
adj_longitude = 271.80;
% Loading the original gaze and head (face) data
head = load('#head.txt'); gaze = load('#gaze.txt');
% Defining the duration of the single spot
% recorded duration: 1:138(pt1); 155:275(pt2),309:425(pt3),441:575(pt4),599:696(pt5),709:826(pt6);
t = 709:826;
% ------------------Find out the data of the target spot-------------------
head_coordinates = Totalhead_coordinates(t,:);
latitude_head = -head(:,1)+adj_latitude;longtitude_head = head(:,3);
longtitude_head_adj = zeros(size(longtitude_head));
for i=1:length(longtitude_head)
    if adj_longitude >= 0
        if longtitude_head(i,:) >= adj_longitude - 180 && longtitude_head(i,:) <= 180
            longtitude_head_adj(i,:) = longtitude_head(i,:) - adj_longitude;
        else
            longtitude_head_adj(i,:) = longtitude_head(i,:) - adj_longitude+360;
        end
    else
        if longtitude_head(i,:) >= -180 && longtitude_head(i,:) <= 180 + adj_longitude
            longtitude_head_adj(i,:) = longtitude_head(i,:) - adj_longitude;
        else
            longtitude_head_adj(i,:) = longtitude_head(i,:) - adj_longitude-360;
        end
    end
end

[Totalgazemap] = gazemap_plus_headrotation_function(gaze,origin_time);
Totalhead_coordinates = [longtitude_head_adj,latitude_head];
gazemap = Totalgazemap(t,:);
gaze_direction_4use = [gazemap,head_coordinates];
%% ----------- visualize the original unstructured gaze data --------------
gazemap2 = gazemap+head_coordinates;
figure,scatter(gazemap2(:,1),gazemap2(:,2),'r','filled')
hold on, scatter(head_coordinates(:,1),head_coordinates(:,2),'ks'),hold off
xticks([-180,-150,-120,-90,-60,-30,0,30,60,90,120,150,180]);
yticks([-90,-60,-30,0,30,60,90]);
axis equal;xlim([-180,180]);ylim([-90,90]);
title('Raw Data of Gaze Points and Head Orientation')
xlabel('horizontal degree') ;ylabel('vertical degree')
legend('gaze points','face normal')
%% ------------------------ draw gaze vector ------------------------------
gaze_head_map = [head_coordinates,gazemap];
figure,quiver(-gaze_head_map(:,1),gaze_head_map(:,2),-gaze_head_map(:,3),...
    gaze_head_map(:,4),0,'color',[1 0 0])
xticks([-180,-150,-120,-90,-60,-30,0,30,60,90,120,150,180]);
yticks([-90,-60,-30,0,30,60,90]);
axis equal;xlim([-180,180]);ylim([-90,90])
title('Vector From the Head Orientation to its Corresponding Gaze Points')
xlabel('horizontal degree');ylabel('vertical degree') 
%% ----- Automatically find the range of K (k medoids)and cluster ---------
[cluster_num] = bestK_f(head_coordinates,20);
[idx_head,head_clust,D] = kmedoids(head_coordinates,cluster_num);
ADFC = sum(D)/length(head_coordinates);%average distance from centriod
formatSpec = 'The average distance from clust centroid is %d';
fprintf(formatSpec,ADFC);fprintf('\n');
% visualize the head (face) scatter point would be in a single cluster
figure,gscatter(head_coordinates(:,1),head_coordinates(:,2),idx_head)
hold on,scatter(head_clust(:,1),head_clust(:,2),100,'b+'),hold off
axis equal;
xticks([-180,-150,-120,-90,-60,-30,0,30,60,90,120,150,180]);
yticks([-90,-60,-30,0,30,60,90]);
xlim([-180,180]);ylim([-90,90]);title('head orientation clusts and scatters')
xlabel('horizontal degree');ylabel('vertical degree') 
% visuallize the silhouette of the head cluster
figure, silhouette(head_coordinates,idx_head)
s = silhouette(head_coordinates,idx_head);avgs = mean(s);sds = std(s);
formatSpec = 'The average silhouette value of each point is %d with standard deviation %d';
fprintf(formatSpec,avgs,sds);fprintf('\n');
%% ----------- gaze cluster on each head (face) orientation ---------------
c = hsv(length(head_clust));
figure,gscatter(gazemap2(:,1),gazemap2(:,2),idx_head)
hold on,scatter(head_clust(:,1),head_clust(:,2),200,c,'+'),hold off
xticks([-180,-150,-120,-90,-60,-30,0,30,60,90,120,150,180]);
yticks([-90,-60,-30,0,30,60,90]);
axis equal;xlim([-180,180]);ylim([-90,90])
xlabel('horizontal degree');ylabel('vertical degree') 
title('Raw Gaze Points with Corresponding Head Orientation')
%% ------ diving into gaze point group with the same head index -----------
head_coordinates2 = [idx_head,head_coordinates];
head_coordinates2 = sortrows(head_coordinates2,1);
gaze3 = [idx_head,gazemap2];gaze3 = sortrows(gaze3,1);
gaze_group_cell = cell(1,cluster_num);
for i=1:cluster_num
    target_idx = find(gaze3(:,1) == i);
    target = gaze3(target_idx,:);target(:,1) = [];
    gaze_group_cell{i} = target;
end
%% cluster in each head orientation group
idx_g = [];clust_g = [];cluster_num_g = zeros(cluster_num,1);sumd_g = [];
for i = 1:cluster_num
    gazei = gaze_group_cell{i};
    kmax = length(gazei);
    [cluster_num_gi] = bestK_f2(gazei,kmax);
    [idx_gi,clust_gi,sumd_gi] = kmedoids(gazei,cluster_num_gi);
    clust_g = [clust_g;clust_gi];
    cluster_num_g(i) = cluster_num_gi;sumd_g = [sumd_g;sumd_gi];
    if i == 1
    idx_g = [idx_g;idx_gi];
    else
    idx_gi = idx_gi+max(idx_g); idx_g = [idx_g;idx_gi];
    end
end
sum_clust_gaze = sum(cluster_num_g);
formatSpec = 'The total gaze clust number is %d.';
fprintf(formatSpec,sum_clust_gaze);fprintf('\n');
ADFCg_total = sum(sumd_g)/length(head_coordinates);
formatSpec = 'The average distance from gaze clust centroid is %d';
fprintf(formatSpec,ADFCg_total);fprintf('\n');

head_gaze_origin=[];
for i = 1:cluster_num
    gazei = gaze_group_cell{i};
    head_gaze_origin = [head_gaze_origin;gazei];
end

figure,gscatter(head_gaze_origin(:,1),head_gaze_origin(:,2),idx_g)
hold on,scatter(clust_g(:,1),clust_g(:,2),100,'b+'),hold off
xticks([-180,-150,-120,-90,-60,-30,0,30,60,90,120,150,180]);
yticks([-90,-60,-30,0,30,60,90]);
axis equal;xlim([-180,180]);ylim([-90,90])
xlabel('horizontal degree');ylabel('vertical degree');
title('Gaze Point Cluster')
%% ----------------------- clustered gaze vector --------------------------
head_clust_final = [];
for i = 1:cluster_num
    for j = 1:cluster_num_g(i)
        head_clust_final = [head_clust_final;head_clust(i,:)];
    end
end

gaze_clust_in_head = clust_g-head_clust_final;

% ----------------- count the time of each head orientation ---------------
    num_head = zeros(max(idx_head),1);
    for i = 1:max(idx_head)
        num_head(i,1) = length(find(idx_head==i));
    end
sz_head = num_head*7.5; c_head = hsv(length(num_head));
% -------------------- count the time of each gaze point ------------------
num_gaze=zeros(max(idx_g),1);% save for time
    for i=1:max(idx_g)
        num_gaze(i,1)=length(find(idx_g==i));
    end
sz_gaze = num_gaze*12;
c_gaze=hsv(length(num_gaze));
% -------- save for use: original gaze point with corresponding idx -------
clust_gaze_head_time=[gaze_clust_in_head,head_clust_final,num_gaze];%save file
gaze3(:,1)=[];head_coordinates2(:,1)=[];gaze4=gaze3-head_coordinates2;
scatter_gaze_head=[gaze4,head_coordinates2,idx_g];
scatter_gaze_head_idx=sortrows(scatter_gaze_head,5);%save this file
%% ------------------------------ drawing ---------------------------------
quiver(head_clust_final(:,1),head_clust_final(:,2),gaze_clust_in_head(:,1),...
    gaze_clust_in_head(:,2),0,'color',[0 0 0],'LineWidth',0.6)
hold on,scatter(head_clust(:,1),head_clust(:,2),sz_head,c_head,'filled')
hold on,scatter(head_clust(:,1),head_clust(:,2),sz_head,'k','LineWidth',2.5)
hold on,scatter(clust_g(:,1),clust_g(:,2),sz_gaze,c_gaze,'filled'),hold off
xticks([-180,-150,-120,-90,-60,-30,0,30,60,90,120,150,180]);
yticks([-90,-60,-30,0,30,60,90]);
axis equal;xlim([-180,180]);ylim([-90,90]);
xlabel('horizontal degree');ylabel('vertical degree');
title('Vector From Head Orientation to Gaze Point and their Duration')