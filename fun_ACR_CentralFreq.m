function fun_ACR_CentralFreq(loc_file,Excel_file)
% This function reads the loc DICOM tag to extract the central frequency
% value into a designated Excel sheet for long term recording.
% This is a quick fix before I have time to include the central frequency
% into the QA result Excel sheet.
%
% Input:
%   loc_file: localiser file (str)
%   Excel_file: Excel file name (str)
% Output:
%   
% Usage: 
%   
% HW: (search for HW)
%   
% Naughty Boy: (search for NB)
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v1 (16/07/16)
%          v2 ()(search for v2)
% History: v1
%          v2 
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.read central frequency and date
AcqDate=fun_DICOMInfoAccess(loc_file,'StudyDate');
CenFreq=fun_DICOMInfoAccess(loc_file,'ImagingFrequency');
if isempty(CenFreq)
    CenFreq=0;
    disp('Central frequency is not included in DICOM tag.');
end
%2.update Excel file
if ~exist(Excel_file)
    disp('Central frequency Excel file NOT exists, create one now.');
    xlswrite(Excel_file,{'Date','Freq'})
end
[~,~,raw]=xlsread(Excel_file);
%2.define the new row index
new_row_ind=size(raw,1)+1;
%3.add new date
res=raw;
res{new_row_ind,1}=AcqDate;
res{new_row_ind,2}=CenFreq;
%4.save new Excel to dir
xlswrite(Excel_file,res);
disp('The central frequency report has been updated under following path: ');
disp(Excel_file);
end