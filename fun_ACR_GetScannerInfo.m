function [institution_name,manuf_name,manuf_model_name,station_name,QA_date]=...
    fun_ACR_GetScannerInfo(dir_name)
% This function reads the relevant DICOM tag from the localiser image. Some
% of the info will be used to target the correct Excel worksheet to save
% the result.
% 
% Input:
%   dir_name: user can provide the localiser dir path (with '\' at the end)
% Output:
%   institution_name: institution name (str)
%   manuf_name: manufacturer name (str)
%   manuf_model_name: manufacturer model name (str)
%   station_name: station name (str)
%   QA_date: QA date (str,YYYYMMDD)
% Usage: 
%   
% HW: (search for HW)
% Naughty Boy: (search for NB)
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v1 (14/07/16)
%          v2 ()(search for v2)
% History: v1 
%          v2 
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.load directory
if ~exist('dir_name','var')||isempty(dir_name)
    dir_name=uigetdir('C:\','Select Image Directory');
    dir_name=[dir_name '\'];
end
%2.find the localiser file under the directory
file_list=dir(dir_name);
file_name=file_list(3).name;
%3.get institution name
institution_name=fun_DICOMInfoAccess...
    ([dir_name file_name],'InstitutionName');
%4.get manufacturer name
manuf_name=fun_DICOMInfoAccess...
    ([dir_name file_name],'Manufacturer');
%5.get manufactuer model name
manuf_model_name=fun_DICOMInfoAccess...
    ([dir_name file_name],'ManufacturerModelName');
%6.get station name
station_name=fun_DICOMInfoAccess...
    ([dir_name file_name],'StationName');
%7.get acquisition date
QA_date=fun_DICOMInfoAccess([dir_name file_name],'StudyDate');
%7.give name if no DCM tag
if isempty(institution_name)
    institution_name='InstitutionName';
end
if isempty(manuf_name)
    manuf_name='ManuName';
end
if isempty(manuf_model_name)
    manuf_model_name='ManuModelName';
end
if isempty(station_name)
    station_name='StationName';
end
%8.remove spaces in string
institution_name=institution_name(find(~isspace(institution_name)));
manuf_name=manuf_name(find(~isspace(manuf_name)));
manuf_model_name=manuf_model_name(find(~isspace(manuf_model_name)));
station_name=station_name(find(~isspace(station_name)));
end