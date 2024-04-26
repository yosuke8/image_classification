%-------------コードブック作成する-----------------

load('Training.mat');
% 次に forループで，全画像についてSURF特徴を抽出します．
Features=[];
for i=1:numel(Training)
  I=rgb2gray(imread(Training{i}));
  p=detectSURFFeatures(I);
  [f,p2]=extractFeatures(I,p);
  Features=[Features; f];
end

[numRows, numCols] = size(Features);
if numRows > 50000
    Features=Features(randperm(size(Features,1),50000),:);
end

k = 500;
[idx, codebook] = kmeans(Features, k);

save('codebook.mat','codebook');

size(codebook)