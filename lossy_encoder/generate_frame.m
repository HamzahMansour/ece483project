function output_img = generate_coefficients(quantized_coeff, qf)       
    %% Stage 1: Dequantization of coefficients
    % Generate JPEG quantization matrix
    m = [16 11 10 16 24 40 51 61       
         12 12 14 19 26 58 60 55       
         14 13 16 24 40 57 69 56 
         14 17 22 29 51 87 80 62
         18 22 37 56 68 109 103 77
         24 35 55 64 81 104 113 92 
         49 64 78 87 103 121 120 101 
         72 92 95 98 112 100 103 99];

    % Scale quantization matrix using quality factor
    if (qf >= 50)
        tau = (100 - qf)/50;
    elseif (qf < 50)
        tau = 50/qf;
    end
    QM = m * tau;
    
    % Apply dequantization operation
    fun = @(block_struct) double(block_struct.data).*QM;
    partial_coeff = blockproc(quantized_coeff,[8,8],fun);
    
    %% Stage 2: Inverse block transform, undo level off
    fun = @(block_struct) idct2(block_struct.data) + 128;
    reconstructed_img = blockproc(partial_coeff,[8,8],fun);
    
    output_img = reconstructed_img;