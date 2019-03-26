function [quantized_coeff, motion_vectors] = lossy_encoder(input_video, gop,
                                                           bma)
%% Compress raw video using temporal and spatial compression methods.
% Input arguments:
%   - input_video:
%   - gop: Parameter, controls sequencing of I and P frames. Every 'gop'th
%          frame will be an I frame.
%   - bma: Parameter, controls which block-matching algorithm is used in
%          motion estimation stage.
%
% Output arguments:
%   - quantized_coeff: Quantized coefficients (created from I frame,
%                      difference frame) to be encoded.
%   - motion_vectors: Motion vectors (used to generate predicted frame) to be
%                     encoded.


%% previous api file combined with main.m, stored in project folder.
%functions:
coefficients = generateCoefficients(inputFrame);
storedFrame = generateFrame(coefficients);
[predictedFrame, motionVectors] = motionEstimation(inputFrame, storedFrame, bma);

% main.m
v = VideoReader('inputVideo');
while hasFrame(v)
  frame_counter++;

  currentFrame = readFrame(v);

  if(currentFrame = i_frame){
    coefficients = generateCoefficients(inputFrame);
    storedFrame = generateFrame(coefficients);
  }
else if(currentFrame = p_frame){
    [predictedFrame, motionVectors] = motionEstimation(inputFrame, storedFrame);

    differenceFrame = inputFrame - predictedFrame;
    coefficients = generateCoefficients(differenceFrame);

    differenceFrame = generateFrame(coefficients);
    storedFrame = differenceFrame + predictedFrame;
  }
end
