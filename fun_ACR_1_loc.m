function [distance_real,pf_hdl]=fun_ACR_1_loc...
    (dir_name,file_name,visual,imag_check,save_path)
% This function is used for geometric distortion check on localiser. The
% slice thickness insertion ramp is used to determine 2 vertical lines on
% bth side of it to measure the length of phantom. Original code was writen
% for 256x256 matrix size, new code updated to include 512x512 matrix size
%
% NOTE: This image needs to be acquired with intensity homogeneity filtered
%       turned on. Otherwise, this function may give faulse result when the
%       intensity near the measurement is low due to the uncorrected
%       intensity.
%
% Input:
%   dir_name: directory path string where image is stored
%   file_name: file name of localiser
%   visual: visualisation option, 1=on & 0=off. Showing all graphs and
%           plots for visualisation purpose
%   imag_check: if check the current image is the correct image
%   save_path: the path to save image
% Output:
%   distance_real: length of phantom
%   pf_hdl: pass/fail handle
% Usage: 
%   distance=fun_ACR_1_loc()
%   distance=fun_ACR_1_loc('dir_str','file_str',1or0,1or0)
% HW: (search for HW)
%   sample row location is 10 pxl away from wedge edge;
%   mask threshold=mu-2*std to cover most water (necessary to cover 95%);
%   result display location on image;
%
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1
%          v.2 (search for v2)
%          v.3 (27/03/13)(15/05/13)(search for v3)
%          v.4 (20/07/13)(search for v4)
%          v.5 (21/08/13)(search for v5)
%          v.6 (09/01/14)(seaech for v6)
%          v.7 (11/01/14)(search for v7)
%          v.8 (30/04/14)(search for v8)
%          v.9 (27/11/14)(search for v9)
% History: v.1 (26/03/13)
%          v.2 use fun_DICOMInfoAccess to get pixel size and convert result
%              to mm;
%              display result on image
%          v.3 allow user to change the directory and file names depends on 
%              where the image is stored. This can be changed at the 
%              beginning of this file also directory and file name strings 
%              are 2 new inputs of this function add visualisation option
%          v.4 original code was writen for 256x256 matrix size, changed to
%              512x512 matrix size
%          v.5 add option if to allow user to check the current image;
%              output pass/fail handle
%          v.6 measurement sampling location for 256&512 matrix size;
%              find horizontal boundary of phantom and then mid-point and
%              then search towards sides for central dark segment
%              boundaries and then sample phantom length measurement
%              locations near boundaries
%          v.7 replace manual setup of intensity range for water peak
%              intensity calculation with automatic peak estimation;
%              add possible fail reason, if the image is not filtered with
%              homogeneity filter, then the result may be shorter than the
%              actual phantom length. It usually happens when the low
%              intensity region locates close to where measurement does
%          v.8 add save_path variable to save measurement image to a
%              designated path
%          v.9 Instead of sample 3 row profile for searching phantom bottom
%              edge, only sample the image middle row for sampling.
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.check if user has specified dir and file name
if ~exist('dir_name','var')||isempty(dir_name)%v3
    dir_name='test_images\';
end
if ~exist('file_name','var')||isempty(file_name)%v3
    file_name='loc.dcm';
end
if ~exist('visual','var')||isempty(visual)%v3
    visual=0;
end
if ~exist('imag_check','var')||isempty(imag_check)%v5
    imag_check=0;
end
%2.load and display image to let user check if it is localiser
I=dicomread([dir_name file_name]);%v3
I=double(I);
if imag_check==1%v5
    h=imtool(I,[]);
    choice = questdlg('Is this image the localiser?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');%Construct a questdlg with two options
    switch choice%Handle response
        case 'Yes'
            path_name=[dir_name file_name];%v3
            %v6 comment out
