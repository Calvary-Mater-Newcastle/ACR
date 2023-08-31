function [distance_hori_mm,distance_vert_mm,...
    distance_ng_mm,distance_pg_mm,pf_hdl]=fun_ACR_1_S5...
    (dir_name,file_name,visual,imag_check,img_type,save_path,pill_choice,pill_r)
% This function is used for geometric distortion check on S5. Two pairs
% of cross lines are measured, the 1st cross is measured as normal. Before
% measuring the 2nd cross, the image is rotated by 45 degrees and then
% performs the normal mearsurement. 1st cross measurement gives the
% horizontal and vertical diameter of phantom, 2nd cross measurement gives
% the negative and positive gradient diameter of phantom
%
% NOTE: This function uses two methods for the rest of the 1st and 2nd 
% pairs of crosses coordinant finding. For 1st cross, it uses the normal 
% function defined as fun_ACR_FindWaterBndryBinary_RestCoord. For 2nd pair
% cross, it simply sum rotated binary image horizontally and vertically and 
% search for peak. Because this process is only for display purpose, the 
% 2nd method is acceptable.
%
% Input:
%   dir_name: directory path string where image is stored
%   file_name: file name of S5
%   visual: visualisation option, 1=on & 0=off. Showing all graphs and
%           plots for visualisation purpose
%   imag_check: if check the current image is the correct image
%   img_type: image type (string: T1 or T2)
%   save_path: the path to save image
%   pill_choice: with/without attached pill (1=with, 0=without)
%   pill_r: pill radius in mm (num)
% Output:
%   distance_hori_mm: horizontal measurement of phantom
%   distance_vert_mm: vertical measurement of phantom
%   distance_ng_mm: positive gradient measurement of phantom
%   distance_pg_mm: negative gradient measurement of phantom
%   pf_hdl: pass/fail handle
% Usage: 
%   [dist_hori,dist_vert,dist_ng,dist_pg]=fun_ACR_1_S5()
%   [dist_hori,dist_vert,dist_ng,dist_pg]=fun_ACR_1_S5('dir_str','file_str',1or0)
% HW: (search for HW)
%   mask threshold=mu-2*std to cover most water (necessary to cover 95%)
%   sum up row & col band using 30%-60% of central image to avoid missing
%       circle centre because of positioning error
%   result display location on image
%   sometime pg length is off by ~10 pixels when showing on image
%   phantom wall thickness=6 mm
%
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (28/03/13)
%          v.2 (15/05/13)(search for v2)
%          v.3 (21/08/13)(search for v3)
%          v.4 (27/08/13)(search for v4)
%          v.5 (09/01/14)(search for v5)
%          v.6 (11/01/14)(search for v6)
%          v.7 (30/04/14)(search for v7)
%          v.8 (14/07/15)(search for v8)
%          v.9 (30/07/15)(search for v9)
%          v.10 (01/04/17)(search for v10)
% History: v.1
%          v.2 allow user to change the directory and file names depends
%              on where the image is stored. This can be changed at the
%              beginning of this file;
%              also directory and file name strings are 2 new inputs of
%              this function;
%              add visualisation option;
%          v.3 add option if to allow user to check the current image;
%              output pass/fail handle;
%          v.4 replace FINDPEAKS function with MAX function to find the
%              coordinates to display length
%          v.5 simplify the method to find coord for displaying diameter
%              for hori & vert phantom diameter;
%              replace v4 with midpoint of phantom boundaries, because 
%              sometime phantom edge is spiky after rotation and the peak 
%              may not be the central line
%          v.6 replace manual setup of intensity range for water peak
%              intensity calculation with automatic peak estimation
%          v.7 add save_path variable to save measurement image to a
%              designated path
%          v.8 Add choice of with/without attached pill. This is mainly to
%              solve the missing liquid induced AP diameter mis-measurement
%              problem.
%              Instead of rotate image to find diagonal diameter, sample
%              straight from phantom centre in four directions to calc
%              diagonal diameter.
%              Also plot the measurements in one figure.
%          v.9 For diag diameter calc, after 4 direction edges ID check if
%              2 hori/vert adjacent pxl is 1 then add 0.5 to edge. This
%              averages phantom edge.
%          v.10 Add pill radius as input.
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.
%1.check if user has specified dir and file name and visualisation option
if ~exist('dir_name','var')||isempty(dir_name)%v2
    dir_name='test_images\';
