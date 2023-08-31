function [pks,pks_loc]=fun_ACR_FindSpokePeak...
    (slice_num,r,Int_circum,rad_interval,visual)
% This function searches the intensity profile along the circumference from
% the LCOD disk and then identifies the number of peak
%
% Input:
%   slice_num: slice number (8-11)
%   r: radius order (1-3, from smallest radius)
%   Int_circum: intensity profile along a circumference
%   rad_interval: radian interval when sampling intensity profile (0.16 for
%                 smallest radius, 0.1 for 2 larger radius by default)
%   visual: visualisation option, 1=on & 0=off. Showing all graphs and
%           plots for visualisation purpose
%
% Output:
%   pks: 1-by-10 vector of 10 spokes peak
%   pks_loc: 1-by-10 vector of location of 10 spokes peak
%
% HW: (search for HW)
%   radian interval when sampling intensity profile 0.16 for smallest 
%       radius, 0.1 for 2 larger radius
%
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (07/06/13)
% History: v.1
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.check if user specified radian interval
if ~exist('rad_interval','var')||isempty(rad_interval)
    if r==1
        rad_interval=0.16;
    elseif r==2||r==3
        rad_interval=0.1;
    end
end
if ~exist('visual','var')||isempty(visual)
    visual=0;
end
%1.find the peaks of intensity profile
[~,locs]=findpeaks(Int_circum);
loc_pk_1st=locs(1,1);
%2.define hori axis scale
scale_vec=zeros(1,size(Int_circum,2));
for i=2:size(scale_vec,2)
    scale_vec(1,i)=rad_interval+scale_vec(1,i-1);
end
%3.find expected peak radian
expect_pks_rad=zeros(1,10);
expect_pks_rad(1,1)=scale_vec(1,loc_pk_1st);%1st expected peak from observ
for i=2:size(expect_pks_rad,2)
    expect_pks_rad(1,i)=expect_pks_rad(1,i-1)+2*pi/10;%10 spoke,each 36 deg
end
if r==1
    expect_pks_rad=round(expect_pks_rad*100)/100;%2dp if rad interal=0.12
else
    expect_pks_rad=round(expect_pks_rad*10)/10;%1dp if rad interal=0.1
end
%4.find expected peak location
expect_pks_loc=zeros(1,10);
if r==1
    for i=1:size(expect_pks_loc,2)
        dummy=expect_pks_rad(1,i);
        expect_pks_loc(1,i)=...
            find(abs(scale_vec-dummy)<=rad_interval/2);%cannot use == here
    end
else
    for i=1:size(expect_pks_loc,2)
        dummy=expect_pks_rad(1,i);
        expect_pks_loc(1,i)=...
            find(abs(scale_vec-dummy)<1e-5);%cannot use == here
    end
end
disp(['The expected peak location for radius ' num2str(r)...
    ' is: ' mat2str(expect_pks_loc)]);
%5.search -1/+1 interval to get real peak location
pks_loc=expect_pks_loc;
for i=1:size(pks_loc,2)
    if Int_circum(expect_pks_loc(1,i)-1)>Int_circum(expect_pks_loc(1,i))
        pks_loc(1,i)=expect_pks_loc(1,i)-1;
    end
    if expect_pks_loc(1,i)+1<size(scale_vec,2)%avoid error when error is
        if Int_circum(expect_pks_loc(1,i)+1)>...%last element
                Int_circum(expect_pks_loc(1,i))
            pks_loc(1,i)=expect_pks_loc(1,i)+1;
        end
    end
end
disp(['The real peak location for radius ' num2str(r)...
    ' is: ' mat2str(pks_loc)]);
%6.find the normalised value at expected location
pks=zeros(1,10);
for i=1:size(pks,2)
    pks(1,i)=Int_circum(1,pks_loc(1,i));
end
%7.plot the peaks on intensity profile
if visual==1
    figure;plot(Int_circum);hold on;
    plot(pks_loc,pks+0.005,'r^',expect_pks_loc,pks+0.005,'bx');
    legend('Intensity profile','Real Peaks','Expected Peaks',...
        'Location','South');
    title(['Intensity Profile along Circumference with Radius '...
        num2str(r)]);hold off;
else
    disp('You have turned off the visualisation of intensity peaks.');
end
end