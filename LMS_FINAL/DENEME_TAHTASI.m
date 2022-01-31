clear all;
close all;
%  Standard deviation for line of sight and non line of sight conditions
stddev = 0.2; % 0.2 DUVARLI 0.62 duvarsız

kalman_gain = 0;
estimate_error = [10 10];
measurement_error = [1 1];

x_Anchor = [0 11 0 5 12]; % Anchorlar X koordinatları
y_Anchor = [0 0 6 3 12]; % Anchorlar Y koordinatları

%-- Tespit edilmesi gereken noktayı elimizle yerleştiriyoruz:
tag_real = [10,10]; % Gerçek tag değeri
distance_real = calculateDistance(tag_real, x_Anchor,y_Anchor); % Gerçek uzaklık değerlerinin hesaplanması
distance_measured = add_error(distance_real,stddev); % Add 0 mean gaussian error

%--
kalman_gain = 0;
estimate_error = [10 10];
measurement_error = [1 1];
tag_estimated_LMS = LMS_EstimatePoint(distance_measured,x_Anchor,y_Anchor); % Least mean square yakınsama algoritması
tag_estimated_Kalman = [0 0]

for n=1:1000
    distance_measured = add_error(distance_real,stddev); % Add 0 mean gaussian error
    tag_estimated_LMS = LMS_EstimatePoint(distance_measured,x_Anchor,y_Anchor); % Least mean square yakınsama algoritması
    kalman_gain = estimate_error ./ (estimate_error + measurement_error);
    tag_estimated_Kalman = tag_estimated_Kalman + kalman_gain.*(tag_estimated_LMS-tag_estimated_Kalman);
    estimate_error = (1-kalman_gain).*estimate_error;
    gecicix(n) = tag_estimated_Kalman(1);
    geciciy(n) = tag_estimated_Kalman(2);
end
figure;
scatter(tag_estimated_LMS(1),tag_estimated_LMS(2));
hold on
scatter(tag_estimated_Kalman(1),tag_estimated_Kalman(2));
hold on
scatter(tag_real(1),tag_real(2),'ks' ,'filled');
legend('LMS','Kalman','Gerçek')
title('Pozisyon');

figure;
subplot(2,1,1);
plot(gecicix);
yline(tag_real(1));
subplot(2,1,2);
plot(geciciy);
yline(tag_real(2));
