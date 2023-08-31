function [distance_hori_mm,distance_vert_mm,mu,pf_hdl]=fun_ACR_1_S1...
    (dir_name,file_name,visual,imag_check,img_type,save_path,pill_choice,pill_r)
% This function is to used for geometric distortion check on S1
%
% Input:
%   dir_name: directory path string where image is stored
%   file_name: file name of S1
%   visual: visualisation option, 1=on & 0=off. Showing all graphs and
%           plots for visualisation purpose.
%   imag_check: if check the current image is the correct image
%   img_type: image type (string: T1 or T2)
%   save_path: the path to save image
%   pill_choice: with/without attached pill (1=with, 0=without)
%   pill_r: pill radius in mm (num)
% Output:
%   distance_hori_mm: horizontal measurement of phantom in mm
%   distance_vert_mm: vertical measurement of phantom in mm
%   I_low: low boundary used to fit distribution to histogram (NOT USED)
%   I_high: high boundary used to fit distribution to histogram (NOT USED)
%   mu: water mean intensity will be used in later test
%   pf_hdl: pass/fail handle
% Usage: 
% HW: (search for HW)
%   mask threshold=mu-2*std to cover most water (necessary to cover 95%)
%   sum up row & col band using 30%-60% of central image to avoid missing
%       circle centre because of positioning error
%   result display location on image
%   phantom wall thickness=6 mm
%
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (27/03/13)
%          v.2 (02/04/13)(search for v2)
%          v.3 (15/05/13)(search for v3)
%          v.4 (21/08/13)(search for v4)
%          v.5 (10/01/14)(search for v5)
%          v.6 (11/01/14)(search for v6)
%          v.7 (30/04/14)(search for v7)
%          v.8 (14/07/15)(search for v8)
%          v.9 (01/04/17)(search for v9)
% History: v.1
%          v.2: add display msgbox of mu for other ACR test use
%          v.3: allow user to change the directory and file names depends
%               on where the image is stored. This can be changed at the 
%               beginning of this file;
%               also directory and file name strings are 2 new inputs of 
%               this function;
%               add visualisation option;
%               wait for user to write down water mean intensity
%          v.4: add option if to allow user to check the current image;
%               output pass/fail handle;
%               export histogram low/high intensity value for later test
%               usage;
%               export water mean intensity for later test
%          v.5: simplify the method to find coord for displaying diameter
%          v.6 replace manual setup of intensity range for water peak
%              intensity calculation with automatic peak estimation
%          v.7 add save_path variable to save measurement image to a
%              designated path
%          v.8 Add choice of with/without attached pill. This is mainly to
%              solve the missing liquid induced AP diameter mis-measurement
%              problem.
%          v.9 Add pill radius as input.
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.check if user has specified dir and file name and visualisation option
if ~exist('dir_name','var')||isempty(dir_name)%v3
    dir_name='test_images\';
end
if ~exist('file_name','var')||isempty(file_name)%v3
    file_name='S1.dcm';
end
if ~exist('visual','var')||isempty(visual)%v3
    visual=0;
end
if ~exist('imag_check','var')||isempty(imag_check)%v4
    imag_check=0;
end
if ~exist('pill_choice','var')%v8
    choice = questdlg('Did you attached a pill marker to anterior phantom on S1?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');
    switch choice%Handle response
        case 'Yes'
            pill_choice=1;
        case 'No'
            pill_choice=0;
    end
