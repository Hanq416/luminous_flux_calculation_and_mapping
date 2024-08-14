function [bestk] = bestK_f2(dataset,kmax)%for point number <= 50
numpts=length(dataset);
if numpts <= 8
    bestk=2;
else
    K=2:kmax;K=K';
    ADCI=zeros(size(K));judge=zeros(size(K));
    for k = 2:kmax
        if k < 4
            [~,~,sumd]=kmedoids(dataset,k);ADCI(k-1)=sum(sumd)/numpts;%3
        elseif k>=4 && k<=numpts-2
            [idx,~,sumd]=kmedoids(dataset,k);ADCI(k-1)=sum(sumd)/numpts;%n
            s=silhouette(dataset,idx);avgs=mean(s);
            [~,~,sumd3]=kmedoids(dataset,k+1);ADCI3=sum(sumd3)/numpts;%n+1
            [~,~,sumd2]=kmedoids(dataset,k-1);ADCI2=sum(sumd2)/numpts;%n-1
            [~,~,sumd5]=kmedoids(dataset,k+2);ADCI5=sum(sumd5)/numpts;%n+2
            [~,~,sumd4]=kmedoids(dataset,k-2);ADCI4=sum(sumd4)/numpts;%n-2
            s1=abs(ADCI(k-1)-ADCI2);%k(n,n-1)
            s2=abs(ADCI3-ADCI(k-1));%k(n+1,n)
            s3=abs(ADCI2-ADCI4);%k(n-1,n-2)
            s4=abs(ADCI5-ADCI3);%k(n+2,n+1)
            if (abs(s2-s1)>abs(s1-s3) && abs(s2-s1)>abs(s4-s2))&& avgs>0.62 
                judge(k,:)=1;
            else
                continue
            end
        else
    end
    end
judge2=isempty(judge);
if judge2==1
    goodk=find(judge(:,1)==1);bestk=min(goodk)+1;
else
    bestk=round(numpts/3);
end
end

