clear all;
close all;

N = 200; % Ölçüm sayısı
sysorder = 5;
mu = 0.0001;
x_measured = zeros([1 N]);
y_measured = zeros([1 N]);
d_ideal = [8.229 3.621 3.145 8.928 5.011]; real = [8,2]; % Test case 3 (8,2)
d_measured = d_ideal + error; % Error ekleme
anchorCount = 5;

x_anchor = [0 11 5 0 11]; % Anchorlar x pozisyonları (biliniyor)
y_anchor = [0 0 3 6 6];  % Anchorlar y pozisyonları (biliniyor)

for k = 1:200 % k kere tekrar edip grafik çizdirmek için sadece
    
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
        e_x(n) = x_measured(n) - estimated_x;
        w = w + (mu*e_x(n)*measured_input(n,:))';
    end
    
    w = zeros([sysorder 1]);
    measured_input = d_measured(1:(N-sysorder+2),:);
    estimated_y = zeros([1 (N-sysorder+2)]);
    
    for n = 1:(N-sysorder+2)
        estimated_y = measured_input(n,:)*w;
        e_y(n) = y_measured(n) - estimated_y;
        w = w + (mu*e_y(n)*measured_input(n,:))';
    end
    
    
    %     Grafikler için genel programla pek alakası yok
    error_lms(k) = sqrt((real(1) - estimated_x)^2 + (real(2) - estimated_y)^2);
    error_raw(k) = sqrt((real(1) - x_measured(n))^2 + (real(2) - y_measured(n))^2);
    k_x(k) = estimated_x;
    k_y(k) = estimated_y;
end

% GRAFİKLER
figure;
scatter(x_measured,y_measured);
hold on
scatter(k_x(1:N),k_y(1:N));
hold on
scatter(real(1),real(2),'ks');
legend('Measured','Estimated(k Different estimations)','Real');
title('Pozisyon Tahminleri');

figure;
plot(e_x.^2);
hold on
plot(e_y.^2);
legend('X error karesi','Y error karesi');
title('Error kareleri');




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