%             imcontrast(h);%open contrast window
%             prompt = {'Lower Intensity:','Higher Intensity:'};
%             dlg_title = 'Water Intensity Range';
%             num_lines = 1;
%             def = {'600','2200'};
%             answer = inputdlg(prompt,dlg_title,num_lines,def);
            close(h);%shut window
        case 'No'
            close(h);%shut window
            disp('Manually select localiser image.');%manual selection
            [f_n,p_n]=uigetfile([dir_name '*.dcm']);%v3
            path_name=fullfile(p_n,f_n);
            I=dicomread(path_name);
            h=imtool(I,[]);
            %v6 comment out
%             imcontrast(h);%open contrast window
%             prompt = {'Lower Intensity:','Higher Intensity:'};
%             dlg_title = 'Water Intensity Range';
%             num_lines = 1;
%             def = {'700','2200'};
%             answer = inputdlg(prompt,dlg_title,num_lines,def);
            close(h);%shut window
    end
elseif imag_check==0
    path_name=[dir_name file_name];
    %v6 comment out
%     h=imtool(I,[]);
%     imcontrast(h);
%     prompt = {'Lower Intensity:','Higher Intensity:'};
%     dlg_title = 'Water Intensity Range';
%     num_lines = 1;
%     def = {'600','2200'};
%     answer = inputdlg(prompt,dlg_title,num_lines,def);
%     close(h);%shut window
end
%3.use mean and std of water to mask image
%v6 comment out
% I_low=str2double(answer{1,1});%get the input
% I_high=str2double(answer{2,1});
% [mu,~]=fun_ACR_FindWaterMean...
%     (I,I_low,I_high,'rician',visual);%find water mean
mu=fun_ACR_FindWaterIntPeak(I,0.1,visual);
% I_bin=add_threshold(I,mu-2*sigma);%HW:threshold mu-2*std to ensure most
% imtool(I_bin,[]);                 %water masked in new binary image
I_bin=add_threshold(I,mu/2);%half water mean as threshold
if visual==1%v3
    figure;
    imshow(I_bin,[]);
    title('Thresholded Localiser Image');
else
    disp(['You have turned off graph visualisation '...
        'to show the thresholded localiser image']);
end
%4.sample two vertical measurements around ramp insert
%===========v6 start===========
% if fun_DICOMInfoAccess(path_name,'Rows')==256
%     row_ind=round(0.74*size(I_bin,1));%HW:roughly 190th row for 256 image size
% elseif fun_DICOMInfoAccess(path_name,'Rows')==512
%     row_ind=round(0.66*size(I_bin,1));%HW:roughly 340th row for 512 %v4
% else
%     row_ind=round(0.66*size(I_bin,1));%HW:for other size
% end
% bndry_left=find(I_bin(row_ind,:),1,'first');%left phantom bndry
% bndry_right=find(I_bin(row_ind,:),1,'last');%right phantom bndry
% dark_seg_midpt=round((bndry_right-bndry_left)/2+bndry_left);
% for i=dark_seg_midpt:-1:dark_seg_midpt-50%50 is arbitrary
%     if I_bin(row_ind,i)==1
%         bndry_low=i;
%         break;
%     end
% end
% for i=dark_seg_midpt:dark_seg_midpt+50%here 50 is arbitrary
%     if I_bin(row_ind,i)==1
%         bndry_high=i;
%         break;
%     end
% end
% % [bndry_low,bndry_high]=fun_ACR_FindBndryBinaryRow(I_bin,row_ind);
% %===========v6 finish===========
% sample_distance=20;%HW:sample measurement 10 pxl away from boundary
% [bndry_top_left,bndry_bottom_left]=fun_ACR_FindWaterBndryBinaryCol...
%     (I_bin,bndry_low-sample_distance);%vertical bndry left side of ramp
% [bndry_top_right,bndry_bottom_right]=fun_ACR_FindWaterBndryBinaryCol...
%     (I_bin,bndry_high+sample_distance);%vertical bndry right side of ramp
%===========v9 start===========
% sample_leftbndry(1)=find(I_bin(round(0.25*size(I_bin,1)),:),1,'last');
% sample_leftbndry(2)=find(I_bin(round(0.50*size(I_bin,1)),:),1,'last');
% sample_leftbndry(3)=find(I_bin(round(0.75*size(I_bin,1)),:),1,'last');
% if std(sample_leftbndry)<5%if small rotation
%     left_bndry=round(mean(sample_leftbndry));
% else%if large rotation or false measurement
%     left_bndry=round(max(sample_leftbndry));
% end
left_bndry=find(I_bin(round(0.50*size(I_bin,1)),:),1,'last');
pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');%v2
sample_col_ind=round(left_bndry-0.75*16/pxl_sz(1,1));%somewhere between left bndy and last grid
sample_col_top=find(I_bin(:,sample_col_ind),1,'first');
sample_row_ind=sample_col_top+round(98.8/pxl_sz(1,1));
centre_col=left_bndry-round(95.8/pxl_sz(1,1));
sample_distance=round(12.5/pxl_sz(1,1));
[bndry_top_left,bndry_bottom_left]=fun_ACR_FindWaterBndryBinaryCol...
    (I_bin,centre_col-sample_distance);%vertical bndry left side of ramp
