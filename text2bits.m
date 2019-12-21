function [b] = text2bits(txt)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
b = reshape([zeros(length(txt),1),dec2bin(txt) - '0']',[],1);
end

