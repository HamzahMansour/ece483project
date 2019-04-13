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
            anchorFrame = double(imread(strcat(pathA,fileA)));
            targetFrame = double(imread(strcat(pathT,fileT)));
            
            % Execute motion estimation algorithm
            predictedFrames = cell(1,3);
            displacementV = cell(1,3);
            displacementH = cell(1,3);
            errorFrames = cell(1,3);
            
            % Predict frame for each BMA type
            for i = 1:3
                [predictedFrames{i}, displacementV{i}, displacementH{i}] = ...
                motion_estimation(targetFrame, anchorFrame, i);
            
                % Calculate difference frame for encoding
                errorFrames{i} = anchorFrame - predictedFrames{i};

                % Display error image (complemented for visual inspection)
                figure(i);
                imshow(imcomplement(uint8(errorFrames{i})));
            end
        end
    end
end
