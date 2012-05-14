%debug = 0;

%Assumes stip features have been read by process_stip
%and kmeans centres are computed over those features
load read_stip.mat
load kmeans.mat
numOfFidgets = length(features);
numOfClasses = size(numOfFidgetsPerClass,1);

%load hist.mat
%precompute histograms %
 fprintf('Compute all Histograms');
 for person = 1:numOfFidgets, fprintf('.');
     for activity = 1:length(features{person})
         if(~isempty(features{person}{activity}))
             hist{person,activity} =  compute_frequency_histogram( features{person}{activity}, centres );
         end;
     end;
 end; fprintf('\n');
 save hist.mat hist;

person_to_class_map = zeros(numOfFidgets,1);
% precompute map of which person is doing what activity
for person = 1:numOfFidgets
    for activity = 1:length(features{person})
       if(~isempty(features{person}{activity}))
           person_to_class_map(person,1) = activity;
       end
    end
end


                                                                                                                                                  
if(debug ~= 1)                                                                                                                                       
                                                                                                                                                     
%calculate number of fidgets(test and train) per class                                                                                               
num_of_training_fidgets_per_class = zeros(1,numOfClasses);                                                                                           
num_of_test_fidgets_per_class = zeros(1,numOfClasses);                                                                                               
for class=1:numOfClasses                                                                                                                             
    num_of_training_fidgets_per_class(class) = 2*ceil(numOfFidgetsPerClass(class)/2);                                                                
    num_of_test_fidgets_per_class(class) = numOfFidgets - num_of_training_fidgets_per_class(class);
end

%%

                                                                                                                                                  
if(debug ~= 1)                                                                                                                                       
                                                                                                                                                     
%calculate number of fidgets(test and train) per class                                                                                               
num_of_training_fidgets_per_class = zeros(1,numOfClasses);                                                                                           
num_of_test_fidgets_per_class = zeros(1,numOfClasses);                                                                                               
for class=1:numOfClasses                                                                                                                             
    num_of_training_fidgets_per_class(class) = 2*ceil(numOfFidgetsPerClass(class)/2);                                                                
    num_of_test_fidgets_per_class(class) = numOfFidgets - num_of_training_fidgets_per_class(class);
end

%%

%
total_iter=10;
train_subjects = cell(total_iter,numOfClasses);
test_subjects = cell(total_iter,numOfClasses);

for iter=1:total_iter
    for class=1:size(numOfFidgetsPerClass,1)
        train_subjects{iter,class} = zeros(1,num_of_training_fidgets_per_class(class));
        test_subjects{iter,class} = zeros(1,num_of_test_fidgets_per_class(class));
    end
end

%compute 1 Vs All training and test subjects(person num)
for iter =1:total_iter
   for class=1:numOfClasses
       p = randperm(numOfFidgets);
       neg_count = 0;
       curr_count = 0;
       for person = p
          if(curr_count < num_of_training_fidgets_per_class(class))
               if(person_to_class_map(person) == class)
                   curr_count = curr_count + 1;
                   train_subjects{iter,class}(curr_count) = person;
               elseif neg_count < num_of_training_fidgets_per_class(class)/2;
                   neg_count = neg_count + 1;
                   curr_count = curr_count + 1;
                   train_subjects{iter,class}(curr_count) = person;
               end
          else
               break;
          end
       end
       test_subjects{iter,class} = setdiff(p,train_subjects{iter,class});
   end
end

save initialization.mat

end%debug




%% If in debug mode then generate videos for visualization and use smaller test set
if(debug == 1)

%calculate number of fidgets(test and train) per class
num_of_training_fidgets_per_class = zeros(1,numOfClasses);
num_of_test_fidgets_per_class = zeros(1,numOfClasses);
for class=1:numOfClasses
    num_of_training_fidgets_per_class(class) = 2*ceil(numOfFidgetsPerClass(class)/2);
    num_of_test_fidgets_per_class(class) = 2*floor(numOfFidgetsPerClass(class)/2);
end

%%

%
total_iter=10;
train_subjects = cell(total_iter,numOfClasses);
test_subjects = cell(total_iter,numOfClasses);

for iter=1:total_iter
    for class=1:size(numOfFidgetsPerClass,1)
        train_subjects{iter,class} = zeros(1,num_of_training_fidgets_per_class(class));
        test_subjects{iter,class} = zeros(1,num_of_test_fidgets_per_class(class));
    end
end


%compute 1 Vs All training and test subjects(person num)
%For debug mode make test samples equal to train samples
for iter =1:total_iter
   for class=1:numOfClasses
       p = randperm(numOfFidgets);
       pos_count_train = 0;
       neg_count_train = 0;
       curr_count_train = 0;
       neg_count_test = 0;
       curr_count_test = 0;
       for person = p
         % if(curr_count_train < num_of_training_fidgets_per_class(class))
          if(person_to_class_map(person) == class)
             if(pos_count_train <  num_of_training_fidgets_per_class(class)/2)
                   pos_count_train = pos_count_train + 1;
                   curr_count_train = curr_count_train + 1;
                   train_subjects{iter,class}(curr_count_train) = person;
             else
                   curr_count_test = curr_count_test + 1;
                   test_subjects{iter,class}(curr_count_test) = person;
             end
               elseif neg_count_train < num_of_training_fidgets_per_class(class)/2
                   neg_count_train = neg_count_train + 1;
                   curr_count_train = curr_count_train + 1;
                   train_subjects{iter,class}(curr_count_train) = person;
               elseif neg_count_test < num_of_test_fidgets_per_class(class)/2;
                   neg_count_test = neg_count_test + 1;
                   curr_count_test = curr_count_test + 1;
                   test_subjects{iter,class}(curr_count_test) = person;
               end

       end
       %test_subjects{iter,class} = setdiff(p,train_subjects{iter,class});                                                                           
   end                                                                                                                                               
end                                                                                                                                                  
                                                                                                                                                     
save initialization.mat                                                                                                                              
                                                                                                                                                     
end%debug                                                                                                                                            