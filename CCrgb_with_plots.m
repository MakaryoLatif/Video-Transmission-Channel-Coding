% Reading the video
obj = VideoReader('highway.avi');

% Reads all the frames of the video and stores them in a 4-dimensional array 'a', 
% where the dimensions represent rows, columns, color channels (typically RGB), and frames
a = read(obj);

% Error probability for the binary symmetric channel
p = linspace(0.0001, 0.2, 10);

% Getting the number of frames in the video
frames = get(obj, 'NumberOfFrames');


% Extracting the frames
for i = 1:frames
    l(i).cdata = a(:, :, :, i);
end

% Defining the code rates and puncturing patterns for convolutional coding
codeRate = [8/9, 4/5, 2/3, 4/7, 1/2];
puncturing = {[1 1 1 0 1 0 1 0 0 1 1 0 1 0 1 0],[1 1 1 0 1 0 1 0 1 1 1 0 1 0 1 0],[1 1 1 0 1 1 1 0 1 1 1 0 1 1 1 0],[1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 0],[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]};

% Size of one frame (assuming the frames are of the same size)
s = size(l(1).cdata);

% Initialize the structure array to hold the modified frames
mov1(1:frames) = struct('cdata', zeros(s(1), s(2), 3, 'uint8'), 'colormap', []); 

% prob error for rate half
y1 = [];
z1 = [];
for p_plot = 1:length(p)
    % Initialize error counting variables
    total_errors = 0;
    total_bits = 0;
    total_corrected = 0;
% Loop through each frame
for Frame = 1:frames
    % Extracting RGB channels from the frame
    R = l(Frame).cdata(:, :, 1);
    G = l(Frame).cdata(:, :, 2);
    B = l(Frame).cdata(:, :, 3);

    % Convert RGB channels to double precision
    Rdouble = double(R);
    Gdouble = double(G);
    Bdouble = double(B);

    % Convert double precision channels to binary
    R_bin = de2bi(Rdouble);
    G_bin = de2bi(Gdouble);
    B_bin = de2bi(Bdouble);

    % Reshape binary data into 1D arrays
    Rbin_reshaped = reshape(R_bin, 1, []);
    Gbin_reshaped = reshape(G_bin, 1, []);
    Bbin_reshaped = reshape(B_bin, 1, []);

    % Reshape binary data into packets
    R_packets = reshape(Rbin_reshaped, 198, 1024);
    G_packets = reshape(Gbin_reshaped, 198, 1024);
    B_packets = reshape(Bbin_reshaped, 198, 1024);

    % Define the trellis structure for convolutional coding
    trellis = poly2trellis(7, [171 133]);

    % Loop through each packet
    for j = 1:198
        % Extract individual packets
        R_packet = R_packets(j, :);
        G_packet = G_packets(j, :);
        B_packet = B_packets(j, :);

        % Encode the packets using convolutional coding
        encoded_R(j, :) = convenc(R_packet, trellis, puncturing{4});
        encoded_G(j, :) = convenc(G_packet, trellis, puncturing{4});
        encoded_B(j, :) = convenc(B_packet, trellis, puncturing{4});

        % Pass the encoded packets through a binary symmetric channel
        errored_R = bsc(encoded_R, p(p_plot));
        errored_G = bsc(encoded_G, p(p_plot));
        errored_B = bsc(encoded_B, p(p_plot));
        
        % Simulate transmission without no channel coding
        % errored_R_no_code = bsc(R_packets, p(p_plot));
        % errored_G_no_code = bsc(G_packets, p(p_plot));
        % errored_B_no_code = bsc(B_packets, p(p_plot));

        % Decode the received packets using Viterbi decoding
        decoded_R(j, :) = vitdec(errored_R(j, :), trellis, 35, 'trunc', 'hard', puncturing{4});
        decoded_G(j, :) = vitdec(errored_G(j, :), trellis, 35, 'trunc', 'hard', puncturing{4});
        decoded_B(j, :) = vitdec(errored_B(j, :), trellis, 35, 'trunc', 'hard', puncturing{4});

        % Update the total number of bits processed
        total_bits = total_bits + length(decoded_R(j, :))+length(decoded_G(j, :))+length(decoded_B(j, :));

        % Count the number of errors in the decoded packets
        errors_red = sum(decoded_R(j, :) ~= R_packets(j, :));
        errors_blue = sum(decoded_B(j, :) ~= G_packets(j, :));
        errors_green = sum(decoded_G(j, :) ~= B_packets(j, :));
        total_errors = total_errors + errors_red + errors_blue + errors_green;
        

    end
end

    total_corrected = total_bits - total_errors;
    % Reshape the errored packets without channel coding back to 2D arrays
    % Rcorrected_reshaped = reshape(errored_R_no_code, 144 * 176, 8);
    % Gcorrected_reshaped = reshape(errored_G_no_code, 144 * 176, 8);
    % Bcorrected_reshaped = reshape(errored_B_no_code, 144 * 176, 8);

    % Reshape the errored packets with channel coding (in different rates depending on the puncturing rule) back to 2D arrays
    % Rcorrected_reshaped = reshape(decoded_R, 144*176, 8);
    % Gcorrected_reshaped = reshape(decoded_G, 144*176, 8);
    % Bcorrected_reshaped = reshape(decoded_B, 144*176, 8);
    % 
    % % Convert binary data back to double precision
    % R_binToDoub = bi2de(Rcorrected_reshaped);
    % G_binToDoub = bi2de(Gcorrected_reshaped);    
    % B_binToDoub = bi2de(Bcorrected_reshaped);
    % 
    % % Convert double precision data back to uint8
    % Rcorrected_uint8 = uint8(R_binToDoub);
    % Gcorrected_uint8 = uint8(G_binToDoub);
    % Bcorrected_uint8 = uint8(B_binToDoub);
    % 
    % % Reshape the data back to the original frame size
    % R_original = reshape(Rcorrected_uint8, 144, 176, []);
    % G_original = reshape(Gcorrected_uint8, 144, 176, []);
    % B_original = reshape(Bcorrected_uint8, 144, 176, []);
    % 
    % % Store the corrected frame in the output video structure
    % mov1(Frame).cdata(:, :, 1) = R_original;
    % mov1(Frame).cdata(:, :, 2) = G_original;
    % mov1(Frame).cdata(:, :, 3) = B_original;
    % Calculate the error probability
    error_prob = total_errors / total_bits;
    throughput = (total_corrected/total_bits)*(4/7);
    disp(total_errors)
    disp(total_corrected)
    disp(total_bits)
    disp(error_prob)
    disp(throughput)
    % error probability for rate half
    y1(p_plot) = error_prob;
    z1(p_plot) = throughput;
end


% Create a VideoWriter object
%v1 = VideoWriter('Channel Coding Project NewVideo_rate_half_P_0.1.avi');

% Open the VideoWriter object
%open(v1);

% Write frames to the VideoWriter object
%writeVideo(v1, mov1);

% Close the VideoWriter object
%close(v1);

% Play the resulting video
%implay('Channel Coding Project NewVideo_rate_half_P_0.1.avi');

x = p;
% Plotting the error probability and throughput
figure;
subplot(2, 1, 1);
plot(x, y1, '-o');
xlabel('(p)');
ylabel('bit Error Probability');
title('bit Error Probability vs. p');
grid on;

subplot(2, 1, 2);
plot(x, z1, '-o');
xlabel('(p)');
ylabel('Throughput');
title('Throughput vs. p');
grid on;


