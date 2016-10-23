function D = C4_5(train_features, train_targets, inc_node,test_features)


[Ni, M]		= size(train_features); %��������ΪNI*M�ľ�������M��ʾѵ������������NiΪ����ά��ά��
inc_node    = inc_node*M/100; 

disp('Building tree') 
tree        = make_tree(train_features, train_targets, inc_node); 
 
%Make the decision region according to the tree %���ݲ�����������������
disp('Building decision surface using the tree') 
[n,m]=size(test_features);
targets		= use_tree(test_features, 1:m, tree, unique(train_targets)); %target������˶�Ӧ�Ĳ��������������õ������
 
D   		= targets; 
%END 
 
function targets = use_tree(features, indices, tree,  Uc) %target������˶�Ӧ�Ĳ��������������õ����
 

targets = zeros(1, size(features,2)); %1*M������
 
if (tree.dim == 0) 
   %Reached the end of the tree 
   targets(indices) = tree.child; 
   return %child��������������Ϣ��indeces�����˲��������е�ǰ���Ե���������
end 
         

dim = tree.dim; %��ǰ�ڵ����������
dims= 1:size(features,1); %dimsΪ1-����ά��������
 
   %Discrete feature 
   in				= indices(find(features(dim, indices) <= tree.split_loc)); %inΪ��������ԭ�����index

   targets		= targets + use_tree(features(dims, :), in, tree.child_1, Uc); 
   in				= indices(find(features(dim, indices) >  tree.split_loc)); 

   targets		= targets + use_tree(features(dims, :), in, tree.child_2, Uc); 
return 
      
 
function tree = make_tree(features, targets, inc_node) 

[Ni, L]    					= size(features); 
Uc         					= unique(targets); %UC��ʾ�����
tree.dim						= 0; %����ά��Ϊ0
%tree.child(1:maxNbin)	= zeros(1,maxNbin); 
 
if isempty(features), %�������Ϊ�գ��˳�
   return 
end 

%When to stop: If the dimension is one or the number of examples is small 
if ((inc_node > L) | (L == 1) | (length(Uc) == 1)), %ʣ��ѵ����ֻʣһ������̫С��С��inc_node����ֻʣһ�࣬�˳�
   H					= hist(targets, length(Uc)); %�����������ֱ��ͼ
   [m, largest] 	= max(H); %�����һ�࣬mΪ���ֵ����������largestΪλ�ã�������λ��
   tree.child	 	= Uc(largest); %ֱ�ӷ������и����һ����Ϊ�����
   return
end 
 
%Compute the node's I 
%�������е���Ϣ��
for i = 1:length(Uc), 
    Pnode(i) = length(find(targets == Uc(i))) / L; 
end 
Inode = -sum(Pnode.*log(Pnode)/log(2)); 
 
%For each dimension, compute the gain ratio impurity 
%This is done separately for discrete and continuous features 
delta_Ib    = zeros(1, Ni); 
S=[];
for i = 1:Ni, 
   data	= features(i,:); 
   temp=unique(data); 
      P	= zeros(length(Uc), 2); 
       
      %Sort the features 
      [sorted_data, indices] = sort(data); 
      sorted_targets = targets(indices); 
       %���Ϊ���������������
      %Calculate the information for each possible split 
      I	= zeros(1, L-1); 
      
      for j = 1:L-1, 
         for k =1:length(Uc), 
            P(k,1) = length(find(sorted_targets(1:j) 		== Uc(k))); 
            P(k,2) = length(find(sorted_targets(j+1:end) == Uc(k))); 
         end 
         Ps		= sum(P)/L; %����������Ȩ�� 
         temp1=[P(:,1)]; 
         temp2=[P(:,2)]; 
         fo=[Info(temp1),Info(temp2)];
         %info	= sum(-P.*log(eps+P)/log(2)); %����������I
         I(j)	= Inode - sum(fo.*Ps);    
      end 
      [delta_Ib(i), s] = max(I); 
      S=[S,s];
   
end
 
%Find the dimension minimizing delta_Ib  
%�ҵ����Ļ��ַ���
[m, dim] = max(delta_Ib); 

dims		= 1:Ni; 
tree.dim = dim; 

%Split along the 'dim' dimension 
%������ 
   %Continuous feature 
   [sorted_data, indices] = sort(features(dim,:)); 
   %tree.split_loc		= split_loc(dim); 
   %disp(tree.split_loc);
   S(dim)
   indices1=indices(1:S(dim))
   indices2=indices(S(dim)+1:end)
   tree.split_loc=sorted_data(S(dim))
   tree.child_1		= make_tree(features(dims, indices1), targets(indices1), inc_node); 
   tree.child_2		= make_tree(features(dims, indices2), targets(indices2), inc_node); 
%D = C4_5_new(train_features, train_targets, inc_node);