end
if ~exist('file_name','var')||isempty(file_name)%v2
    file_name='S5.dcm';
end
if ~exist('visual','var')||isempty(visual)%v2
    visual=0;
end
if ~exist('imag_check','var')||isempty(imag_check)%v5
    imag_check=0;
end
if ~exist('pill_choice','var')%v8
    pill_choice_trig = questdlg('Did you attached a pill marker to anterior phantom on S5?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');
    switch pill_choice_trig%Handle response
        case 'Yes'
            pill_choice=1;
        case 'No'
            pill_choice=0;
    end
end
%2.load and display image to let user check if it is S5
I=dicomread([dir_name file_name]);%v2
if imag_check==1%v3
    h=imtool(I,[]);
    choice = questdlg('Is this image the S5 image?', ...
        'Choose Red or Blue Pill', ...
        'Yes','No','Yes');%Construct a questdlg with two options
    switch choice%Handle response
        case 'Yes'
            path_name=[dir_name file_name];%v2
            %v6 comment out
%             imcontrast(h);%open contrast window
%             prompt = {'Lower Intensity:','Higher Intensity:'};
%             dlg_title = 'Water Intensity Range';
%             num_lines = 1;
%             def = {'1500','3500'};
%             answer = inputdlg(prompt,dlg_title,num_lines,def);
            close(h);%shut window
        case 'No'
            close(h);%shut window
            disp('Manually select localiser image.');%manual selection
            [f_n,p_n]=uigetfile([dir_name '*.dcm']);%v2
            path_name=fullfile(p_n,f_n);
            I=dicomread(path_name);
            h=imtool(I,[]);
            %v6 comment out
%             imcontrast(h);%open contrast window
%             prompt = {'Lower Intensity:','Higher Intensity:'};
%             dlg_title = 'Water Intensity Range';
%             num_lines = 1;
%             def = {'1500','3500'};
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
%     def = {'1500','3500'};
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
if visual==1%v2
    figure;
    imshow(I_bin,[]);
    title('Thresholded S5 Image');
else
    disp(['You have turned off graph visualisation '...
        'to show the thresholded S5 image']);
