% ------------テスト用画像（ノイズ有り）３００枚のデータ作る--------------

n=0; list={}; posnum = 0; negnum = 0;
  LIST={'tenshinhan_test'};
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
      end
    end
  end
 
% まず，テスト画像リスト（ノイズ有り）を作成します．
List=list(1:n);   
Test={List{:}};

save('Test.mat','Test');

size(Test)