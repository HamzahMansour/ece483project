function [predictedFrame, displacementV, displacementH] = motion_estimation ...
    (targetFrame, anchorFrame, BMA)
    % Input arguments:
    %   - targetFrame: Stored previous frame. This frame will be searched for
    %                  matching blocks to create predicted frame.
    %   - anchorFrame: New frame. Reference, which will be recreated using
    %                  blocks from target frame.
    %   - blockSize: Dimensions of NxN macroblock.
    %   - BMA: Choice for block-matching algorithm. (EBMA, 3SS, 2DLS)
    %
    % Output arguments:
    %   - errorFrame: Difference between anchorFrame and predicted frame.
    %   - displacementV: Vertical component of displacement vectors.
    %   - displacementH: Horizontal component of displacement vectors.

    % Setting a default values for parameters if not supplied
    if (~exist('BMA', 'var'))
        BMA = 1;
    end

    % Precalculate frame and block properties
    mbSize = 16;
    [frameHeight,frameWidth] = size(anchorFrame);
    vBlocks = frameHeight/mbSize;
    hBlocks = frameWidth/mbSize;
    maxHeight = frameHeight-(mbSize-1);
    maxWidth = frameWidth-(mbSize-1);
    S = 7; % Implies a 15x15 search window

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
                         S, mbSize, maxHeight, maxWidth);
                case 2
                    % Three-Step Search for best-matching block and MV
                    [predictedFrame(pAnchorV:pAnchorV+mbSize-1,  ...
                                    pAnchorH:pAnchorH+mbSize-1), ...
                     displacementV(ceil(pAnchorV/mbSize)),       ...
                     displacementH(ceil(pAnchorH/mbSize))] =     ...
                    TSS(targetFrame, anchorBlock, pAnchorV, pAnchorH, ...
                        S, mbSize, maxHeight, maxWidth);
                case 3
                    % 2D Log Search for best-matching block and MV
                    [predictedFrame(pAnchorV:pAnchorV+mbSize-1,  ...
                                    pAnchorH:pAnchorH+mbSize-1), ...
                     displacementV(ceil(pAnchorV/mbSize)),       ...
                     displacementH(ceil(pAnchorH/mbSize))] =     ...
                    TDLS(targetFrame, anchorBlock, pAnchorV, pAnchorH, ...
                         S, mbSize, maxHeight, maxWidth);
                otherwise
                    print("Not a valid choice for BMA");
            end
        end
    end
end


function [predictedBlock, displacementV, displacementH] = EBMA ...
    (targetFrame, anchorBlock, pAnchorV, pAnchorH, ...
     S, mbSize, maxHeight, maxWidth)
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
    for pTargetV = (pAnchorV-S):(pAnchorV+S)
        for pTargetH = (pAnchorH-S):(pAnchorH+S)

            % Ensuring target frame pointers are within image boundary
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
                    displacementV = pTargetV - pAnchorV;
                    displacementH = pTargetH - pAnchorH;
                end
            end
        end
    end
end

function [predictedBlock, displacementV, displacementH] = TSS ...
    (targetFrame, anchorBlock, pAnchorV, pAnchorH, ...
     S, mbSize, maxHeight, maxWidth)
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
    
    % Initialize using target block from anchor block location. (Doing 
    % outside loop as center location not checked in recursive steps.)
    targetBlock = targetFrame(pAnchorV:pAnchorV+mbSize-1, ...
                              pAnchorH:pAnchorH+mbSize-1);
    differenceBlock = targetBlock - anchorBlock;
    lowestError = sum(abs(differenceBlock),'all');      
    predictedBlock = targetBlock;
    displacementV = pAnchorV;
    displacementH = pAnchorH;
    
    % List of neighbour coordinates to search through 
    search = [ 1  1;  1  0;  1 -1; ...
               0  1;         0 -1;  ...
              -1  1; -1  0; -1 -1];
          
    while S > 1
        S = round(S/2);  % Halve step size
        for i = 1:8
            % Update target pointer with location of one of 8 neighbours
            pTargetV = pAnchorV + S*search(i,1);
            pTargetH = pAnchorH + S*search(i,2);
            
            % Ensuring target frame pointers are within image boundary
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
                    displacementV = pTargetV - pAnchorV;
                    displacementH = pTargetH - pAnchorH;
                end
            end
        end  
        % Update center location for next step
        pAnchorV = displacementV;
        pAnchorH = displacementH;
    end
end

function [predictedBlock, displacementV, displacementH] = TDLS ...
    (targetFrame, anchorBlock, pAnchorV, pAnchorH, ...
     S, mbSize, maxHeight, maxWidth)
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
    
    % Initialize using target block from anchor block location. (Doing 
    % outside loop as center location not checked in recursive steps.)
    targetBlock = targetFrame(pAnchorV:pAnchorV+mbSize-1, ...
                              pAnchorH:pAnchorH+mbSize-1);
    differenceBlock = targetBlock - anchorBlock;
    lowestError = sum(abs(differenceBlock),'all');      
    predictedBlock = targetBlock;
    displacementV = pAnchorV;
    displacementH = pAnchorH;
    
    % List of neighbour coordinates to search through 
    search = [        1  0;         ...
               0  1;         0 -1;  ...
                     -1  0;      ];
          
    while S > 1
        for i = 1:4
            % Update target pointer with location of one of 4 neighbours
            pTargetV = pAnchorV + S*search(i,1);
            pTargetH = pAnchorH + S*search(i,2);
            
            % Ensuring target frame pointers are within image boundary
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
                    displacementV = pTargetV - pAnchorV;
                    displacementH = pTargetH - pAnchorH;
                end
            end
        end  
        if (pAnchorV == displacementV)
            % Halve step size if best location did not change
            S = round(S/2);  
        else
            % Update location for next step
            pAnchorV = displacementV;
            pAnchorH = displacementH;
        end
    end 
end

