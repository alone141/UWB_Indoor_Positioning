clear all;
close all;

N = 500; % Ölçüm sayısı
sysorder = 5;
mu = 0.0001;
x_measured = zeros([1 N]);
y_measured = zeros([1 N]);
d_ideal = [8.229 3.621 3.145 8.928 5.011]; real = [8,2]; % Test case 3 (8,2)
d_measured = d_ideal + error; % Error ekleme
anchorCount = 5;

x_anchor = [0 11 5 0 11]; % Anchorlar x pozisyonları (biliniyor)
y_anchor = [0 0 3 6 6];  % Anchorlar y pozisyonları (biliniyor)


for n = 1:N
    d_ideal = [8.229 3.621 3.145 8.928 5.011]; real = [8,2]; % Test case 3 (8,2)
    d_measured(n,:) = d_ideal + error; % Error ekleme
    [x_measured(n),y_measured(n)] = multilateration(anchorCount,x_anchor,y_anchor,d_measured(n,:));
end

w = zeros([sysorder 1]);
measured_input = d_measured(1:(N-sysorder+2),:);
estimated_x = zeros([1 (N-sysorder+2)]);

for n = 1:(N-sysorder+2)
    estimated_x = measured_input(n,:)*w;
    e = x_measured(n) - estimated_x;
    w = w + (mu*e*measured_input(n,:))';
end

w = zeros([sysorder 1]);
measured_input = d_measured(1:(N-sysorder+2),:);
estimated_y = zeros([1 (N-sysorder+2)]);

for n = 1:(N-sysorder+2)
    estimated_y = measured_input(n,:)*w;
    e = y_measured(n) - estimated_y;
    w = w + (mu*e*measured_input(n,:))';
end

estimated = [estimated_x ; estimated_y]

scatter(x_measured,y_measured);
hold on
scatter(real(1),real(2),'ks');
hold on
scatter(estimated_x,estimated_y,'rs');







function y= error % Error function
% mean = -0.023;
% stddev = 0.2;
mean = -0.41;
stddev = 0.62;
y= randn(1,5)*stddev + mean;
end

function [x,y] = multilateration(K,x,y,d)
% K = anchor sayısı
% A*I = b
n = 1:K-1;
A = 2*([x(n) - x(end) ; y(n) - y(end)])';
b = (x(n).^2 - x(end).^2 + y(n).^2 - y(end).^2 + d(end).^2 - d(n).^2)';
I = inv(A'*A)*A'*b;
x = I(1,1); % Ölçülen x
y = I(2,1); % Ölçülen y

end

% function y = LMS(N,mu,)
%
% end