end
%======================v8 start======================
% %4.sum up a band of row (30%-60% of image size) to get row bndry
% [ind_l,ind_r]=fun_ACR_FindBndryFromBand(I_bin,'row',[0.3 0.6]);
% %5.sum up a band of col (30%-60% of image size) to get col bndry
% [ind_t,ind_b]=fun_ACR_FindBndryFromBand(I_bin,'col',[0.3 0.6]);
% %6.find pixel distance and convert to mm
% distance_col=ind_r-ind_l;
% distance_row=ind_b-ind_t;
% pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');
% distance_real_c=distance_col*pxl_sz(1,1);
% distance_real_hori=round(distance_real_c*10)/10;
% distance_real_r=distance_row*pxl_sz(1,1);
% distance_real_vert=round(distance_real_r*10)/10;
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
%     [num2str(distance_real_vert) '\rightarrow'],...%use 'normalized' to
%     'Color','r','FontUnits','normalized');         %scale letter to image
% text(ind_t_x+20,ind_l_y-10,...%HW:20 pxls up
%     ['\downarrow' num2str(distance_real_hori)],...%use 'normalized' to
%     'Color','r','FontUnits','normalized');        %scale letter to image
% if exist('save_path','var')
%     if strcmp(img_type,'T1')
%         saveas(gcf,[save_path 'Test1_S5_T1(1).png']);
%     elseif strcmp(img_type,'T2')
%         saveas(gcf,[save_path 'Test1_S5_T2(1).png']);
%     end
%     disp('The result image has been saved to the following path:');
%     disp(save_path);
% end
% %8.rotate binary image by 45 degrees
% I_bin_r=imrotate(I_bin,45);
% %9.sum up a band of row (30%-60% of image size) to get row bndry for
% %  negative gradient length
% [ind_l_r,ind_r_r]=fun_ACR_FindBndryFromBand(I_bin_r,'row',[0.3 0.6]);
% %10.sum up a band of col (30%-60% of image size) to get col bndry for
% %  positive gradient length
% [ind_t_r,ind_b_r]=fun_ACR_FindBndryFromBand(I_bin_r,'col',[0.3 0.6]);
% %10.find pixel distance and convert to mm
% distance_col_r=ind_r_r-ind_l_r;
% distance_row_r=ind_b_r-ind_t_r;
% distance_real_ng=distance_col_r*pxl_sz(2,1);
% distance_real_ng=round(distance_real_ng*10)/10;
% distance_real_pg=distance_row_r*pxl_sz(2,1);
% distance_real_pg=round(distance_real_pg*10)/10;
% %11.fast way to get other coord of bndry for display purpose only
% % sum_h=sum(I_bin_r,1);%sum image horizontally
% % [~,ind_tb_r]=findpeaks(sum_h,'SORTSTR','ascend');
% % ind_tb_r=ind_tb_r(end);%peak is the last element
% % sum_v=sum(I_bin_r,2);%sum image vertically
% % [~,ind_lr_r]=findpeaks(sum_v,'SORTSTR','ascend');
% % ind_lr_r=ind_lr_r(end);%peak is the last element
% % [~,ind_tb_r]=max(sum_h);%v4
% % ind_tb_r=ind_tb_r+10;%HW:sometimes off by 10 pixels,need improve%v4
% % [~,ind_lr_r]=max(sum_v);%v4
% % ind_tb_r=(find(sum_h,1,'last')-find(sum_h,1,'first'))/2+...
% %     find(sum_h,1,'first');%v5
% % ind_lr_r=(find(sum_v,1,'last')-find(sum_v,1,'first'))/2+...
% %     find(sum_v,1,'first');%v5
% ind_lr_r=(ind_b_r-ind_t_r)/2+ind_t_r;%v5
% ind_tb_r=(ind_r_r-ind_l_r)/2+ind_l_r;%v5
% figure;
% imshow(imrotate(I,45),[]);
% hold on
% plot([ind_tb_r,ind_tb_r],[ind_t_r,ind_b_r],'Color','r','LineWidth',2);
% plot([ind_l_r,ind_r_r],[ind_lr_r,ind_lr_r],'Color','r','LineWidth',2);
% text(ind_lr_r-50,ind_t_r+20,...%HW:50 pxls to left
%     [num2str(distance_real_ng) '\rightarrow'],...%use 'normalized' to
%     'Color','r','FontUnits','normalized');       %scale letter to image
% text(ind_lr_r+20,ind_tb_r-10,...%HW:20 pxls up
%     ['\downarrow' num2str(distance_real_pg)],...%use 'normalized' to scale
%     'Color','r','FontUnits','normalized');      %letter to image
% disp('The displayed line only extends to the pixel centre.');
% if exist('save_path','var')
%     if strcmp(img_type,'T1')
%         saveas(gcf,[save_path 'Test1_S5_T1(2).png']);
%     elseif strcmp(img_type,'T2')
%         saveas(gcf,[save_path 'Test1_S5_T2(2).png']);
%     end
%     disp('The result image has been saved to the following path:');
%     disp(save_path);
% end
%4.find phantom centre and phantom bndry
pxl_sz=fun_DICOMInfoAccess(path_name,'PixelSpacing');
[cen_pxl,phant_a_y,phant_p_y,phant_l_x,phant_r_x,pill_cen]=...
    fun_FindPhantCen(I,I_bin,pxl_sz,pill_choice,pill_r,6);%HWv10
