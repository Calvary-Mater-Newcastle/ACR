function fun_ACR_SaveLog(save_path,pf_hdl,TEST_1_loc,TEST_1_S1_hori,...
    TEST_1_S1_vert,TEST_1_S5_hori,TEST_1_S5_vert,TEST_1_S5_ng,...
    TEST_1_S5_pg,TEST_1_S1_hori_T2,TEST_1_S1_vert_T2,TEST_1_S5_hori_T2,...
    TEST_1_S5_vert_T2,TEST_1_S5_ng_T2,TEST_1_S5_pg_T2,TEST_2_S1,...
    TEST_2_S1_T2,TEST_3_S1,TEST_3_S1_T2,TEST_4_S1,TEST_4_S11,TEST_4_S1_T2,...
    TEST_4_S11_T2,TEST_5_S7,TEST_5_S7_T2,TEST_6_S7,TEST_6_S7_T2,TEST_7_S11,...
    TEST_7_S10,TEST_7_S9,TEST_7_S8,TEST_7_S11_T2,TEST_7_S10_T2,...
    TEST_7_S9_T2,TEST_7_S8_T2,t_loc,t_T1,t_T2,t_log)
% This function creates log of QA result to the designated path.
%
% Input:
%   ALL THE QA TEST RESULTS
% Output:
%   
% Usage: 
%   
% HW: (search for HW)
%   
% Author: Jidi Sun
% Email: jidi.sun@uon.edu.au
% Version: v.1 (01/05/14)
%          v.2 ()(search for v2)
% History: v.1
%          v.2 
% Copyright: please see license.txt
% Acknowledgement: My study is funded by the Cancer Council NSW, Australia,
%                  project grant RG11-05. PhD under the University of 
%                  Newcastle and the Calvary Mater Newcastle Hospital 
%                  provides me the office and the MR scanner to work with.
fileID=fopen([save_path 'log.txt'],'w');
fprintf(fileID,' Test  |  Image | Value | Criteria| P/F\n');
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,1)==1
    fprintf(fileID,'Test 1 |   Loc  | %5.1f | 146-150 | Pass\n',TEST_1_loc);
else
    fprintf(fileID,'Test 1 |   Loc  | %5.1f | 146-150 | Fail\n',TEST_1_loc);
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,2)==1
    fprintf(fileID,'       |   T1   | %5.1f | 188-192 | Pass\n',mean([TEST_1_S1_hori,TEST_1_S1_vert,TEST_1_S5_hori,TEST_1_S5_vert,TEST_1_S5_ng,TEST_1_S5_pg]));
else
    fprintf(fileID,'       |   T1   | %5.1f | 188-192 | Fail\n',mean([TEST_1_S1_hori,TEST_1_S1_vert,TEST_1_S5_hori,TEST_1_S5_vert,TEST_1_S5_ng,TEST_1_S5_pg]));
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,3)==1
    fprintf(fileID,'       |   T2   | %5.1f | 188-192 | Pass\n',mean([TEST_1_S1_hori_T2,TEST_1_S1_vert_T2,TEST_1_S5_hori_T2,TEST_1_S5_vert_T2,TEST_1_S5_ng_T2,TEST_1_S5_pg_T2]));
else
    fprintf(fileID,'       |   T2   | %5.1f | 188-192 | Fail\n',mean([TEST_1_S1_hori_T2,TEST_1_S1_vert_T2,TEST_1_S5_hori_T2,TEST_1_S5_vert_T2,TEST_1_S5_ng_T2,TEST_1_S5_pg_T2]));
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,4)==1
    fprintf(fileID,'Test 2 |  T1 UL |%5.1f  |  <=1.0  | Pass\n',TEST_2_S1(1,1));
else
    fprintf(fileID,'Test 2 |  T1 UL |%5.1f  |  <=1.0  | Fail\n',TEST_2_S1(1,1));
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,5)==1
    fprintf(fileID,'       |  T1 LR |%5.1f  |  <=1.0  | Pass\n',TEST_2_S1(2,1));
else
    fprintf(fileID,'       |  T1 LR |%5.1f  |  <=1.0  | Fail\n',TEST_2_S1(2,1));
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,6)==1
    fprintf(fileID,'       |  T2 UL |%5.1f  |  <=1.0  | Pass\n',TEST_2_S1_T2(1,1));
else
    fprintf(fileID,'       |  T2 UL |%5.1f  |  <=1.0  | Fail\n',TEST_2_S1_T2(1,1));
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,7)==1
    fprintf(fileID,'       |  T2 LR |%5.1f  |  <=1.0  | Pass\n',TEST_2_S1_T2(2,1));
else
    fprintf(fileID,'       |  T2 LR |%5.1f  |  <=1.0  | Fail\n',TEST_2_S1_T2(2,1));
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,8)==1
    fprintf(fileID,'Test 3 |   T1   |%5.1f  | 5+/-0.7 | Pass\n',TEST_3_S1);
else
    fprintf(fileID,'Test 3 |   T1   |%5.1f  | 5+/-0.7 | Fail\n',TEST_3_S1);
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,9)==1
    fprintf(fileID,'       |   T2   |%5.1f  | 5+/-0.7 | Pass\n',TEST_3_S1_T2);
else
    fprintf(fileID,'       |   T2   |%5.1f  | 5+/-0.7 | Fail\n',TEST_3_S1_T2);
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,10)==1
    fprintf(fileID,'Test 4 |  T1 S1 |%5.1f  | -5<x<5  | Pass\n',TEST_4_S1);
