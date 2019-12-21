

r = zeros(12,1);

%message_length_lower_limit =  
%message_length_upper_limit =
for i= 1:100000
    
    if i < 12
        r(12-i) = r(12-i) + 1;
    end
    
    r(12 - mod(i,12)) = r(12 - mod(i,12)) + 1;
    
end

