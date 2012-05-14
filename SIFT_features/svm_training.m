%for once and for all) and initialization(it has to be called again for debug
%mode) were run in debug mode
load initialization.mat
%% Initialize traindata-labels and testdata-labels
total_train_classes = 0;
traindata_arr = cell(total_iter,numOfClasses); trainlabels_arr = cell(total_iter,numOfClasses);
testdata_arr = cell(total_iter,numOfClasses); testlabels_arr = cell(total_iter,numOfClasses);

%Initialize traindata and testdata, training_subjects and test_subjects
for iter=1:total_iter
    for class=1:size(numOfFidgetsPerClass,1)
        traindata_arr{iter,class} = zeros(num_of_training_fidgets_per_class(class),4000);
        testdata_arr{iter,class} = zeros(num_of_test_fidgets_per_class(class),4000);
        trainlabels_arr{iter,class} = zeros(num_of_training_fidgets_per_class(class),2);
        testlabels_arr{iter,class} = zeros(num_of_test_fidgets_per_class(class),2);
    end
end
for iter = 1:total_iter
   tic;fprintf('Iteration %d\n',iter);
   num_of_fidgets_covered_for_each_class = zeros(1,numOfClasses);
   fprintf('Generating Training data ');
   for class=1:numOfClasses,fprintf('.')
       if(numOfFidgetsPerClass(class) >= 10)
            for person = train_subjects{iter,class}
              activity = person_to_class_map(person);
              if(activity == class)
                num_of_fidgets_covered_for_each_class(class) = num_of_fidgets_covered_for_each_class(class) + 1;
traindata_arr{iter,class}(num_of_fidgets_covered_for_each_class(class),:) = hist{person,activity};
                trainlabels_arr{iter,class}(num_of_fidgets_covered_for_each_class(class),:) = [person 1];
              %Make sure both classes have equal data for training
              else
                num_of_fidgets_covered_for_each_class(class) = num_of_fidgets_covered_for_each_class(class) + 1;
traindata_arr{iter,class}(num_of_fidgets_covered_for_each_class(class),:) = hist{person,activity};
                trainlabels_arr{iter,class}(num_of_fidgets_covered_for_each_class(class),:) = [person -1];
              end
            end
       end
   end
   %save train.mat traindata_arr trainlabels_arr ;
   fprintf('\nGenerating Test data ');
   num_of_fidgets_covered_for_each_class = zeros(1,numOfClasses);
   for class=1:numOfClasses, fprintf('.')
      for person = test_subjects{iter,class}
           activity = person_to_class_map(person);
           if(activity == class)
                num_of_fidgets_covered_for_each_class(class) = num_of_fidgets_covered_for_each_class(class) + 1;
testdata_arr{iter,class}(num_of_fidgets_covered_for_each_class(class),:) = hist{person,activity};
                testlabels_arr{iter,class}(num_of_fidgets_covered_for_each_class(class),:) = [person 1];
           else
                num_of_fidgets_covered_for_each_class(class) = num_of_fidgets_covered_for_each_class(class) + 1;
testdata_arr{iter,class}(num_of_fidgets_covered_for_each_class(class),:) = hist{person,activity};
                testlabels_arr{iter,class}(num_of_fidgets_covered_for_each_class(class),:) = [person -1];
           end
      end
   end
   fprintf('\nTraining and Test data generated for all classes\n');toc
end
%TODO save training_data and labels seperatelyfor model generation, it will be
%faster to load it than testdata_Arr
%save train_test.mat -v7.3 traindata_arr trainlabels_arr testdata_arr testlabels_arr ;


%%
%clear features;
%load train_test.mat
fprintf('Data & label generation for SVM:Done and saved \n');
fprintf('Running SVM\n');

%model = cell(total_iter, 11);

for iter = 1:total_iter
    fprintf('Iter = %d\n',iter);
    for class=1:size(numOfFidgetsPerClass,1)
        if(numOfFidgetsPerClass(class)>=10)
            fprintf('Class %d\n',class);
            traindata = traindata_arr{iter,class};
            testdata = testdata_arr{iter,class};
            trainlabels = trainlabels_arr{iter,class};
            testlabels = testlabels_arr{iter,class};
            classify_bag;
            %model{iter,class} = model_precomputed;
predict_label{iter,class} = predict_label_P;
accuracy{iter,class} = accuracy_P;
            %dec_values stores the confidence for each class
predicted_values{iter,class}= dec_values_P;
	end
    end
end
%save svm_models.mat model;
save svm_results.mat predict_label accuracy predicted_values;

%CM;                                                                                                                                                 


