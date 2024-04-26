%-------------カラーヒストグラム作成して線形SVMで学習、分類------------------------
load('Training.mat');
load('posnum.mat');
load('negnum.mat');

% -----------------カラーヒストグラムを作成------------------
% まずポジティブ画像100枚ネガティブ画像100枚についてdatabase作成
database=[];
  for i=1:length(Training)
    X=imread(Training{i});
%    { h にヒストグラムが生成されるとする．
%       }
% 減色
    RED=X(:,:,1); GREEN=X(:,:,2); BLUE=X(:,:,3);
    X64=floor(double(RED)/64) *4*4 + floor(double(GREEN)/64) *4 + floor(double(BLUE)/64);

    X64_vec = reshape(X64, 1, numel(X64));
    h = histc(X64_vec, [0:63]);

    h = h / sum(h);      % 要素の合計が１になるように正規化します．
    database=[database; h];
  end


imgnum = posnum + negnum;
cv=5;
accuracy=[]
data_pos = database(1:posnum,:);
data_neg = database(posnum+1:posnum+negnum, :);

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
FID = fopen('1_1_correct_img_katu.txt','w');
for i=correct_img_idx
    fprintf(FID,'%s\n',Training{i});
end
fclose(FID);

FID = fopen('1_1_wrong_img_katu.txt','w');
for j=wrong_img_idx
    fprintf(FID,'%s\n',Training{j});
end
fclose(FID);

