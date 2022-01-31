clear all;
close all;
%  Standard deviation for line of sight and non line of sight conditions
stddev = 0.2; % 0.2 DUVARLI 0.62 duvarsız

x_Anchor = [0 11 0 5 12]; % Anchorlar X koordinatları
y_Anchor = [0 0 6 3 12]; % Anchorlar Y koordinatları
% İstediğiniz noktaya anchor ekleyebilirsiniz

%-- Tespit edilmesi gereken noktayı elimizle yerleştiriyoruz:
tag_real = [10,10]; % Gerçek tag değeri
distance_real = calculateDistance(tag_real, x_Anchor,y_Anchor); % Gerçek uzaklık değerlerinin hesaplanması
distance_measured = add_error(distance_real,stddev); % Add 0 mean gaussian error

%--
expected_Kalman_estimate_error = [10 10];
expected_LMS_measurement_error = [1 1];

for n = 1:10
    distance_measured = add_error(distance_real,stddev); % Add 0 mean gaussian error
    tag_estimated_LMS(n,:) = LMS_EstimatePoint(distance_measured,x_Anchor,y_Anchor); % Least mean square yakınsama algoritması
end

tag_estimated_kalman = Kalman_EstimatePoint(expected_Kalman_estimate_error,expected_LMS_measurement_error,tag_estimated_LMS);
