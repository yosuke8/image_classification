load("Test.mat");
load("sorted_idx.mat");
load("sorted_score.mat");

FID = fopen('2_n25_img.txt','w');

for i=1:numel(sorted_idx)
  fprintf(FID, '%s %.5f\n',Test{sorted_idx(i)},sorted_score(i));
end

fclose(FID);