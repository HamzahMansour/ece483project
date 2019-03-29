function motion_estimation_test
    clear all; close all;

    % Add encoder folder to path
    currentDir = pwd;
    idcs   = strfind(pwd,filesep);
    parentDir = currentDir(1:idcs(end)-1);
    addpath(strcat(parentDir,'\lossy_encoder'));
    
    % Choose anchor/current image, check validity
    [fileA,pathA] = uigetfile({'*.tif';'*.png';'*.jpg';'*.jpeg';'*.*'}, ...
                              'Select Anchor Frame');
    if ~isequal(fileA,0)
        % Choose target/reference image, check validity
        [fileT,pathT] = uigetfile({'*.tif';'*.png';'*.jpg';'*.jpeg'; ...
                                   '*.*'}, 'Select Target Frame');
        if ~isequal(fileT,0)
            % Load test frames into MATLAB
            anchorFrame = imread(strcat(pathA,fileA));
            targetFrame = imread(strcat(pathT,fileT));

            % Execute motion estimation algorithm
            [errorFrame, displacementV, displacementH] = ...
            motion_estimation(double(targetFrame), double(anchorFrame));
        end
    end
    
    % Display error image (complemented for visual inspection purposes)
    imshow(imcomplement(uint8(errorFrame)));
end
