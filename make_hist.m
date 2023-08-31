function make_hist(I)
%http://stackoverflow.com/questions/7401189/matlab-hist-function-for-image-data
%     img = im2uint8(img);

I_max=double(max(max(I)));
[count,bin] = hist(I(:), 0:I_max);
stem(bin,count, 'Marker','none')

hAx = gca;
set(hAx, 'XLim',[0 I_max], 'XTickLabel',[], 'Box','on')

%# create axes, and draw grayscale colorbar
hAx2 = axes('Position',get(hAx,'Position'), 'HitTest','off');
image(0:I_max, [0 1], repmat(linspace(0,1,256),[1 1 3]), 'Parent',hAx2)
set(hAx2, 'XLim',[0 I_max], 'YLim',[0 1], 'YTick',[], 'Box','on')

%# resize the axis to make room for the colorbar
set(hAx, 'Units','pixels')
p = get(hAx, 'Position');
set(hAx, 'Position',[p(1) p(2)+26 p(3) p(4)-26])
set(hAx, 'Units','normalized')

%# position colorbar at bottom
set(hAx2, 'Units','pixels')
p = get(hAx2, 'Position');
set(hAx2, 'Position',[p(1:3) 26])
set(hAx2, 'Units','normalized')

%# link x-limits of the two axes
linkaxes([hAx;hAx2], 'x')
set(gcf, 'CurrentAxes',hAx)
end