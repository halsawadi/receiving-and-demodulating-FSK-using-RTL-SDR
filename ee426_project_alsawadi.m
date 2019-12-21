close all;clear;clc;
tic
load('data4')
M = 4;
freq_sep = 100e3;
fs = 1e6;
symbol_rate = 10e3;
nSamp = fs/symbol_rate;
nRows = length(data);

z = zeros(nRows/nSamp,1);
freqs = (-(M-1)/2 : (M-1)/2) * freq_sep;

t = (0 : 1/fs : nSamp/fs - 1/fs)';
phase = 2*pi*t*freqs;
tones = exp(-1i*phase);

 for iSym = 1 : nRows/nSamp
        
       
        yTemp = data((iSym-1)*nSamp+1 : iSym*nSamp);
        
        
        yTemp = yTemp(:, ones(M,1));

        
        yTemp = yTemp .* tones;

        
        yMag = abs(sum(yTemp,1));

        
        [~,maxIdx]=max(yMag);
        z(iSym) = maxIdx - 1;
        
 end
 
 bit_stream = zeros(2*length(z),1);

 
 for i = 1:length(z)
    switch(z(i))
        case 0
            bit_stream(2*i-1) = 0;
            bit_stream(2*i) = 0;
        case 1
            bit_stream(2*i-1) = 1;
            bit_stream(2*i) = 0;
        case 2
            bit_stream(2*i-1) = 0;
            bit_stream(2*i) = 1;
        case 3
            bit_stream(2*i-1) = 1;
            bit_stream(2*i) = 1;
    end
 end

built_in_bit_stream = bit_stream;

frame_start_locations = strfind(built_in_bit_stream',[1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0])';
frame_bias = 4;
message_cells =  cell(length(frame_start_locations)-frame_bias,1);
w = cell(length(frame_start_locations)-frame_bias,1);


for f = 1:length(frame_start_locations)-frame_bias
    frame_end = 0;
    message_vector = [];
    p = [];
    e = 0;
    Next_frame_start_location = frame_start_locations(f);
    while 1
        
        e = e + 1;

        Next_subframe_location = Next_frame_start_location + 8 + 13*8*(e-1);


        m = zeros(12,1);
        for k = 1:12
            
            q = built_in_bit_stream(Next_subframe_location+8+8*(k-1):Next_subframe_location+7+8*k);
            m(k) = bin2dec(num2str(q)');
            p = [p;q];
            C1 = 0;
            C2 = 0;
            C4 = 0;
            C3 = isequal(built_in_bit_stream(Next_subframe_location+8+8*(k-1):Next_subframe_location+7+8*(k))' , [0,0,0,0,0,0,0,0]);
            C5 = isequal(built_in_bit_stream(Next_subframe_location+8+8*(k-1):Next_subframe_location+7+8*(k)-4)' , [0,0,0,0]);
            
            if k < 12 & k > 10
                C4 = isequal(built_in_bit_stream(Next_subframe_location+8+8*(k-1):Next_subframe_location+7+8*(k))' , [0,0,1,0,1,1,1,0]);
            end 
            
            if k < 12
                C1 = isequal(built_in_bit_stream(Next_subframe_location+8+8*(k-1):Next_subframe_location+7+8*(k+1))' , [0,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0]);
                C2 = isequal(built_in_bit_stream(Next_subframe_location+8+8*(k-1):Next_subframe_location+7+8*(k+1))' , [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
            end
            if C1 | C2 | C3 | C4 | C5
                frame_end = 1;
             
            end
        end
        
        
        

        message_vector = [message_vector;m];
        
        
        if frame_end
            break
        end

               
%         C1 = isequal(built_in_bit_stream(Next_subframe_location+8+8*(10-1):Next_subframe_location+7+8*11)' , [0,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0]);
%         C2 = isequal(built_in_bit_stream(Next_subframe_location+8+8*(11-1):Next_subframe_location+7+8*12)' , [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
%         C3 = isequal(built_in_bit_stream(Next_subframe_location+8+8*(12-1):Next_subframe_location+7+8*13)' , [0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0]);
        
%         c1 = isequal(built_in_bit_stream(Next_subframe_location+8+8*(12-1):Next_subframe_location+7+8*12)' , [0,0,0,0,0,0,0,0]);
%         c2 = isequal(built_in_bit_stream(Next_subframe_location+8+8*(10-1):Next_subframe_location+7+8*10)' , [0,0,1,0,1,1,1,0]);
%         c3 = isequal(built_in_bit_stream(Next_subframe_location+8+8*(11-1):Next_subframe_location+7+8*11)' , [0,0,0,0,0,0,0,0]);
        
%         C4 = c1 & c2;
%         if C1 | C2 | C4 | c1 | c2 | c3 
%             
%         
%             break
% 
%         end

    end



message = join(string(char(message_vector)),"");

message_cells(f) = {message}
w(f) = {p};

end 

ultimate_message_vector = zeros(100*2048,1);

for i = 1: length(w)
    
    ultimate_message_vector = ultimate_message_vector + [2*w{i};zeros(length(ultimate_message_vector)-length(w{i}),1)] - 1;
    
end

ultimate_message_vector = double(ultimate_message_vector > 0);

toc
message = deblank(join(string(char(bin2dec(num2str(reshape(ultimate_message_vector',8,[])')))),""))

