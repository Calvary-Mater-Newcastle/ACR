function Phi = segCroissRegion(tolerance,Igray,x,y,visual)
% This function is written Stéphane and downloaded from Matlab central: 
% http://www.mathworks.com.au/matlabcentral/fileexchange/35269-simple-
% single-seeded-region-growing
% It is used to grow low contrast disk on S8 to S11 binary image, tol sets
% to 0.5 or 1, Igray uses binary image, x&y uses phantom centre

% Modification:
%   add visualisation option

%1.visualisation option
if ~exist('visual','var')||isempty(visual)
    visual=0;
end
%2.original code
Phi = false(size(Igray,1),size(Igray,2));
ref = true(size(Igray,1),size(Igray,2));
PhiOld = Phi;
Phi(uint8(x),uint8(y)) = 1;
while(sum(Phi(:)) ~= sum(PhiOld(:)))
    PhiOld = Phi;
    segm_val = Igray(Phi);
    meanSeg = mean(segm_val);
    posVoisinsPhi = imdilate(Phi,strel('disk',1,0)) - Phi;
    voisins = find(posVoisinsPhi);
    valeursVoisins = Igray(voisins);
    Phi(voisins(valeursVoisins > ...
        meanSeg - tolerance & valeursVoisins < ...
        meanSeg + tolerance)) = 1;
end
%3.visualise or not
if visual==1
    imtool(Phi,[]);%for visualisation purpose only
else
    disp(['You have turned off graph visualisation '...
        'in segCroissRegion.']);
end
%4.original code continues
% Uncomment this if you only want to get the region boundaries
% SE = strel('disk',1,0);
% ImErd = imerode(Phi,SE);
% Phi = Phi - ImErd;