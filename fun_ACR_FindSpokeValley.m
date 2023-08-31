function [spk_vly,spk_vly_loc] = fun_ACR_FindSpokeValley...
    (slice_num,r,Int_circum,spk_pks_loc,visual)
% This function receives spoke peaks location and searches towards both
% sides of an individual peak to find the valley or background intensity
% next to each peak. The background intensity is the minimum value of the
% minimum values of both sides of the peak. 
%
% Input:
%   slice_num: slice number (8-11)
%   r: radius order (1-3, from smallest radius)
%   Int_circum: intensity profile along a circumference
%   spk_pks_loc: spoke peak location vector, 1-by-10 vector get from
%                fun_ACR_FindSpokePeak
%   visual: visualisation option, 1=on & 0=off. Showing all graphs and
%           plots for visualisation purpose
%
% Output:
%   spk_vly: 1-by-10 vector of 10 spokes valley or background intensity
%   spk_vly_loc: 1-by-10 vector of location of 10 spokes valley
%
% HW: (search for HW)
%   the dummy is set to 5, larger than the normalised spoke intensity.
%       during valley search, if new value is less than dummy, then assign
%       the new value to dummy
%   max searching range for r=1 is 3 pixels, for r=2,3 is 5 pixels, because
%       r=1 gives smaller vector size as the result of larger radian
%       interval
%   
%
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1
% History: v.1 (21/06/13)
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.search both sides of each peak and set the minimum value as the valley
spk_vly_loc=zeros(1,size(spk_pks_loc,2));
spk_vly=zeros(1,size(spk_pks_loc,2));
if r==1
    for i=1:size(spk_pks_loc,2)
        dummy_loc=0;%HW:dummy needs > spoke norm value
        dummy_int=Int_circum(1,spk_pks_loc(1,i));
        for j=1:2%HW:max search range
            if spk_pks_loc(1,i)+j>size(Int_circum,2)%if search is outside
                break;                              %vector bndry
            elseif dummy_int>Int_circum(1,spk_pks_loc(1,i)+j)
                dummy_loc=spk_pks_loc(1,i)+j;
                dummy_int=Int_circum(1,spk_pks_loc(1,i)+j);
            end
        end
        for j=1:2%HW:max search range
            if spk_pks_loc(1,i)-j<1%if search is outside vector bndry
                break;
            elseif dummy_int>Int_circum(1,spk_pks_loc(1,i)-j)
                dummy_loc=spk_pks_loc(1,i)-j;
                dummy_int=Int_circum(1,spk_pks_loc(1,i)-j);
            end
         end
         spk_vly_loc(1,i)=dummy_loc;
         spk_vly(1,i)=dummy_int;
    end
elseif r==2||r==3
    for i=1:size(spk_pks_loc,2)
        dummy_loc=0;%HW:dummy needs > spoke norm value
        dummy_int=Int_circum(1,spk_pks_loc(1,i));
        for j=1:4%HW:max search range
            if spk_pks_loc(1,i)+j>size(Int_circum,2)%if search is outside
                break;                              %vector bndry
            elseif dummy_int>Int_circum(1,spk_pks_loc(1,i)+j)
                dummy_loc=spk_pks_loc(1,i)+j;
                dummy_int=Int_circum(1,spk_pks_loc(1,i)+j);
            end
        end
        for j=1:4%HW:max search range
            if spk_pks_loc(1,i)-j<1%if search is outside vector bndry
                break;
            elseif dummy_int>Int_circum(1,spk_pks_loc(1,i)-j)
                dummy_loc=spk_pks_loc(1,i)-j;
                dummy_int=Int_circum(1,spk_pks_loc(1,i)-j);
            end
         end
         spk_vly_loc(1,i)=dummy_loc;
         spk_vly(1,i)=dummy_int;
    end
end
%3.plot the points on intensity profile
if visual==1
    figure;plot(Int_circum);hold on;
    plot(spk_vly_loc,spk_vly-0.005,'r^');
    legend('Intensity profile','Spoke Valley');
    title(['Intensity Profile along Circumference with Radius '...
        num2str(r)]);hold off;
    msgbox(['Missing valleys? Don''t worry. The code uses the smallest '...
        'value of both side to calculate the peak-to-valley difference.']);
else
    disp('You have turned off the visualisation of intensity peaks.');
end
end