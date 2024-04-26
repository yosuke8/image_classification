


% 画像表示
figure;
for i=1:10
    for j=1:10
        img = imread(Test{sorted_idx((i-1)*10 + j)});
        subplot(10, 10, (i-1)*10 + j);
        imshow(img);
    end
end



% fileNames = string(Test{sorted_idx});
% figure;
% montage(fileNames, "Size", [20 20])

% fileFolder = fullfile("MATLAB Drive","最終課題1","imgdir","katudon");
% dirOutput = dir(fullfile(fileFolder,"*0*.jpg"));
% fileNames = string({dirOutput.name})