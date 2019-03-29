function img_to_coeff_to_img_test
    clear all; close all;

    % Add encoder folder to path
    currentDir = pwd;
    idcs   = strfind(pwd,filesep);
    parentDir = currentDir(1:idcs(end)-1);
    addpath(strcat(parentDir,'\lossy_encoder'));
    
    % Set quality factor for compression
    qf = 5;
    
    % Choose image, check validity
    [file,path] = uigetfile({'*.tif';'*.png';'*.jpg';'*.jpeg';'*.*'}, ...
                              'Select Input Image');
    if ~isequal(file,0)
        % Read image as MATLAB double array
        input_img = double(imread(strcat(path,file)));
        
        % Convert image to quantized DCT coefficients at specified QF
        quantized_coeff = generate_coefficients(input_img, qf);
        % Convert DCT coefficients to image at specified QF
        output_img = generate_frame(quantized_coeff,qf);
        
        % Display image for testing
        imshow(output_img);
    end
end