else
    fprintf(fileID,'Test 4 |  T1 S1 |%5.1f  | -5<x<5  | Fail\n',TEST_4_S1);
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,11)==1
    fprintf(fileID,'       | T1 S11 |%5.1f  | -5<x<5  | Pass\n',TEST_4_S11);
else
    fprintf(fileID,'       | T1 S11 |%5.1f  | -5<x<5  | Fail\n',TEST_4_S11);
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,12)==1
    fprintf(fileID,'       |  T2 S1 |%5.1f  | -5<x<5  | Pass\n',TEST_4_S1_T2);
else
    fprintf(fileID,'       |  T2 S1 |%5.1f  | -5<x<5  | Fail\n',TEST_4_S1_T2);
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,13)==1
    fprintf(fileID,'       | T2 S11 |%5.1f  | -5<x<5  | Pass\n',TEST_4_S11_T2);
else
    fprintf(fileID,'       | T2 S11 |%5.1f  | -5<x<5  | Fail\n',TEST_4_S11_T2);
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,14)==1
    fprintf(fileID,'Test 5 |  T1 S7 |%5.1f%% |  >=82%%  | Pass\n',TEST_5_S7*100);
else
    fprintf(fileID,'Test 5 |  T1 S7 |%5.1f%% |  >=82%%  | Fail\n',TEST_5_S7*100);
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,15)==1
    fprintf(fileID,'       |  T2 S7 |%5.1f%% |  >=82%%  | Pass\n',TEST_5_S7_T2*100);
else
    fprintf(fileID,'       |  T2 S7 |%5.1f%% |  >=82%%  | Fail\n',TEST_5_S7_T2*100);
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,16)==1
    fprintf(fileID,'Test 6 |  T1 S7 |%5.1f  | <=0.025 | Pass\n',TEST_6_S7);
else
    fprintf(fileID,'Test 6 |  T1 S7 |%5.1f  | <=0.025 | Fail\n',TEST_6_S7);
end
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,17)==1
    fprintf(fileID,'       |  T2 S7 |%5.1f  | <=0.025 | Pass\n',TEST_6_S7_T2);
else
    fprintf(fileID,'       |  T2 S7 |%5.1f  | <=0.025 | Fail\n',TEST_6_S7_T2);
end
fprintf(fileID,'--------------------------------------------\n');
fprintf(fileID,'Test 7 | T1 S11 |%5.0f  |    NA   | \n',TEST_7_S11);
fprintf(fileID,'--------------------------------------------\n');
fprintf(fileID,'       | T1 S10 |%5.0f  |    NA   | \n',TEST_7_S10);
fprintf(fileID,'--------------------------------------------\n');
fprintf(fileID,'       |  T1 S9 |%5.0f  |    NA   | \n',TEST_7_S9);
fprintf(fileID,'--------------------------------------------\n');
fprintf(fileID,'       |  T1 S8 |%5.0f  |    NA   | \n',TEST_7_S8);
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,18)==1
    fprintf(fileID,'       |   T1   |%5.0f  |   >=37  | Pass\n',sum([TEST_7_S11,TEST_7_S10,TEST_7_S9,TEST_7_S8]));
else
    fprintf(fileID,'       |   T1   |%5.0f  |   >=37  | Fail\n',sum([TEST_7_S11,TEST_7_S10,TEST_7_S9,TEST_7_S8]));
end
fprintf(fileID,'--------------------------------------------\n');
fprintf(fileID,'       | T2 S11 |%5.0f  |    NA   | \n',TEST_7_S11_T2);
fprintf(fileID,'--------------------------------------------\n');
fprintf(fileID,'       | T2 S10 |%5.0f  |    NA   | \n',TEST_7_S10_T2);
fprintf(fileID,'--------------------------------------------\n');
fprintf(fileID,'       |  T2 S9 |%5.0f  |    NA   | \n',TEST_7_S9_T2);
fprintf(fileID,'--------------------------------------------\n');
fprintf(fileID,'       |  T2 S8 |%5.0f  |    NA   | \n',TEST_7_S8_T2);
fprintf(fileID,'--------------------------------------------\n');
if pf_hdl(1,19)==1
    fprintf(fileID,'       |   T2   |%5.0f  |   >=37  | Pass\n',sum([TEST_7_S11_T2,TEST_7_S10_T2,TEST_7_S9_T2,TEST_7_S8_T2]));
else
    fprintf(fileID,'       |   T2   |%5.0f  |   >=37  | Fail\n',sum([TEST_7_S11_T2,TEST_7_S10_T2,TEST_7_S9_T2,TEST_7_S8_T2]));
end
fprintf(fileID,'--------------------------------------------\n');
fprintf(fileID,'The QA time for Localiser image was: %5.2f sec\n',t_loc);
fprintf(fileID,'The QA time for T1 image was:        %5.2f sec\n',t_T1);
fprintf(fileID,'The QA time for T2 image was:        %5.2f sec\n',t_T2);
fprintf(fileID,'The time for logging was:            %5.2f sec\n',t_log);
fprintf(fileID,'The total time of this QA was:       %5.2f sec\n',sum([t_loc,t_T1,t_T2,t_log]));
fprintf(fileID,'--------------------------------------------\n');
fclose(fileID);
end