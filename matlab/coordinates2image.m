function [image,CV] =coordinates2image(r,c,L)
image=zeros(max(r),max(c));
for i=1:length(r)
    x=r(i);y=c(i);
    image(x,y)=L(i);
end
CV = std(L)/mean(L);
end

