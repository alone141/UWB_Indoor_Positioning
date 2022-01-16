clear all;
close all;
FAIL=0;

for k = 1:1000

a_x = [0 11 0]; % X coordinates of anchors
a_y = [0 0 6 6];  % Y coordinates of anchors

% The real distance values without noise
% anchor_realdist = [8.546 4.247 8.542]; real = [8,3]; % Test case 1 (8,3) 
%  anchor_realdist = [5.010 8.950 3.599]; real = [3,4]; % Test case 2 (3,4)
anchor_realdist = [10.82 6.33 9]; real = [9,6]; % Test case 3 (9,6)
%  anchor_realdist = [1.423 10.044 5.094]; real = [1,1]; % Test case 4 (1,1)



N = 500;  % X ICIN 3 ANCHORDAN N KEZ ALINAN INPUTLAR
mu = 0.000005; % Step size
% N = 500; mu = 0.0001;

for i = 1:N
    anchor_pseudodist(i,:) = anchor_realdist + error()'; % Adding noise
end

  A = 2*a_x(2) - 2*a_x(1);
  B = 2*a_y(2) - 2*a_y(1);
  C = anchor_pseudodist(:,1).^2 - anchor_pseudodist(:,2).^2 - a_x(1)^2 + a_x(2)^2 - a_y(1)^2 + a_y(2)^2;
  D = 2*a_x(3) - 2*a_x(2);
  E = 2*a_y(3) - 2*a_y(2);
  F = anchor_pseudodist(:,2).^2 - anchor_pseudodist(:,3).^2 - a_x(2)^2 + a_x(3)^2 - a_y(2)^2 + a_y(3)^2;
  d_x = (C*E - F*B) / (E*A - B*D);
  d_y = (C*D - A*F) / (B*D - A*E);
  
sysorder = 3;
x  = [anchor_pseudodist(:,1) anchor_pseudodist(:,2) anchor_pseudodist(:,3)];     % Input to the filter 
d  = d_x;  % Desired signal = output of H + Uncorrelated noise signal
w = zeros (sysorder, 1) ; % Initially filter weights are zero
mu = 0.01;
for n = 1 : N 
    x_co(:,n)= x(n,:)*w; % output of the adaptive filter
    e(n) = d(n) - x_co(n) ; % error signal = desired signal - adaptive filter output
    w(:,1) = w(:,1) + (mu * x(n,:) * e(n)).' ; % filter weights update
    if e(n) < 1
        mu = 0.001;
    end
    if e(n) < 0.1
        mu = 0.0001;
    end
end 

x  = [anchor_pseudodist(:,1) anchor_pseudodist(:,2) anchor_pseudodist(:,3)];     % Input to the filter 
d  = d_y;  % Desired signal = output of H + Uncorrelated noise signal
w = zeros (sysorder, 1) ; % Initially filter weights are zero
mu = 0.0005;
for n = 1 : N 
    y_co(:,n)= x(n,:)*w; % output of the adaptive filter
    e(n) = d(n) - y_co(n) ; % error signal = desired signal - adaptive filter output
    w(:,1) = w(:,1) + (mu * x(n,:) * e(n)).' ; % filter weights update
    if e(n) < 1
        mu = 0.001;
    end
    if e(n) < 0.1
        mu = 0.0001;
    end
end     
psuedo_hata(k) = pdist([real;d_x(end), d_y(end)]);
tahmin_hata(k) = pdist([real;x_co(end), y_co(end)]);

tahmin_y(k) = y_co(end);
tahmin_x(k) = x_co(end);
if psuedo_hata(k)-tahmin_hata(k) < 0
FAIL = FAIL+1;
end
end




figure;
plot(e);
title('Error margin')
figure;
plot(d_y)
hold on
plot(y_co);
legend('Y Pseudo','Y Tahmin')


figure;
% plot(d_x(end),d_y(end),'rx')
scatter(d_x,d_y);
hold on
% plot(x_co(end),y_co(end),'bx');
scatter(tahmin_x,tahmin_y);
hold on
scatter(a_x(1),a_y(1),'ks','filled');
hold on
scatter(a_x(2),a_y(2),'ks','filled');
hold on
scatter(a_x(3),a_y(3),'ks','filled');
hold on
plot(real(1),real(2),'kd');
legend('pseudo','tahmin','gercek','Anchors')
title('Pozisyon Grafiği')
axis([0 11 0 6])

figure;
subplot(2,1,1);
histogram(psuedo_hata);
subplot(2,1,2);
histogram(tahmin_hata);

figure;

plot(tahmin_hata);


function y= error % Error function
mean = -0.023;
stddev = 0.2;
% mean = -0.41;
% stddev = 0.62;
y= randn(3,1)*stddev + mean; % Error margin with standard deviation and mean
end
