function [bestk] = bestK_f(dataset,kmax)%for point number > 50
numpts=length(dataset);
if numpts <= 8
    bestk=2;
else
    K=2:kmax;K=K';
    ADCI=zeros(size(K));judge=zeros(size(K));
    for k = 2:kmax
        if k < 5
            [~,~,sumd]=kmedoids(dataset,k);ADCI(k-1)=sum(sumd)/numpts;%3
        elseif k>=5 && k<=numpts-2
            [~,~,sumd]=kmedoids(dataset,k);ADCI(k-1)=sum(sumd)/numpts;%n
            %s=silhouette(dataset,idx);avgs=mean(s);
            [~,~,sumd3]=kmedoids(dataset,k+1);ADCI3=sum(sumd3)/numpts;%n+1
            [~,~,sumd2]=kmedoids(dataset,k-1);ADCI2=sum(sumd2)/numpts;%n-1
            [~,~,sumd5]=kmedoids(dataset,k+2);ADCI5=sum(sumd5)/numpts;%n+2
            [~,~,sumd4]=kmedoids(dataset,k-2);ADCI4=sum(sumd4)/numpts;%n-2
            %[~,~,sumd7]=kmedoids(dataset,k+3);ADCI7=sum(sumd7)/numpts;%n+3
            %[~,~,sumd6]=kmedoids(dataset,k-3);ADCI6=sum(sumd6)/numpts;%n-3
            s1=ADCI(k-1)-ADCI2;%k(n,n-1)
            s2=ADCI3-ADCI(k-1);%k(n+1,n)
            s3=ADCI2-ADCI4;%k(n-1,n-2)
            s4=ADCI5-ADCI3;%k(n+2,n+1)
            %s6=abs(ADCI7-ADCI5);%k(n+3,n+2)
            %s5=abs(ADCI4-ADCI6);%k(n-2,n-3)
            %if abs(s2-s1)>abs(s1-s3) && abs(s2-s1)>abs(s4-s2)&& abs(s2-s1)>abs(s5-s3) && abs(s2-s1)>abs(s6-s4)
            if abs(s2-s1)> abs(s1-s3) && abs(s2-s1)> abs(s4-s2)
                judge(k,:)=1;
            else
                continue
            end
        else
            [~,~,sumd]=kmedoids(dataset,k);ADCI(k-1)=sum(sumd)/numpts;
    end
    end
end
figure(1),plot (K,ADCI,'-*r')
title('Average Distance From Centroid')
xlabel('Preset k Value') 
ylabel('Distance')
goodk=find(judge(:,1)==1);min_goodk=min(goodk);
formatSpec='The potential k is %d';fprintf(formatSpec,min_goodk);fprintf('\n');
threshold=(ADCI(kmax-1,1)+ ADCI(min_goodk,1))*0.5;
bestk=find((ADCI(:,1)<=threshold));bestk=min(bestk)+1;
% bestk=min_goodk;
% while bestk<kmax
% [idx,~,~]=kmedoids(dataset,bestk);
% s=silhouette(dataset,idx);avgs=mean(s);
%     if avgs>=0.62
%         break
%     else
%         bestk=bestk+1;
%     end
% end
formatSpec='The best used k value is %d';fprintf(formatSpec,bestk);fprintf('\n');
end

