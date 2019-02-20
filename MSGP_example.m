% demonstrate usage of mean-shift gray pixel method
%
% Copyright (c) by Yanlin Qian, yanlin.qian@tut.fi, 2017-11-15.
clear all, close all
addpath(genpath('./greypixel'));
load('exampleimg.mat');
%% mean-shifted grey pixel
Npre =1; % the percentage of pixels chosen as preliminary gray pixels.
bandwidth=0.1; %bandwidth for mean-shift clustering
    
Npixels = size(input_im,1)*size(input_im,2);
numGPs=floor(Npre*Npixels/100); 

%mask saturated pixels
mask(max(input_im,[],3)>=0.95)=1;
%mask very dark pixels
mask(sum(input_im,3)<=8/255.0)=1;

[grayness_map,estimated_illuminants,matrix_cluter] = GPconstancy_meanshift(input_im,numGPs*(2^0),mask,bandwidth,'flatangle',true);

normr(estimated_illuminants)
gt
sprintf('angular error: %0.4f',acos(normr(estimated_illuminants)*gt')*180/pi)
    
    
  