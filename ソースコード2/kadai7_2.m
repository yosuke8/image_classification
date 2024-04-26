%----------課題2,DCNN特徴量抽出して、線形SVMで学習、その後scoreごとにソートして出力-----

load("Training2.mat");
load("posnum2.mat");
load("negnum2.mat");
load("Test.mat");

%---------学習用データ作成する-----------------------------
%---------学習用画像のDCNN特徴量抽出する-------
dcnnf_list = [];

for i=1:numel(Training2)
    % network, 入力画像を準備します．
    net = alexnet;
    img = imread(Training2{i});
    reimg = imresize(img,net.Layers(1).InputSize(1:2)); 
    
    % activationsを利用して中間特徴量を取り出します．
    % 4096次元の'fc7'から特徴抽出します．
    dcnnf = activations(net,reimg,'fc7');  
    
    % squeeze関数で，ベクトル化します．
    dcnnf = squeeze(dcnnf);

    % L2ノルムで割って，L2正規化．
    % 最終的な dcnnf を画像特徴量として利用します．
    dcnnf = dcnnf/norm(dcnnf);
    dcnnf_list = [dcnnf_list; dcnnf'];  %dcnnfは4096 * 1行列なので転置する。
end

n = 25;     %課題で設定するn,上位n枚をポジティブ画像として学習する。
data_pos = dcnnf_list(1:n,:);
data_neg = dcnnf_list(posnum2+1:posnum2+negnum2, :);
training_data = [data_pos; data_neg];
training_label = [ones(n, 1); ones(negnum2, 1) * (-1)];



%---------テスト用データ作成する----------------------------------------
%---------テスト用画像のDCNN特徴量抽出する-------
dcnnf_list_test = [];

for i=1:numel(Test)
    net = alexnet;
    img = imread(Test{i});
    reimg = imresize(img,net.Layers(1).InputSize(1:2)); 
    
    % activationsを利用して中間特徴量を取り出します．
    % 4096次元の'fc7'から特徴抽出します．
    dcnnf = activations(net,reimg,'fc7');  
    
    % squeeze関数で，ベクトル化します．
    dcnnf = squeeze(dcnnf);

    % L2ノルムで割って，L2正規化．
    % 最終的な dcnnf を画像特徴量として利用します．
    dcnnf = dcnnf/norm(dcnnf);
    dcnnf_list_test = [dcnnf_list_test; dcnnf'];  %dcnnfは4096 * 1行列なので転置する。
end

eval_data = dcnnf_list_test(:, :);

%   学習
training_data3=repmat(sqrt(abs(training_data)).*sign(training_data),[1 3]).*[0.8*ones(size(training_data)) 0.6*cos(0.6*log(abs(training_data)+eps)) 0.6*sin(0.6*log(abs(training_data)+eps))];
model_linear = fitcsvm(training_data3, training_label,'KernelFunction','linear');

% 　テスト
eval_data3 = repmat(sqrt(abs(eval_data)).*sign(eval_data),[1 3]).*[0.8*ones(size(eval_data)) 0.6*cos(0.6*log(abs(eval_data)+eps)) 0.6*sin(0.6*log(abs(eval_data)+eps))];
[predicted_label, score] = predict(model_linear, eval_data3);

% 降順 ('descent') でソートして，ソートした値とソートインデックスを取得します．
[sorted_score,sorted_idx] = sort(score(:,2),'descend');

% Test{:} に画像ファイル名が入っているとして，
% sorted_idxを使って画像ファイル名，さらに
% sorted_score[i](=score[sorted_idx[i],2])の値を出力します．
for i=1:numel(sorted_idx)
  fprintf('%s %f\n',Test{sorted_idx(i)},sorted_score(i));
end

save("sorted_idx.mat", "sorted_idx");
save("sorted_score.mat", "sorted_score");


