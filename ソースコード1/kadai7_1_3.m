%--------------課題3,DCNN特徴量抽出して、線形SVMで学習、分類------------

load("Training.mat");
load("posnum.mat");
load("negnum.mat");

dcnnf_list = [];
%---------DCNN特徴量抽出する-------
for i=1:numel(Training)
    % network, 入力画像を準備します．
    net = alexnet;
    img = imread(Training{i});
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



imgnum = posnum + negnum;
cv=5;
idx=[1:imgnum];
accuracy=[]
data_pos = dcnnf_list(1:posnum,:);
data_neg = dcnnf_list(posnum+1:posnum+negnum, :);


% idx番目(idxはcvで割った時の余りがi-1)が評価データ
% それ以外は学習データ
for i=1:cv 
% 作成した特徴量を学習用と分類用に分ける
  train_pos=data_pos(find(mod([1:posnum],cv)~=(i-1)),:);
  eval_pos =data_pos(find(mod([1:posnum],cv)==(i-1)),:);
  train_neg=data_neg(find(mod([posnum+1:posnum+negnum],cv)~=(i-1)),:);
  eval_neg =data_neg(find(mod([posnum+1:posnum+negnum],cv)==(i-1)),:);

  training_data=[train_pos; train_neg];
  eval_data=[eval_pos; eval_neg];

  training_label=[ones(size(train_pos, 1),1); ones(size(train_neg, 1),1)*(-1)];
  eval_label =[ones(size(eval_pos, 1),1); ones(size(eval_neg, 1),1)*(-1)];


%   学習 (学習用のmファイルを作りましょう)
  training_data3=repmat(sqrt(abs(training_data)).*sign(training_data),[1 3]).*[0.8*ones(size(training_data)) 0.6*cos(0.6*log(abs(training_data)+eps)) 0.6*sin(0.6*log(abs(training_data)+eps))];
  model_linear = fitcsvm(training_data3, training_label,'KernelFunction','linear');

% 　分類 (分類用のmファイルを作りましょう)
  eval_data3 = repmat(sqrt(abs(eval_data)).*sign(eval_data),[1 3]).*[0.8*ones(size(eval_data)) 0.6*cos(0.6*log(abs(eval_data)+eps)) 0.6*sin(0.6*log(abs(eval_data)+eps))];
  [predicted_label_linear, score_linear] = predict(model_linear, eval_data3);

%   評価
  ac = numel(find(eval_label == predicted_label_linear)) / numel(eval_label)
  accuracy=[accuracy ac];


% 5回中1回だけ確認用に分類成功画像と失敗画像の添字番号取り出す。
  if (i == 1)
      eval_idx = [];    %テストに用いている画像の全体の中での添字番号
      eval_idx = [find(mod([1:posnum],cv)==(i-1)), find(mod([posnum+1:posnum+negnum],cv)==(i-1)) + posnum];
      correct_list = [];
      wrong_list = [];
      correct_list = find(eval_label == predicted_label_linear);
      wrong_list = find(eval_label ~= predicted_label_linear);
      correct_img_idx = eval_idx(correct_list);         %分類成功している画像の全データの中での添字番号
      wrong_img_idx = eval_idx(wrong_list);             %分類失敗している画像の全データの中での添字番号
  end
end

accuracy
fprintf('accuracy: %f\n',mean(accuracy))


% -------確認用画像保存-----------
FID = fopen('1_3_correct_img_katu.txt','w');
for i=correct_img_idx
    fprintf(FID,'%s\n',Training{i});
end
fclose(FID);

FID = fopen('1_3_wrong_img_katu.txt','w');
for j=wrong_img_idx
    fprintf(FID,'%s\n',Training{j});
end
fclose(FID);


