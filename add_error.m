function output= add_error(input,stddev)
%Input vektörüne stddev zero mean gaussian ekler
output= input + (randn(1,length(input))).*stddev;
end