[bndry_top_right,bndry_bottom_right]=fun_ACR_FindWaterBndryBinaryCol...
    (I_bin,centre_col+sample_distance);%vertical bndry right side of ramp
%===========v9 finish===========
%5.find vertical distance and convert to mm
distance_left=bndry_bottom_left-bndry_top_left;
distance_right=bndry_bottom_right-bndry_top_right;
distance_ave=(distance_left+distance_right)/2;
% pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');%v2
distance_real_l=distance_left*pxl_sz(2,1);
distance_real_l=round(distance_real_l*10)/10;
distance_real_r=distance_right*pxl_sz(2,1);
distance_real_r=round(distance_real_r*10)/10;
distance_real=distance_ave*pxl_sz(2,1);
distance_real=abs(round(distance_real*10)/10);%round to 1st d.p
%6.display lines on image
figure;
imshow(I,[]);
hold on
%===========v7 start===========
% p1=[bndry_low-sample_distance,bndry_top_left];
% p2=[bndry_low-sample_distance,bndry_bottom_left];
% p3=[bndry_high+sample_distance,bndry_top_right];
% p4=[bndry_high+sample_distance,bndry_bottom_right];
p1=[centre_col-sample_distance,bndry_top_left];
p2=[centre_col-sample_distance,bndry_bottom_left];
p3=[centre_col+sample_distance,bndry_top_right];
p4=[centre_col+sample_distance,bndry_bottom_right];
%===========v7 finish===========
plot([p1(1),p2(1)],[p1(2),p2(2)],'Color','r','LineWidth',2);
plot([p3(1),p4(1)],[p3(2),p4(2)],'Color','r','LineWidth',2);
text(p1(1)-50,(p2(2)-p1(2)),...%HW:50 pxls to left
    [num2str(distance_real_l) '\rightarrow'],...%use 'normalized' to scale
    'Color','r','FontUnits','normalized');      %letter to image
text(p3(1)+3,(p4(2)-p3(2)),...%HW:3 pxls to left
    ['\leftarrow' num2str(distance_real_r)],...%use 'normalized' to scale
    'Color','r','FontUnits','normalized');     %letter to image
disp('The red line doesn''t seem to reach the phantom edge on image shown?');
disp('It''s ok, because the displayed line only extends to the pixel centre.');
if exist('save_path','var')
    saveas(gcf,[save_path 'Test1_Loc.png'])
    disp('The result image has been saved to the following path:');
    disp(save_path);
end
%7.pass/fail handle
if distance_real>=146 && distance_real<=150%v5
    pf_hdl=1;
else
    pf_hdl=0;
end
%8.give possible fail reason
if distance_real<143%v7
    h=msgbox(['Your result is ' num2str(distance_real) ' mm. '...
        'It is shorter than the minimum acceptable phantom length by '...
        num2str(distance_real-146) ' mm. '...
        'The difference is too big. It can''t be the distortion. '...
        'Make sure you turn on the intensity homogeneity filter '...
        'when you acquire the localiser image.']);
    uiwait(h);
end
end