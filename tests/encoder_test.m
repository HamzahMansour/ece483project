function encoder_test
    clear all; close all;

    % Add encoder folder to path
    currentDir = pwd;
    idcs   = strfind(pwd,filesep);
    parentDir = currentDir(1:idcs(end)-1);
    addpath(strcat(parentDir,'\lossy_encoder'));

    % Set input parameters
    video_path = strcat(currentDir,'\test_video1.mp4');
    gop = 7;

    % Test encoder using three different BMA types
    bmas = ["EBMA", "TSS", "TDLS"];

    % run encoder for each BMA + each QF
    
    hold on for i = 1:3
        [quantized_coeff, motion_vectors, ssim_values, zeros_percentage,
        times] = ...
            lossy_encoder(video_path,
            strcat("output_video_qf50_",bmas(i),".avi"), 50, gop, i);
        plot(ssim_values);
    end hold off

    hold on
    for i = 1:3
        [quantized_coeff, motion_vectors, ssim_values, zeros_percentage, times] = ...
            lossy_encoder(video_path, strcat("output_video_qf50_",bmas(i),".avi"), 50, gop, i);
        plot(zeros_percentage);
    end
    hold off

    hold on
    for i = 1:3
        [quantized_coeff, motion_vectors, ssim_values, zeros_percentage, times] = ...
            lossy_encoder(video_path, strcat("output_video_qf50_",bmas(i),".avi"), 50, gop, i);
        plot(times);
    end
    hold off

end
