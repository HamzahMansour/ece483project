function quantized_coeff = generate_coefficients(input_img, qf)
    %% Stage 1: Level-off, block transform
    fun = @(block_struct) dct2(block_struct.data - 128); 
    dct_coeff = blockproc(input_img,[8,8],fun);
    
    %% Stage 2: Compression (quantization of coefficients)
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

    % Create quantized set of DCT coefficients
    fun = @(block_struct) ...
          round((double(block_struct.data)./(QM)));
    quantized_coeff = blockproc(dct_coeff,[8,8],fun);            
end