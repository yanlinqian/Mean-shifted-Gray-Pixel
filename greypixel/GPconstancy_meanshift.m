function [outimg EvaLum,matrix_cluter] = GPconstancy_meanshift(img,numGPs,mask,K,kernel,isangular_ranking)
% function [CorrImg EvaLum] = GPconstancy(img,numGPs,mask)
% inputs:
%         img   ------ Input color-biased image.
%         numGPs ----- The number of grey pixels.
%         mask  ------ The mask of color checker.
% outputs:
%         CorrImg -----Corrected image
%         EvaLum  ---- Estimated illuminant
%
% Main function for performing color constancy system using Grey Pixels in paper:
% Kaifu Yang, Shaobing Gao, and Yongjie Li*.
% Efficient Illuminant Estimation for Color Constancy Using Grey Pixels.CVPR, 2015.
%
% modified by Yanlin Qian, yanlin.qian@tut.fi,2017
%
%========================================================================%



R=img(:,:,1); G=img(:,:,2); B=img(:,:,3);
R(R==0)=eps;  G(G==0)=eps;  B(B==0)=eps;

% % Algorithm 1 -- using edge as IIM
if (isangular_ranking)
    sigma = 0.5;
    greylight=normr([1,1,1]);
    [~,Greyidx] = GetGreyidx_angular(img,'GPedge',sigma);
else
    Greyidx = GetGreyidx(img,'GPedge',sigma);
end
% [~,Greyidx]=GetGreyidx_angular(img,'GPabso',5);

% Algorithm 2 -- using Local Contrast as IIM
% GreyStd = GetGreyidx(img,'GPstd',3);
% Greyidx = GreyStd;

outimg=Greyidx;

if ~isempty(mask)
    Greyidx(find(mask)) = max(Greyidx(:));
end


tt=sort(Greyidx(:));
Gidx = zeros(size(Greyidx));
idx_small_GP=find(Greyidx<=tt(numGPs));
if length(idx_small_GP)>numGPs
    stride=floor(length(idx_small_GP)/numGPs);
    idx_small_GP=idx_small_GP(1:stride:length(idx_small_GP),1);
end
Gidx(idx_small_GP) = 1;
Greyidx_smallGP=Greyidx(idx_small_GP);



Gidx_tile=repmat(Gidx,[1,1,3]);
choosen_img=(img.*Gidx_tile);
%visualize choosen_img
%imshow(choosen_img)

choosen_img_oneline=reshape(choosen_img,size(choosen_img,1)*size(choosen_img,2),size(choosen_img,3));
index1=find(choosen_img_oneline(:,1));
index2=find(choosen_img_oneline(:,2));
index3=find(choosen_img_oneline(:,3));
index_notNaN=union(union(index1,index2),index3);
choosen_img_positive=choosen_img_oneline(index_notNaN,:);

x=choosen_img_positive';
x=x/max(x(:));



[clustCent1,point2cluster1,clustMembsCell1] = angular_HGMeanShiftCluster_betterinit(x,K,kernel,Greyidx_smallGP);
sprintf('mean shift iteration: %d, cluster number: %d',0, size(clustCent1,2))
sprintf('min greyness: %d', min(Greyidx_smallGP))


matrix_cluter=zeros([size(choosen_img_oneline,1),1]);
for i=1:size(clustCent1,2)
    matrix_cluter(index_notNaN(find(point2cluster1==i)))=i;
end
[a,b]=hist(point2cluster1,unique(point2cluster1));
[sortvalue,sortidx]=sort(a,'descend');
ind_greycluster=b(sortidx(1));
center_greycluster=clustCent1(:,ind_greycluster)';


choosen_pixels=choosen_img_positive(find(point2cluster1==ind_greycluster),:);
EvaLum=normr(mean((choosen_pixels),1));


