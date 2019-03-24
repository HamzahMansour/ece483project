function newton_joshua_a04
    clear all; close all;
    
    % Dimension for square search window
    inputSearchRange = 5;
    
    % Choose target image, anchor image, execute EBMA algorithm
    [fileA,pathA] = uigetfile('*.tif'); 
    if ~isequal(fileA,0)
        [fileT,pathT] = uigetfile('*.tif'); 
        if ~isequal(fileT,0)
            inputAnchorFrame = imread(strcat(pathA,fileA)); 
            inputTargetFrame = imread(strcat(pathT,fileT));
            ebma(inputTargetFrame, inputAnchorFrame, inputSearchRange);
        end
    end    
end

function [predictedFrame, displacementVectors, predictionError] = ...
    ebma(targetFrame, anchorFrame, searchRange, blockSize)
    % Setting a default value of 16 for blockSize when not supplied.
    if (~exist('blockSize', 'var'))
        blockSize = 16;
    end
    
    % Precalculating values needed for iteration
    [frameHeight,frameWidth] = size(anchorFrame);
    maxHeight = frameHeight-(blockSize-1);
    maxWidth = frameWidth-(blockSize-1);
    windowSize = (searchRange-1)/2;
    lowestError = Inf;
    
    % Preallocating arrays for displacement vectors, predicted frame
    displacementV = zeros(25,32);
    displacementH = zeros(25,32);
    predictedFrame = zeros(frameHeight,frameWidth);
    
    % Iterating through location of current anchor frame block 
    for pAnchorV = 1:blockSize:maxHeight
        for pAnchorH = 1:blockSize:maxWidth
            
            % Storing values contained in current anchor frame block
            anchorBlock = anchorFrame(pAnchorV:pAnchorV+blockSize-1,...
                                      pAnchorH:pAnchorH+blockSize-1);  
            
            % Iterating through search location (relative to current block)
            for pSearchV = -windowSize:windowSize
                for pSearchH = -windowSize:windowSize
                    
                    % Calculating location of current target frame block
                    pTargetV = pAnchorV + pSearchV;
                    pTargetH = pAnchorH + pSearchH;
                    
                    % Check if target frame pointers are within boundaries
                    if (pTargetV > 0 && pTargetV < maxHeight+1 && ...
                        pTargetH > 0 && pTargetH < maxWidth+1)
                    
                        % Storing values contained in current target block
                        targetBlock = targetFrame(pTargetV:pTargetV+blockSize-1, ...
                                                     pTargetH:pTargetH+blockSize-1);
                        
                        % MAD criterion calculation
                        differenceBlock = targetBlock - anchorBlock;
                        errorTerm = sum(abs(differenceBlock),'all');
                        
                        if (pAnchorV == (1*blockSize+1) && ...
                            pAnchorH == (1*blockSize+1))
                            figure(1);
                            imshow(targetBlock,'InitialMagnification',1600);
                            figure(2);
                            imshow(anchorBlock,'InitialMagnification',1600);
                        end
                        
                        % Check to see if lowest error in search window
                        if errorTerm < lowestError
                            lowestError = errorTerm;
                            predictedFrame(pAnchorV:pAnchorV+blockSize-1,...
                                           pAnchorH:pAnchorH+blockSize-1)...
                                           =targetBlock;
                                           
                            % Convert block location to indexes for quiver
                            pIndexV = ((pAnchorV-1)/blockSize + 1);
                            pIndexH = ((pAnchorH-1)/blockSize + 1);
                            displacementV(pIndexV,pIndexH) = pSearchV;
                            displacementH(pIndexV,pIndexH) = pSearchH;
                        end
                    end
                end
            end
            lowestError = Inf;
        end
    end
    predictedFrame = uint8(predictedFrame);
    quiver(displacementV,displacementH);
    figure(1);
    imshow(predictedFrame);
    errorImage = anchorFrame - predictedFrame;
    figure(2);
    imshow(imcomplement(errorImage));
    ATdiff = anchorFrame - targetFrame;
    figure(3);
    imshow(imcomplement(ATdiff));
end

