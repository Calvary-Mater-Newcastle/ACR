function [t]=fun_DICOMAcqTimeCalc(I_path,chk_start,chk_end)
% This function read the DICOM info of an image and extracts the
% ACQUISIATION TIME & CONTENT TIME, then takes the difference of two to
% calculate the acquisation time in readable format. DICOM time is in the
% format of HHMMSS.FRAC. This fucntion assumes the actual acquisition time
% is the difference between AcquisitionTime and ContentTime.
%
% Input:
%   I_path: image path (optional)
%   chk_start: start time for check (HHMMSS) (optional)
%   chk_end: end time for check (HHMMSS) (optional)
%
% Output:
%   t: acquisation time in readable format (string)
% Usage: 
%   t=fun_DICOMAcqTimeCalc('img_path')
%   t=fun_DICOMAcqTimeCalc('img_path',123050,133050)
% HW:(search for HW)
%    
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (18/06/13)
%          v.2 (20/06/13)(search for v2)
% History: v.1
%          v.2: changed ContentTime to SeriesTime as suggested by Jason
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.if no path then performs a time check
if ~exist('I_path','var')||isempty(I_path)
    disp('There is no path input, I will perform a time check instead.');
    disp('Or you can enter the start/end time for check.');
    disp('The starting time is 20:30:50.');
    disp('The end time is 21:08:3.');
    disp('The time difference should be 0:37:13.');
    disp('Now let''s check it.');
end
%2.user input check time
if exist('chk_start','var')&&exist('chk_end','var')
    disp('It seems you have entered time for check.');
    disp('I will do your check time instead.');
    t_start_str=num2str(chk_start);
    t_end_str=num2str(chk_end);
    if size(t_start_str)<6
        t_start_str=['0' t_start_str];
    end
    if size(t_end_str)<6
        t_end_str=['0' t_end_str];
    end
else
    t_start_str='203050';
    t_end_str='210803';
end
%2.get the ACQUISATION TIME value from DICOM image
if ~exist('chk_start','var')&&~exist('chk_end','var')
    t_start_str=fun_DICOMInfoAccess(I_path,'AcquisitionTime');
end
%3.get the Series TIME value from DICOM image
if ~exist('chk_start','var')&&~exist('chk_end','var')
    t_end_str=fun_DICOMInfoAccess(I_path,'SeriesTime');%v2
end
%4.convert string into double
t_start_vec=sscanf(t_start_str,'%1f');
t_end_vec=sscanf(t_end_str,'%1f');
%5.convert time into HHMMSS format value from 6-by-1 vector
t_start=t_start_vec(1,1)*100000+t_start_vec(2,1)*10000+...
    t_start_vec(3,1)*1000+t_start_vec(4,1)*100+t_start_vec(5,1)*10+...
    t_start_vec(6,1);
t_end=t_end_vec(1,1)*100000+t_end_vec(2,1)*10000+...
    t_end_vec(3,1)*1000+t_end_vec(4,1)*100+t_end_vec(5,1)*10+...
    t_end_vec(6,1);
%6.convert time into second
dummy_h=floor(t_start/10000)*60^3;
dummy_m=floor((t_start/10000-floor(t_start/10000))*100)*60^2;
dummy_s=((t_start/10000-floor(t_start/10000))*100-...
    floor((t_start/10000-floor(t_start/10000))*100))*100*60;
t_start_s=dummy_h+dummy_m+dummy_s;%t_start in s
dummy_h=floor(t_end/10000)*60^3;
dummy_m=floor((t_end/10000-floor(t_end/10000))*100)*60^2;
dummy_s=((t_end/10000-floor(t_end/10000))*100-...
    floor((t_end/10000-floor(t_end/10000))*100))*100*60;
t_end_s=dummy_h+dummy_m+dummy_s;%t_end in s
%7.find time difference in seconds
t_diff_s=t_end_s-t_start_s;
%8.convert to hours
t_diff_h=t_diff_s/(60^3);
%9.find hour component
t_h=floor(t_diff_h);
%10.find minute component
t_m=floor((t_diff_h-floor(t_diff_h))*60);%abs here for 0 hr case
%11.find second component
t_s=((t_diff_h-floor(t_diff_h))*60-...
    floor((t_diff_h-floor(t_diff_h))*60))*60;
%12.time in HHMMSS
if ceil(log10(abs(t_h)))<2
    t_h_str=['0' num2str(t_h)];
else
    t_h_str=num2str(t_h);
end
if ceil(log10(abs(t_m)))<2
    t_m_str=['0' num2str(t_m)];
else
    t_m_str=num2str(t_m);
end
if ceil(log10(abs(t_s)))<2
    t_s_str=['0' num2str(t_s)];
else
    t_s_str=num2str(t_s);
end
t=[t_h_str ':' t_m_str ':' t_s_str];
%13.display time in HHMMSS
disp(['The acquisition time is ' num2str(t_h) ':' num2str(t_m) ':' ...
    num2str(t_s)]);
end