function encoder_test
    clear all; close all;
    
    % Set input paraemeters
    [file,path] = uigetfile({'*.avi';'*.*'}, 'Select Raw Video');
    video_path = strcat(path,file);
    gop = 7;
    bma = 'EBMA';
    
    % Testing encoder using three different quantization matrix QFs
    [quantized_coeff, motion_vectors] = ...
        lossy_encoder(video_path, "output_video_qf10.avi", 10, gop, bma);
    [quantized_coeff, motion_vectors] = ...
        lossy_encoder(video_path, "output_video_qf50.avi", 50, gop, bma);
    [quantized_coeff, motion_vectors] = ...
        lossy_encoder(video_path, "output_video_qf90.avi", 90, gop, bma);
end