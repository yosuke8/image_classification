idx = find(eval_label == predicted_label_linear);
FID = fopen('1_1_correct_img_dog.txt','w');

% 
% idx = find(eval_label ~= predicted_label_linear);
% FID = fopen('1_1_wrong_img_dog.txt','w');

for i=idx
    fprintf('%s\n',Training{i});
    fprintf(FID,'%s\n',Training{i});
end



fclose(FID);