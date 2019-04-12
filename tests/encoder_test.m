function encoder_test
    clear all; close all;
    
    % Add encoder folder to path
    currentDir = pwd;
    idcs   = strfind(pwd,filesep);
    parentDir = currentDir(1:idcs(end)-1);
    addpath(strcat(parentDir,'\lossy_encoder'));
    
    % Set input parameters
    [file,path] = uigetfile({'*.avi';'*.*'}, 'Select Raw Video');
    video_path = strcat(path,file);
    gop = 7;
    
    % Test encoder using three different BMA types
    bmas = ["EBMA", "TSS", "TDLS"];
    for i = 1:3
        % Testing encoder using three different quantization matrix QFs
        [quantized_coeff, motion_vectors] = ...
            lossy_encoder(video_path, strcat("output_video_qf10_",bmas(i),".avi"), 10, gop, i);
        [quantized_coeff, motion_vectors] = ...
            lossy_encoder(video_path, strcat("output_video_qf50_",bmas(i),".avi"), 50, gop, i);
        [quantized_coeff, motion_vectors] = ...
            lossy_encoder(video_path, strcat("output_video_qf90_",bmas(i),".avi"), 90, gop, i);
    end
end