%5.calc phantom hori&vert diameter in mm
distance_hori_mm=abs(phant_l_x-phant_r_x)*pxl_sz(1);
distance_vert_mm=abs(phant_a_y-phant_p_y)*pxl_sz(1);
%6.calc phantom diag diameter in mm
% ln_vec_ng=fun_ACR_DiagProfSamp(size(I,2),size(I,1),round(cen_pxl),-1);%DON'T ASK, IT WORKS.
% ln_vec_pg(2,:)=size(I,1)-ln_vec_ng(2,:)+2*(diff(round(cen_pxl)));%DON'T ASK, IT WORKS.
% ln_vec_pg(1,:)=1:size(ln_vec_pg,2);

% I_bin_r=imrotate(I_bin,45);
% [~,phant_a_y,phant_p_y,phant_l_x,phant_r_x,~]=...
%     fun_FindPhantCen(I,I_bin_r,pxl_sz,pill_choice,4,6);%HW
% distance_ng_mm=abs(phant_l_x-phant_r_x)*pxl_sz(1);
% distance_pg_mm=abs(phant_a_y-phant_p_y)*pxl_sz(1);

cnt=1;
% figure;imshow(I_bin,[]);hold on;
for a=1:size(I,2)-round(cen_pxl(1))
    if round(cen_pxl(2)-a)>0 && round(cen_pxl(1)+a)<size(I,2)
%         plot(round(cen_pxl(1)+a),round(cen_pxl(2)-a),'+r');hold on;
        dummy(cnt,1)=I_bin(round(cen_pxl(2)-a),round(cen_pxl(1)+a));
        cnt=cnt+1;
    else
%         hold off;
        break;
    end
end
NE_inc=find(dummy,1,'last');%northeast increment
%======================v9 start======================
if I_bin(round(cen_pxl(2)-NE_inc-1),round(cen_pxl(1)+NE_inc))>0 && ...%superior pxl
        I_bin(round(cen_pxl(2)-NE_inc),round(cen_pxl(1)+NE_inc+1))>0%right pxl
    NE_inc=NE_inc+0.5;
end
%======================v9 start======================
cnt=1;
% figure;imshow(I_bin,[]);hold on;
for a=1:size(I,2)-round(cen_pxl(1))
    if round(cen_pxl(2)+a)<size(I,1) && round(cen_pxl(1)-a)>0
%         plot(round(cen_pxl(1)-a),round(cen_pxl(2)+a),'+r');hold on;
        dummy(cnt,1)=I_bin(round(cen_pxl(2)+a),round(cen_pxl(1)-a));
        cnt=cnt+1;
    else
%         hold off;
        break;
    end
end
SW_inc=find(dummy,1,'last');%northeast increment
%======================v9 start======================
if I_bin(round(cen_pxl(2)+SW_inc+1),round(cen_pxl(1)-SW_inc))>0 && ...%posterior pxl
        I_bin(round(cen_pxl(2)+SW_inc),round(cen_pxl(1)-SW_inc-1))>0%left pxl
    SW_inc=SW_inc+0.5;
end
%======================v9 start======================
cnt=1;
% figure;imshow(I_bin,[]);hold on;
for a=1:size(I,2)-round(cen_pxl(1))
    if round(cen_pxl(2)-a)>0 && round(cen_pxl(1)-a)>0
%         plot(round(cen_pxl(1)-a),round(cen_pxl(2)-a),'+r');hold on;
        dummy(cnt,1)=I_bin(round(cen_pxl(2)-a),round(cen_pxl(1)-a));
        cnt=cnt+1;
    else
%         hold off;
        break;
    end
end
NW_inc=find(dummy,1,'last');%northeast increment
%======================v9 start======================
if I_bin(round(cen_pxl(2)-NW_inc-1),round(cen_pxl(1)-NW_inc))>0 && ...%superior pxl
        I_bin(round(cen_pxl(2)-NW_inc),round(cen_pxl(1)-NW_inc-1))>0%left pxl
    NW_inc=NW_inc+0.5;
end
%======================v9 start======================
cnt=1;
% figure;imshow(I_bin,[]);hold on;
for a=1:size(I,2)-round(cen_pxl(1))
    if round(cen_pxl(2)+a)<size(I,1) && round(cen_pxl(1)+a)<size(I,2)