end
%2.load and display image to let user check if it is S1
I=dicomread([dir_name file_name]);%v3
I=double(I);
if imag_check==1%v4
    h=imtool(I,[]);
    choice = questdlg('Is this image the S1 image?', ...
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
%             def = {'1500','2900'};
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
%             def = {'1500','2900'};
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
%     def = {'1500','3000'};
%     answer = inputdlg(prompt,dlg_title,num_lines,def);
%     close(h);%shut window
end
%3.use mean and std of water to mask image
%v6 comment out
% I_low=str2double(answer{1,1});%get the input%v4
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
    title('Thresholded S1 Image');
else
    disp(['You have turned off graph visualisation '...
        'to show the thresholded S1 image']);
end
%======================v8 start======================
% %4.sum up a band of row (30%-60% of image size) to get row bndry
% [ind_l,ind_r]=fun_ACR_FindBndryFromBand(I_bin,'row',[0.3 0.6]);%HW
% %5.sum up a band of col (30%-60% of image size) to get col bndry
% [ind_t,ind_b]=fun_ACR_FindBndryFromBand(I_bin,'col',[0.3 0.6]);%HW
% %6.find pixel distance and convert to mm
% distance_row=ind_r-ind_l;
% distance_col=ind_b-ind_t;
% pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');%v2
% distance_real_r=distance_row*pxl_sz(2,1);
% distance_real_hori=round(distance_real_r*10)/10;
% distance_real_c=distance_col*pxl_sz(2,1);
% distance_real_vert=round(distance_real_c*10)/10;
% %7.find rest coord of bndry
% % [ind_l_y,ind_r_y]=fun_ACR_FindWaterBndryBinary_RestCoord(I_bin,'row');
% % [ind_t_x,ind_b_x]=fun_ACR_FindWaterBndryBinary_RestCoord(I_bin,'col');
% ind_l_y=(ind_b-ind_t)/2+ind_t;%v5
% ind_t_x=(ind_r-ind_l)/2+ind_l;%v5
% figure;
% imshow(I,[]);
% hold on
% % plot([ind_t_x,ind_b_x],[ind_t,ind_b],'Color','r','LineWidth',2);
% % plot([ind_l,ind_r],[ind_l_y,ind_r_y],'Color','r','LineWidth',2);
% plot([ind_t_x,ind_t_x],[ind_t,ind_b],'Color','r','LineWidth',2);%v5
% plot([ind_l,ind_r],[ind_l_y,ind_l_y],'Color','r','LineWidth',2);%v5
% text(ind_t_x-50,ind_t+20,...%HW:50 pxls to left
%     [num2str(distance_real_vert) '\rightarrow'],...%use 'normalized' to scale
%     'Color','r','FontUnits','normalized');      %letter to image
% text(ind_t_x+20,ind_l_y-20,...%HW:20 pxls up
%     ['\downarrow' num2str(distance_real_hori)],...%use 'normalized' to scale
%     'Color','r','FontUnits','normalized');     %letter to image
% hold off
% disp('The displayed line only extends to the pixel centre.');
% if exist('save_path','var')
%     if strcmp(img_type,'T1')
%         saveas(gcf,[save_path 'Test1_S1_T1.png']);
%     elseif strcmp(img_type,'T2')
%         saveas(gcf,[save_path 'Test1_S1_T2.png']);
%     end
%     disp('The result image has been saved to the following path:');
%     disp(save_path);
% end
%4.find phantom centre and phantom bndry
pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');
[cen_pxl,phant_a_y,phant_p_y,phant_l_x,phant_r_x,pill_cen]=...
    fun_FindPhantCen(I,I_bin,pxl_sz,pill_choice,pill_r,6);%HWv9
%5.calc phantom diameter in mm
distance_hori_mm=abs(phant_l_x-phant_r_x)*pxl_sz(1);
distance_vert_mm=abs(phant_a_y-phant_p_y)*pxl_sz(1);
%6.draw on image
figure;
imshow(I,[],'InitialMagnification',200);
hold on
if pill_choice==1
    plot(pill_cen(1),pill_cen(2),'+r');hold on;
end
plot([cen_pxl(1),cen_pxl(1)],[phant_a_y,phant_p_y],'Color','r','LineWidth',2);
plot([phant_l_x,phant_r_x],[cen_pxl(2),cen_pxl(2)],'Color','r','LineWidth',2);
text(cen_pxl(1)-80,phant_a_y+20,...%HW:50 pxls to left
    [num2str(distance_vert_mm) '\rightarrow'],...%use 'normalized' to scale
    'Color','r','FontUnits','normalized');      %letter to image
text(phant_l_x+20,cen_pxl(2)-20,...%HW:20 pxls up
    ['\downarrow' num2str(distance_hori_mm)],...%use 'normalized' to scale
    'Color','r','FontUnits','normalized');     %letter to image
hold off
disp('The displayed line only extends to the pixel centre.');
if exist('save_path','var')
    if strcmp(img_type,'T1')
        saveas(gcf,[save_path 'Test1_S1_T1.png']);
    elseif strcmp(img_type,'T2')
        saveas(gcf,[save_path 'Test1_S1_T2.png']);
    end
    disp('The result image has been saved to the following path:');
    disp(save_path);
end
%======================v8 end======================
%8.pass/fail handle
if distance_vert_mm>=188 && distance_vert_mm<=192%v4
    pf_hdl(1,1)=1;
else
    pf_hdl(1,1)=0;
end
if distance_hori_mm>=188 && distance_hori_mm<=192%v4
    pf_hdl(1,2)=1;
else
    pf_hdl(1,2)=0;
end
end