function Flux_gradient2(lmap)
lmap(lmap<0) = 0;lumimg = (lmap - min(min(lmap)))/(max(max(lmap))-min(min(lmap)));
% if  (1.5<cv)&&(cv<10)
%     gm = round(1/cv,2);
% elseif cv>10
%     gm = 0.09;
% else
%     gm = 1;
% end
lumimg = uint8(lumimg.*256);
rg = max(max(lmap))-min(min(lmap)); crange = jet(256);crange(1,:) = 0;
cb1 = 0;cb2 = 20;cb3 = 40;cb4 = 60;cb5 = 80;cb6 = 100;
figure(1);imshow(lumimg,'Colormap',crange);%name=sprintf('total flux = %0.5g lm',total_flux);title(name,'FontSize',14);
hcb = colorbar('Ticks',[0,51,102,153,204,255],'TickLabels',{cb1,cb2,cb3,cb4,cb5,cb6},'FontSize',12);
title(hcb,'Ratio(%)','FontSize',14);
end