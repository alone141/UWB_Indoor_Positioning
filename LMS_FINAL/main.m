clear all;
close all;
%  Standard deviation for line of sight and non line of sight conditions
stddev = 0.2; % 0.2 DUVARLI 0.62 duvarsız

x_Anchor = [0 11 0 5 12]; % Anchorlar X koordinatları
y_Anchor = [0 0 6 3 12]; % Anchorlar Y koordinatları
% İstediğiniz noktaya anchor ekleyebilirsiniz

%-- Tespit edilmesi gereken noktayı elimizle yerleştiriyoruz:
tag_real = [5,8]; % Gerçek tag değeri
distance_real = calculateDistance(tag_real, x_Anchor,y_Anchor); % Gerçek uzaklık değerlerinin hesaplanması
distance_measured = add_error(distance_real,stddev); % Add 0 mean gaussian error
%--

%-- Kalman için gerekli hata tahminleri
expected_Kalman_estimate_error = [10 10];
expected_LMS_measurement_error = [1 1];

tag_estimated_kalman = [3 2];


tag_estimated_LMS = LMS_EstimatePoint(distance_measured,x_Anchor,y_Anchor); % Least mean square tek bir noktadan yola çıkarak
%optimum noktayı buluyor

% for n = 1:10 % 10 farklı ölçüm aldığımızı düşünüyoruz
%     distance_measured = add_error(distance_real,stddev); %Ölçümü alıyoruz
%     
%     tag_estimated_LMS = LMS_EstimatePoint(distance_measured,x_Anchor,y_Anchor); % Least mean square optimum noktayı buluyor tek noktadan yola çıkarak
%     
%     kalman_gain = expected_Kalman_estimate_error ./ (expected_Kalman_estimate_error + expected_LMS_measurement_error);
%     tag_estimated_kalman = tag_estimated_kalman + kalman_gain.*(tag_estimated_LMS-tag_estimated_kalman);
%     expected_Kalman_estimate_error = (1-kalman_gain).*expected_Kalman_estimate_error;
%     
%     gecicixkalman(n) = tag_estimated_kalman(1);
%     geciciykalman(n) = tag_estimated_kalman(2);
%     
%     gecicixLMS(n) = tag_estimated_LMS(1);
%     geciciyLMS(n) = tag_estimated_LMS(2);
% end

% figure;
% subplot(2,1,1);
% plot(gecicixLMS);
% hold on
% plot(gecicixkalman);
% yline(tag_real(1));
% legend('Least Mean Square','Kalman','Gerçek');
% ylabel('Metre');
% subplot(2,1,2);
% plot(geciciyLMS);
% hold on
% plot(geciciykalman);
% yline(tag_real(2));
% ylabel('Metre');
% legend('Least Mean Square','Kalman','Gerçek');
