function [quantized_coeff, motion_vectors, ssim_values, zeros_percentage, times] = ...
    lossy_encoder(input_video, output_video, qf, gop, bma)
%% Compress raw video using temporal and spatial compression methods.
% Input arguments:
%   - input_video: Path to input video.
%   - output_video: Filename for output video file.
%   - gop: Parameter, number of P frames before the next I frame.
%   - bma: Parameter, controls which block-matching algorithm is used in
%          motion estimation stage.
%
% Output arguments:
%   - quantized_coeff: Quantized coefficients (created from I frame,
%                      difference frame) to be encoded.
%   - motion_vectors: Motion vectors (used to generate predicted frame) to be
%                     encoded.
    % Creating Video objects for read/write operations
    v_in = VideoReader(input_video);
    v_out = VideoWriter(output_video,'Grayscale AVI');

    % Preallocating output (First 100 frames, unsure of how to preallocate
    % for full video. Fix later.)
    quantized_coeff = cell(100,1);
    motion_vectors = cell(100,2);
    ssim_values = zeros(100, 1);
    zeros_percentage = zeros(100, 1);
    times = zeros(100, 1);

    open(v_out);
    frame_counter = 0;
    % while hasFrame(v_in);
    while (frame_counter < 100) % Needs to be adapated for full video
        frame_counter = frame_counter + 1;

        % Extract grayscale frame (for testing)
        current_frame = readFrame(v_in);
        input_frame = double(rgb2gray(current_frame));

        timerVal = tic;
        % I frame
        if frame_counter(mod(frame_counter, gop) == 1)
            % Convert image to quantized DCT coefficients at specified QF
            quantized_coeff{frame_counter, 1} = ...
                generate_coefficients(input_frame, qf);
            % Convert DCT coefficients to image at specified QF
            stored_frame = generate_frame(quantized_coeff{frame_counter,1},qf);

        % P frame
        else
            % Execute motion estimation algorithm
            [predicted_frame, motion_vectors{frame_counter,1}, ...
                              motion_vectors{frame_counter,2}] = ...
                motion_estimation(double(stored_frame), double(input_frame), bma);
            % Calculate difference frame for encoding
            error_frame = input_frame - predicted_frame;
            % Convert image to quantized DCT coefficients at specified QF
            quantized_coeff{frame_counter, 1} = ...
                generate_coefficients(error_frame, qf);
            % Convert DCT coefficients to image at specified QF
            error_frame = generate_frame(quantized_coeff{frame_counter,1},qf);
            % Combine
            stored_frame = predicted_frame + error_frame;
        end
        times(frame_counter) = toc(timerVal);


        ssim_values(frame_counter) = ssim(stored_frame, input_frame);
        zeros_percentage(frame_counter) = nnz(~quantized_coeff{frame_counter, 1})/numel(quantized_coeff{frame_counter, 1});

        % Write stored frame to file for viewing results
        writeVideo(v_out,uint8(stored_frame));

        % Status update
        if (mod(frame_counter, 10) == 0)
            disp([num2str(frame_counter),' frames saved']);
        end
    end

    close(v_out);
end
