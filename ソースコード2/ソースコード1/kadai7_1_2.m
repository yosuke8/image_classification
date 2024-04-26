%-------------課題2、BoFベクトル作成して、非線形SVMで学習、分類-----------------

load('Training.mat');
load('posnum.mat');
load('negnum.mat');
load('codebook.mat');   % 最初にcodebook行列を読み込みます．

% ---------------BOFベクトル作成--------------------------
n = numel(Training);
bof = zeros(n,500);
for j=1:n  % 各画像についての for-loop
    I = rgb2gray(imread(Training{j}));
    p = detectSURFFeatures(I);
    [f, p2] = extractFeatures(I, p);
    for i=1:size(p2,1)  % 各特徴点についての for-loop
        data = f(i, :);     %fはm個の特徴ベクトル,m*n行列で表されてる
        data_rep = repmat(data, 500, 1);
        D = sqrt(sum(((codebook - data_rep).^2)'));
        [Min, index] = min(D);  %最小値のユークリッド距離がMinに、その行番号がindexに入る
% 　　　　一番近いcodebook中のベクトルを探してindexを求める．

        bof(j, index) = bof(j, index) + 1;
    end
end
bof_no_normalize = bof;
bof = bof ./ sum(bof,2); 
% sum(A,2)で行ごとの合計を求めて，それを各行の要素について割ることによっ
% て，各行の合計値を１として正規化する． 


imgnum = posnum + negnum;
cv=5;
accuracy=[]
data_pos = bof(1:posnum,:);
data_neg = bof(posnum+1:posnum+negnum, :);


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
FID = fopen('1_2_correct_img_katu.txt','w');
for i=correct_img_idx
    fprintf(FID,'%s\n',Training{i});
end
fclose(FID);

FID = fopen('1_2_wrong_img_katu.txt','w');
for j=wrong_img_idx
    fprintf(FID,'%s\n',Training{j});
end
fclose(FID);


