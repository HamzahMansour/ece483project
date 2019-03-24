

%% Codec function
% The function follows the structure of an image encoder and decoder, for
% the purpose of showing similarties between problem 9.8 and 9.9. However, 
% since coding/decoding has not been covered yet, those particular stages 
% are left empty. They may be filled after future assignments.

% 

function result = a03_codec(problem_number, input_image, param)
    % Step 1: Image -> DCT -> Coefficients (8x8 blocks)
    dct_coeff = blockproc(input_image,[8,8],'round(dct2(x))');
    
    for problem_number = 8:9
        % 3 Quantization OR Reducing to zero
        switch problem_number
            case 8
                
            case 9
                
        end      
        
        % 4 Coding of coefficients
        % Not necessary for this assignment.
        
        % 5 Decoding of bitstream
        % Not necessary for this assignment.
        
        % 6 Dequantization of coefficients
        switch problem_number
            case 8
                
            case 9
                
        end  
        
        % 7 Inverse block transform
        switch problem_number
            case 8
                
            case 9
                
        end  
        % 8 Displaying of images 
    end

    
%% Main function for Assignment 3 Submission     
function newton_joshua_a03
    % Load image
    [file,path] = uigetfile('*.tif'); % Returns filename and path to file
    input_image = imread(strcat(path,file)); % uint8 grayscale matrix
    
    % Preallocate cell arrays to store processed imagess
    p98_images = cell(5);
    p99_images = cell(6);
    
    % Process images using Problem 9.8 specifications
    % (Partial set of DCT coefficients, K = [4, 8, 16, 32])
    p98_images{1} = a03_codec(9.8, input_image, 4);
    p98_images{2} = a03_codec(9.8, input_image, 8);
    p98_images{3} = a03_codec(9.8, input_image, 16);
    p98_images{4} = a03_codec(9.8, input_image, 32);
    
    % Process images using Problem 9.9 specifications
    % (Quantized DCT coefficients, scale factors = [0.5, 1, 2, 4, 8, 16])
    p99_images{1} = a03_codec(9.9, input_image, 0.5);
    p99_images{2} = a03_codec(9.9, input_image, 1);
    p99_images{3} = a03_codec(9.9, input_image, 2);
    p99_images{4} = a03_codec(9.9, input_image, 4);
    p99_images{5} = a03_codec(9.9, input_image, 8);
    p99_images{6} = a03_codec(9.9, input_image, 16);
    
    % Display images for comparison
    test;