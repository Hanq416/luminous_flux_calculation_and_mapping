%% density based spatial clustering
epsilon=8;minpts=5;
[idx_head,corepts_head] = dbscan(head_coordinates,epsilon,minpts);

core_head_coordinates=[idx_head,head_coordinates];
filter=find(idx_head==-1);core_head_coordinates(filter,:)=[];
idx_core_head=core_head_coordinates(:,1);core_head_coordinates(:,1)=[];
head_cell=cell(1,max(idx_core_head));
for i=1:max(idx_core_head)
    target=find(idx_core_head==i);head_cell{i}=core_head_coordinates(target,:);
end

%geometric center
geo_m=zeros(max(idx_core_head),2);
for i=1:max(idx_core_head)
    head_clust = head_cell{i};n=length(head_clust);
    geo_m(i,:) = real(prod(head_clust).^(1/n));
    if sum(sum(head_clust(:,1)))<=0
        geo_m(i,1) = -geo_m(i,1);
    else
        continue
    end
    if sum(sum(head_clust(:,2)))<=0
        geo_m(i,2) = -geo_m(i,2);
    else
        continue
    end
end

figure,gscatter(core_head_coordinates(:,1),core_head_coordinates(:,2),idx_core_head);
hold on,scatter(geo_m(:,1),geo_m(:,2),100,'b+'),hold off
axis equal;xticks([-180,-150,-120,-90,-60,-30,0,30,60,90,120,150,180]);yticks([-90,-60,-30,0,30,60,90]);
xlim([-180,180]);ylim([-90,90]);title('head orientation clusts and scatters')
xlabel('horizontal degree');ylabel('vertical degree')