%         plot(round(cen_pxl(1)+a),round(cen_pxl(2)+a),'+r');hold on;
        dummy(cnt,1)=I_bin(round(cen_pxl(2)+a),round(cen_pxl(1)+a));
        cnt=cnt+1;
    else
%         hold off;
        break;
    end
end
SE_inc=find(dummy,1,'last');%northeast increment
%======================v9 start======================
if I_bin(round(cen_pxl(2)+SE_inc+1),round(cen_pxl(1)+SE_inc))>0 && ...%posterior pxl
        I_bin(round(cen_pxl(2)+SE_inc),round(cen_pxl(1)+SE_inc+1))>0%right pxl
    SE_inc=SE_inc+0.5;
end
%======================v9 start======================
distance_ng_mm=(NW_inc+SE_inc+1)*sqrt(2)*pxl_sz(1);%+1 to include central pxl
distance_pg_mm=(NE_inc+SW_inc+1)*sqrt(2)*pxl_sz(1);%+1 to include central pxl
%6.draw on image
figure('Position',[100,100,1049,895]);
imshow(I,[],'InitialMagnification',200);
hold on
if pill_choice==1
    plot(pill_cen(1),pill_cen(2),'+r');hold on;
end
plot([cen_pxl(1),cen_pxl(1)],[phant_a_y,phant_p_y],'Color','r','LineWidth',2);
plot([phant_l_x,phant_r_x],[cen_pxl(2),cen_pxl(2)],'Color','r','LineWidth',2);
text(cen_pxl(1)-60,phant_a_y+20,...%HW:50 pxls to left
    [num2str(distance_vert_mm) '\rightarrow'],...%use 'normalized' to scale
    'Color','r','FontUnits','normalized');      %letter to image
text(phant_l_x+20,cen_pxl(2)-20,...%HW:20 pxls up
    ['\downarrow' num2str(distance_hori_mm)],...%use 'normalized' to scale
    'Color','r','FontUnits','normalized');     %letter to image
plot([floor(cen_pxl(1)-NW_inc),round(cen_pxl(1)+SE_inc)],[floor(cen_pxl(2)-NW_inc),round(cen_pxl(2)+SE_inc)],'Color','r','LineWidth',2);
plot([floor(cen_pxl(1)-SW_inc),round(cen_pxl(1)+NE_inc)],[floor(cen_pxl(2)+SW_inc),round(cen_pxl(2)-NE_inc)],'Color','r','LineWidth',2);
text(cen_pxl(1)+SE_inc-60,cen_pxl(2)+SE_inc,...%HW:50 pxls to left
    [num2str(distance_ng_mm) '\uparrow'],...%use 'normalized' to scale
    'Color','r','FontUnits','normalized');      %letter to image
text(cen_pxl(1)-SW_inc,cen_pxl(2)+SW_inc,...%HW:20 pxls up
    ['\uparrow' num2str(distance_pg_mm)],...%use 'normalized' to scale
    'Color','r','FontUnits','normalized');     %letter to image
hold off
disp('The displayed line only extends to the pixel centre.');
if exist('save_path','var')
    if strcmp(img_type,'T1')
        saveas(gcf,[save_path 'Test1_S5_T1.png']);
    elseif strcmp(img_type,'T2')
        saveas(gcf,[save_path 'Test1_S5_T2.png']);
    end
    disp('The result image has been saved to the following path:');
    disp(save_path);
end
%======================v8 end======================
%12.pass/fail handle
if distance_vert_mm>=188 && distance_vert_mm<=192%v3
    pf_hdl(1,1)=1;
else
    pf_hdl(1,1)=0;
end
if distance_hori_mm>=188 && distance_hori_mm<=192%v3
    pf_hdl(1,2)=1;
else
    pf_hdl(1,2)=0;
end
if distance_ng_mm>=188 && distance_ng_mm<=192%v3
    pf_hdl(1,3)=1;
else
    pf_hdl(1,3)=0;
end
if distance_pg_mm>=188 && distance_pg_mm<=192%v3
    pf_hdl(1,4)=1;
else
    pf_hdl(1,4)=0;
end
end