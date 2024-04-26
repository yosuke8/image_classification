% ------------ポジティブ画像100枚、ネガティブ画像1000枚のデータ作る--------------

n=0; list={}; posnum2 = 0; negnum2 = 0;
  LIST={'/MATLAB Drive/最終課題1/imgdir/tenshinhan' '/MATLAB Drive/bgimg/bgimg'};
%  DIR0='/usr/local/class/object/animal/';  % IEDの場合．
  for i=1:length(LIST)
    DIR=strcat(LIST(i),'/');
    W=dir(DIR{:});

    for j=1:size(W)
      if (strfind(W(j).name,'.jpg'))
        fn=strcat(DIR{:},W(j).name);
	    n=n+1;
        fprintf('[%d] %s\n',n,fn);
	    list=[list(:)' {fn}];
        if (i == 1)
            posnum2 = posnum2 + 1;
        elseif (i == 2)
            negnum2 = negnum2 + 1;
        end

        if(negnum2 == 1000)
            break;
        end
      end
    end
  end
 
% まず，読み込む画像リストを作成します．Positive, Negative別々に作成してから，結合してみましょう
PosList=list(1:posnum2);   
NegList=list(posnum2 + 1: posnum2 + negnum2);
Training2={PosList{:} NegList{:}};


save('Training2.mat','Training2');
save('posnum2.mat', 'posnum2');
save('negnum2.mat', 'negnum2');

size(Training2)