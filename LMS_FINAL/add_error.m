function output= add_error(input,stddev)
%Input vektörüne stddev zero mean gaussian ekler
mean = 0;
% stddev = 0.2;
% mean = 0;
% stddev = 0.52;
output= input + randn([1 length(input)]).*stddev + mean;
end