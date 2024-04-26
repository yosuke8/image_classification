% ------------ポジティブ画像100枚、ネガティブ画像100枚のデータ作る--------------

n=0; list={}; posnum = 0; negnum = 0;
%   LIST={'dog' 'elephant'};
  LIST={'katudon' 'tendon'};
  DIR0='/MATLAB Drive/最終課題1/imgdir/';
%  DIR0='/usr/local/class/object/animal/';  % IEDの場合．
  for i=1:length(LIST)
    DIR=strcat(DIR0,LIST(i),'/');
    W=dir(DIR{:});

    for j=1:size(W)
      if (strfind(W(j).name,'.jpg'))
        fn=strcat(DIR{:},W(j).name);
	    n=n+1;
        fprintf('[%d] %s\n',n,fn);
	    list=[list(:)' {fn}];
        if (i == 1)
            posnum = posnum + 1;
        elseif (i == 2)
            negnum = negnum + 1;
        end
      end
    end
  end
 
% まず，読み込む画像リストを作成します．Positive, Negative別々に作成してから，結合してみましょう
PosList=list(1:posnum);   
NegList=list(posnum + 1: posnum + negnum);
Training={PosList{:} NegList{:}};


save('Training.mat','Training');
save('posnum.mat', 'posnum');
save('negnum.mat', 'negnum');

size(Training)