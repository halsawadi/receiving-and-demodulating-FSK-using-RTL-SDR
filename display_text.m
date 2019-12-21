function [message] = display_text(bit_stream,start_idx,num_char)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

message_vector = zeros(num_char,1);
for k = 1:num_char
    message_vector(k) = bin2dec(num2str(bit_stream(start_idx+16+8*(k-1):start_idx+15+8*k))')
end

message = join(string(char(message_vector)),"");

end

