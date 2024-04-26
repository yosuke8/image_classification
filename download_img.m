list = textread('url_tenshinhan_for_test.txt', '%s');

OUTDIR='imgdir/tenshinhan_test';
mkdir(OUTDIR);
for i=1:size(list,1)
  fname=strcat(OUTDIR,'/',num2str(i,'%04d'),'.jpg')
  websave(fname,list{i});
end