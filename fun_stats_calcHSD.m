function [q,q_critical,hdl,F]=fun_stats_calcHSD(A,B)
% This function calculates the Tukey's HSD (honestly significant
% difference) test result including the F-test result. The function
% compares two sets of vectors (can be different sizes). 
% A very good online source of Tukey's HSD test is on following websites: 
% http://web.mst.edu/~psyworld/tukeyssteps.htm
% http://faculty.uncfsu.edu/dwallace/lesson%2016.pdf
% Calculate Tukey's HSD:
% 1.Use table method to calculate MS_within as following link:
% http://web.mst.edu/~psyworld/anovaexample.htm
% 2.Use formula to calculate observed q-value
% http://web.mst.edu/~psyworld/tukeysexample.htm
% 3.Compare the observed q-value to the critical q-value from q-table
% NOTE: the calculation method in the pdf file of the 2nd website is the
%       same as the above method but in an opposite direction.
%
% Input:
%   A: a col vector of 1st data
%   B: a col vector of 2nd data
% Output:
%   q: calculated q-value
%   q_critical: critical q-value from q-table (k=2, alpha=0.05)
%   hdl: 1=diff, 0=no diff
%   F: calculated F-value
% Usage: 
%   [q,q_critical,F]=fun_calcHSD(A,B)
% HW: (search for HW)
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 25/10/2013
% History: v.1
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.

%1.check existence of input
if size(A,1)==1
    A=A';
end
if size(B,1)==1
    B=B';
end
%2.define sample number and df
N_tot=size(A,1)+size(B,1);%total sample #
df_among=2-1;%group #-1
df_within=N_tot-2;%total sample #-group #
%3.make a table structure of square sums and mean
tab1={'','A','A2','B','B2';'',A,A.^2,B,B.^2;...
    'sum',sum(A),sum(A.^2),sum(B),sum(B.^2);...
    'sum2',sum(A)^2,'',sum(B)^2,'';...
    'mu',mean(A),'',mean(B),''};
%4.calc mean square and F
sstotal=(tab1{3,3}+tab1{3,5})-(tab1{3,2}+tab1{3,4})^2/N_tot;
ssamong=(tab1{4,2}/size(A,1)+tab1{4,4}/size(B,1))-...
    (tab1{3,2}+tab1{3,4})^2/N_tot;
sswithin=sstotal-ssamong;
MS_among=ssamong/df_among;
MS_within=sswithin/df_within;
F=MS_among/MS_within;
tab2={'','SS','df','MS','F';'sstotal',sstotal,'','','';...
    'ssamong',ssamong,df_among,MS_among,'';...
    'sswithin',sswithin,df_within,MS_within,F};
%5.calc q
q=abs(tab1{5,2}-tab1{5,4})/sqrt(MS_within/size(A,1));
%6.q table (k=2 only,alpha=0.05)
tabq={'n','k=2';...
    5,3.64;...
    6,3.46;...
    7,3.34;...
    8,3.26;...
    9,3.20;...
    10,3.15;...
    11,3.11;...
    12,3.08;...
    13,3.06;...
    14,3.03;...
    15,3.01;...
    16,3.00;...
    17,2.98;...
    18,2.97;...
    19,2.96;...
    20,2.95;...
    24,2.92;...
    30,2.89;...
    40,2.86;...
    60,2.83;...
    120,2.80;...
    'infinity',2.77};
%7.find critical q
for i=2:size(tabq,1)-1
    if isequal(tabq{i,1},N_tot)
        break;
    end
end
q_critical=tabq{i,2};
%8.compare q
if q<q_critical
    disp('There is no significant difference between A & B.');
    disp(['The critical q-value is ' num2str(q_critical) '.']);
    disp(['The observed q is ' num2str(q) '.']);
    hdl=0;
else
    disp('There is a significant difference between A & B.');
    disp(['The critical q-value is ' num2str(q_critical) '.']);
    disp(['The observed q is ' num2str(q) '.']);
    hdl=1;
end
%9.display F-value
disp(['The observed F-value is ' num2str(F) '.']);