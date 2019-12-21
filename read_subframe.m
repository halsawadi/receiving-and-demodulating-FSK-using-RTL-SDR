function [outputArg1,outputArg2] = read_subframe()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

subframe_bits = built_in_bit_stream(Next_subframe_location+8:12*8+Next_subframe_location+8);

end

