function [int_pk]=fun_ACR_FindWaterIntPeak(I,per,visual)
% This function finds the water intensity peak on the image intensity
% histogram. This intensity peak will be used to threshold image. This
% function may also be used to find the intensity peak from the higher
% intensity side.
% Process (old):
% 1. specify range of intensity (10% max as min to exclude air intensity)
% 2. smooth intensity histogram using SMOOTH function to reduce noise
% 3. find peaks on the intensity histogram
% 4. for localiser image, use the last peak as the water intensity peak;
%    for S1/S5/S7/S11 image, plot the 1st derivative of intensity counts 
%    and use the last peak to define water intensity peak
% Process (new):
% 1. specify range of intensity (10% max as min to exclude air intensity)
% 2. find the max of the histogram frequency within that range, because
%    this is the peak and water intensity
% NOTE:
%    10% above is the experimental value found from all the images so far.
%       This value is high enough to exclude the air intensity on the
%       histogram.
%
% Input:
%   I: phantom original image
%   choice: 'loc','S1','S5','S6'(not in use)
%   per: percentage of maximum intensity for minimum definition (10% for
%        loc, S1 & S5 mean intensity searching, 50% for S8-11 image 
%        contrast setting during manual QA)
%   visual: visualisation option, 1=on & 0=off
% Output:
%   int_pk: water intenstiy peak
% Usage: 
%   mu=fun_ACR_FindWaterIntPeak(I,0.1,visual);
% HW: (search for HW)
%   when smooth intensity profile, use 5% sampling rate;
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (11/01/14)
%          v.2 (19/01/14)(search for v2)
% History: v.1
%          v.2 use max count to locate mean water intensity on intensity
%              histogram (instead of find all the peaks on intensity
%              histogram and then define last peak as mean water intensity)
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%check if user has specified dir and file name and visualisation option
if ~exist('visual','var')||isempty(visual)
    visual=0;
end
%1.specify intensity range
I_max=double(max(max(I)));
[hist_cnt,hist_int]=hist(I(:),0:I_max);
hist_sample_start=round(I_max*per);%percentage of max as min to exclude air intenisty
%++++++++++++start v2++++++++++++
%2.find max within specified histogram range
[int_cnt,int_pk]=max(hist_cnt(hist_sample_start:size(hist_cnt,2)));%v2
int_pk=int_pk+hist_sample_start-1;%v2
%3.display intensity on graph
if visual==1
    figure;
    plot(hist_cnt,'g');
    hold on;
    plot(hist_sample_start:size(hist_int,2),...
        hist_cnt(hist_sample_start:size(hist_cnt,2)),'b');
    hold on;
    plot(int_pk,int_cnt,'k^','markerfacecolor',[1 0 0]);
    hold off;
    xlim([0 I_max*1.1]);
    ylim([0 int_cnt*1.1]);
    title('Intensity Histogram of Image');
    legend('Total Intensity Range','Sampled Intensity Range','Peak Intensity (Water)','Location','NorthWest');
end
%++++++++++++finish v2++++++++++++
% hist_sample_end=I_max;
% water_raw=hist_cnt(hist_sample_start:hist_sample_end);
% %2.smooth intensity profile
% water_smooth=smooth(water_raw,0.05,'lowess');%HW:sample rate=5%
% %3.find peaks on intensity histogram
% [a,b]=findpeaks(water_smooth);
% c=1:size(water_smooth,1);
% if visual==1
%     figure;
%     plot(c,water_raw,'y');
%     hold on;
%     plot(c,water_smooth,'r');
%     hold on;
%     plot(c(b),a+0.05,'k^','markerfacecolor',[1 0 0]);
%     hold off;
%     title('Intensity Histogram and Sampled Peaks');
%     legend('Raw Intensity','Smoothed Intensity','Peaks');
% end
% %4.determine water intensity peak
% % if strcmp(choice,'loc')
% %     diff_prof=abs(diff(a));%derivative of intensity count profile
% %     [~,bb]=findpeaks(diff_prof);
% %     [~,~,dummy]=find(bb,1,'last');
% % %     if dummy<size(a,1)
% % %         dummy=dummy+1;
% % %     end
% %     int_pk=b(dummy)+I_max*0.1;
% % %     [~,~,int_pk]=find(b,1,'last');
% % elseif strcmp(choice,'S1')||strcmp(choice,'S5')||strcmp(choice,'S7')...
% %         ||strcmp(choice,'S11')
% %     diff_prof=abs(diff(a));%derivative of intensity count profile
% %     [~,bb]=findpeaks(diff_prof);
% %     [~,~,dummy]=find(bb,1,'last');
% % %     if dummy<size(a,1)
% % %         dummy=dummy+1;
% % %     end
% %     int_pk=b(dummy)+I_max*0.1;
% % else
% %     disp('Wrong input in CHOICE assignment.');
% % end
% [~,bb]=findpeaks(a);%diff_prof);
% [~,~,dummy]=find(bb,1,'last');
% int_pk=b(dummy)+I_max*0.1;
end