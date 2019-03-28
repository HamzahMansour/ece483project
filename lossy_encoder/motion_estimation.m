function [errorFrame, displacementV, displacementH] = motion_estimation ...
    (targetFrame, anchorFrame, searchRange, mbSize, BMA)
    % Input arguments:
    %   - targetFrame: Stored previous frame. This frame will be searched for
    %                  matching blocks to create predicted frame.
    %   - anchorFrame: New frame. Reference, which will be recreated using
    %                  blocks from target frame.
    %   - blockSize: Dimensions of NxN macroblock.
    %   - BMA: Choice for block-matching algorithm. (EBMA, 3SS, 2DLS)
    %   - searchRange: EBMA parameter.
    %
    % Output arguments:
    %   - errorFrame: Difference between anchorFrame and predicted frame.
    %   - displacementV: Vertical component of displacement vectors.
    %   - displacementH: Horizontal component of displacement vectors.
    
    % Setting a default values for parameters if not supplied
    if (~exist('searchRange', 'var'))
        searchRange = 5;
    end
    
    if (~exist('blockSize', 'var'))
        mbSize = 16;
    end
    
    if (~exist('BMA', 'var'))
        BMA = 1;
    end
    
    % Precalculate frame and block properties
    [frameHeight,frameWidth] = size(anchorFrame);
    vBlocks = frameHeight/mbSize;
    hBlocks = frameWidth/mbSize;
    maxHeight = frameHeight-(mbSize-1);
    maxWidth = frameWidth-(mbSize-1);
    windowSize = (searchRange-1)/2;

    % Preallocate arrays for displacement vectors, predicted frame
    displacementV = zeros(vBlocks,hBlocks);
    displacementH = zeros(vBlocks,hBlocks);
    predictedFrame = zeros(frameHeight,frameWidth);

    % Iterate through anchor frame block by block
    for pAnchorV = 1:mbSize:maxHeight
        for pAnchorH = 1:mbSize:maxWidth
            % Storing values contained in current anchor frame block
            anchorBlock = anchorFrame(pAnchorV:pAnchorV+mbSize-1,...
                                      pAnchorH:pAnchorH+mbSize-1);
            switch BMA
                case 1
                    % Exhaustively search for best-matching block and MV
                    [predictedFrame(pAnchorV:pAnchorV+mbSize-1,  ...
                                    pAnchorH:pAnchorH+mbSize-1), ...
                     displacementV(ceil(pAnchorV/mbSize)),       ...
                     displacementH(ceil(pAnchorH/mbSize))] =     ...
                    EBMA(targetFrame, anchorBlock, pAnchorV, pAnchorH, ...
                         windowSize, mbSize, maxHeight, maxWidth);
                case 2
                    % Three-Step Search for best-matching block and MV
                    [predictedFrame(pAnchorV:pAnchorV+mbSize-1,  ...
                                    pAnchorH:pAnchorH+mbSize-1), ...
                     displacementV(ceil(pAnchorV/mbSize)),       ...
                     displacementH(ceil(pAnchorH/mbSize))] =     ...
                    SS_3(targetFrame, anchorBlock, pAnchorV, pAnchorH, ...
                         windowSize, mbSize, maxHeight, maxWidth);
                case 3
                    % 2D Log Search for best-matching block and MV
                    [predictedFrame(pAnchorV:pAnchorV+mbSize-1,  ...
                                    pAnchorH:pAnchorH+mbSize-1), ...
                     displacementV(ceil(pAnchorV/mbSize)),       ...
                     displacementH(ceil(pAnchorH/mbSize))] =     ...
                    LS_2D(targetFrame, anchorBlock, pAnchorV, pAnchorH, ...
                          windowSize, mbSize, maxHeight, maxWidth);
                otherwise
                    print("Not a valid choice for BMA");
            end
        end
    end
    
    % Calculate difference frame for encoding
    errorFrame = anchorFrame - predictedFrame;
end


function [predictedBlock, displacementV, displacementH] = EBMA ...
    (targetFrame, anchorBlock, pAnchorV, pAnchorH, ...
     windowSize, mbSize, maxHeight, maxWidth)
    % Input arguments:
    %   - targetFrame: Frame to search through for best match block.
    %   - anchorBlock: Block which must be matched.
    %   - pAnchorV: Pointer indicating vertical index of anchorBlock.
    %   - pAnchorH: Pointer indicating horizontal index of anchorBlock.
    %
    % Output arguments:
    %   - predictedBlock: Best match for anchorBlock found in targetFrame.
    %   - displacementV: Vertical component of motion vector.
    %   - displacementH: Horizontal component of motion vector.
    
    % Reset lowest error condition
    lowestError = Inf;

    % Iterate through search window exhaustively
    for pSearchV = -windowSize:windowSize
        for pSearchH = -windowSize:windowSize

            % Convert relative pointer to absolute pointer
            pTargetV = pAnchorV + pSearchV;
            pTargetH = pAnchorH + pSearchH;

            % Ensuring target frame pointers are within boundaries
            if (pTargetV >= 1 && pTargetV <= maxHeight && ...
                pTargetH >= 1 && pTargetH <= maxWidth)

                % Storing values contained in current target block
                targetBlock = targetFrame(pTargetV:pTargetV+mbSize-1, ...
                                          pTargetH:pTargetH+mbSize-1);

                % MAD criterion calculation
                differenceBlock = targetBlock - anchorBlock;
                errorTerm = sum(abs(differenceBlock),'all');

                % Check to see if lowest error in search window
                if errorTerm < lowestError
                    % Updating error condition value
                    lowestError = errorTerm;

                    % Update best match block and its relative location
                    predictedBlock = targetBlock;
                    displacementV = pSearchV;
                    displacementH = pSearchH;
                end
            end
        end
    end
    
    function [predictedBlock, displacementV, displacementH] = SS_3 ...
    (targetFrame, anchorBlock, pAnchorV, pAnchorH, ...
     windowSize, mbSize, maxHeight, maxWidth)
 
    end

    function [predictedBlock, displacementV, displacementH] = LS_2D ...
    (targetFrame, anchorBlock, pAnchorV, pAnchorH, ...
     windowSize, mbSize, maxHeight, maxWidth)
 
    end
end
