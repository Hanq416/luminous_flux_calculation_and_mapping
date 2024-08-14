function Flux_gradient(lmap,cv,total_flux,i)
lmap(lmap<0) = 0;lumimg = (lmap - min(min(lmap)))/(max(max(lmap))-min(min(lmap)));
if  (1.5<cv)&&(cv<10)
    gm = round(1/cv,2);
elseif cv>10
    gm = 0.09;
else
    gm = 1;
end
lumimg = uint8((lumimg.^gm).*256);
rg = max(max(lmap))-min(min(lmap)); crange = jet(256);crange(1,:) = 0;
cb1 = round(10e7.*rg.*(0.03316.^(1/gm)),7);cb2 = round(10e7.*rg.*(0.26754.^(1/gm)),2);
cb3 = round(10e7.*rg.*(0.50191.^(1/gm)),2);cb4 = round(10e7.*rg.*(0.73629.^(1/gm)),2);
cb5 = round(10e7.*rg.*(0.97066.^(1/gm)),2);
figure(i);imshow(lumimg,'Colormap',crange);name=sprintf('total flux = %0.5g lm',total_flux);title(name,'FontSize',14);
hcb = colorbar('Ticks',[8,68,128,188,248],'TickLabels',{cb1,cb2,cb3,cb4,cb5},'FontSize',12);
title(hcb,'Lumen (lm*10e-7)','FontSize',14);
end