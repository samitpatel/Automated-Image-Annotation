dirToSave = '../data/';
fid = fopen([dirToSave 'featureSet.txt'],'w');
fprintf(fid, repmat([repmat('%d ',[1 size(featureSet,2)]) '\n' ],[1 size(featureSet,1)]), featureSet);
fclose(fid);

fid = fopen([dirToSave 'labelSet.txt'],'w');
fprintf(fid, repmat([repmat('%d ',[1 size(labelSet,2)]) '\n' ],[1 size(labelSet,1)]), labelSet);            
fclose(fid);

fid = fopen([dirToSave 'reverseMap.txt'],'w');
fprintf(fid, repmat([repmat('%d ',[1 size(reverseMap,2)]) '\n' ],[1 size(reverseMap,1)]), reverseMap);
fclose(fid);
