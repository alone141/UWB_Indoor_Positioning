clear all;
close all;
clc
%% Initializations

stddev = 0.25; % 0.2 DUVARLI 0.62 duvarsız

x_Anchor = [0 11 0 5 12]; % Anchorlar X koordinatları
y_Anchor = [0 0 6 3 12]; % Anchorlar Y koordinatları

%-- Tespit edilmesi gereken noktayı elimizle yerleştiriyoruz:

tag_real = [1 1]; % Gerçek tag değeri
tag_real2 = [1 1]; % Gerçek tag değeri
% Take measurement
distance_measured = take_measurement(tag_real,x_Anchor,y_Anchor,stddev);

% Least mean square
tag_estimated_LMS = LMS_EstimatePoint(distance_measured,x_Anchor,y_Anchor);


%% SABIT IVME MODEL KALMAN FILTRESI

variance = stddev^2;

%-- Initial Conditions
x_coordinate = 0;
y_coordinate = 0;
x_velocity = 0;
y_velocity = 0;
x_acceleration = 0;
y_acceleration = 0;

delta_time = 10e-3; %10 Hertz

kalman_reset_distance = 100*stddev;

X_state_matrix =...
    [x_coordinate
    x_velocity
    x_acceleration
    y_coordinate
    y_velocity
    y_acceleration];


% New x_coordinate = x_coordinate + x_velocity*delta_time + x_acceleration*(delta_time^2)/2
% New x_velocity = x_velocity + x_acceleration*delta_time
% New x_acceleration = x_acceleration
% ... ... New X_state_matrix = F_state_transition_matrix*X_state_matrix

F_state_transition_matrix = ...
    [1 delta_time   (delta_time^2)/2    0 0          0
    0 1            delta_time          0 0          0
    0 0            1                   0 0          0
    0 0            0                   1 delta_time (delta_time^2)/2
    0 0            0                   0 1           delta_time
    0 0            0                   0 0           1];


P_initial_covariance_matrix = eye(6)*10;


Q_process_noise_matrix = variance*...
    [(delta_time^4)/4 (delta_time^3)/2 (delta_time^2)/2 0                 0               0
    (delta_time^3)/2 (delta_time^2)    delta_time      0                 0               0
    (delta_time^2)/2 (delta_time)      1               0                 0               0
    0                 0                0               (delta_time^4)/4 (delta_time^3)/2 (delta_time^2)/2
    0                 0                0               (delta_time^3)/2 (delta_time^2)   delta_time
    0                 0                0               (delta_time^2)/2 (delta_time)      1];


H_observation_matrix = [1 0 0 0 0 0 ; 0 0 0 1 0 0];


Z_measurement_matrix = tag_estimated_LMS';

R_measurement_covariance = [variance 0 ; 0 variance];


P_predicted_covariance_matrix = F_state_transition_matrix*P_initial_covariance_matrix*F_state_transition_matrix' + Q_process_noise_matrix;

X_state_matrix = F_state_transition_matrix*X_state_matrix;

for k = 1:50 %1 iterasyon = 0.1 saniye
      
%       %Arch
%     tag_real(1) = tag_real(1) + 1/10*((k-50)/20);
%     tag_real(2) = tag_real(2) +0.001*k;

%     %Vertical
%     tag_real(1) = tag_real(1);
%     tag_real(2) = tag_real(2) + 1.5/10;
   
      %Diagonal
    tag_real(1) = tag_real(1) + 1.5/10;
    tag_real(2) = tag_real(2) + 1.5/10;

    
    %Olcum al
    distance_measured = take_measurement(tag_real,x_Anchor,y_Anchor,stddev);
    
    %Least mean square'e sok
    tag_estimated_LMS = LMS_EstimatePoint(distance_measured,x_Anchor,y_Anchor);
    
    
    
    %Olcumleri kaydet (gereksiz ama dursun)
    Z_measurement_matrix = tag_estimated_LMS';
    
    %Gain hesaplama
    K_kalman_gain = P_predicted_covariance_matrix*H_observation_matrix'*...
        inv(H_observation_matrix*P_predicted_covariance_matrix*H_observation_matrix' + R_measurement_covariance);
    
    %State matrixin guncellenmesi
    X_state_matrix = X_state_matrix + ...
        K_kalman_gain*(Z_measurement_matrix - H_observation_matrix*X_state_matrix);
    
    %Beklenen yeni hata payi matrixi
    P_predicted_covariance_matrix = (eye(6) - K_kalman_gain*H_observation_matrix)*...
        P_predicted_covariance_matrix*(eye(6)-K_kalman_gain*H_observation_matrix)' + ...
        K_kalman_gain*R_measurement_covariance*K_kalman_gain';
    
    %
    X_state_matrix = F_state_transition_matrix*X_state_matrix;
    
    P_predicted_covariance_matrix = F_state_transition_matrix*...
        P_predicted_covariance_matrix*F_state_transition_matrix' + Q_process_noise_matrix;
    
    
    x_kalman_temp(k) = X_state_matrix(1);
    y_kalman_temp(k) = X_state_matrix(4);
    
    x_raw_temp(k) = tag_real(1);
    y_raw_temp(k) = tag_real(2);
    
    x_measured_temp(k) = Z_measurement_matrix(1);
    y_measured_temp(k) = Z_measurement_matrix(2);
end


tag_kalman = [x_kalman_temp(end) y_kalman_temp(end)];
fark = calculateDistance(tag_kalman, x_raw_temp(end),y_raw_temp(end))

figure;
% scatter(x_raw_temp,y_raw_temp)
% hold on
scatter(x_kalman_temp,y_kalman_temp)
hold on
scatter(tag_real2(1),tag_real2(2), 'ks', 'filled');
hold on
scatter(x_kalman_temp(end),y_kalman_temp(end), 'kd', 'filled');
hold on
scatter(x_measured_temp,y_measured_temp);
hold on
scatter(x_Anchor,y_Anchor,'kd');
legend('Kalman','Başlangıç','Bitiş','LMS','Anchors')
title('10 saniye süren bir hareket')


figure;
scatter(x_raw_temp,y_raw_temp)
hold on
scatter(x_measured_temp,y_measured_temp);
hold on
scatter(x_Anchor,y_Anchor,'kd');
ylim([0 15])
xlim([0 15])
legend('Gerçek','Ölçülen(LMS)','Anchors')
title('10 saniye süren bir hareket')


figure;
scatter(x_raw_temp,y_raw_temp)
hold on
scatter(x_kalman_temp,y_kalman_temp)
hold on
% scatter(x_measured_temp,y_measured_temp)
% hold on
scatter(tag_real2(1),tag_real2(2), 'ks', 'filled');
hold on
scatter(x_raw_temp(end),y_raw_temp(end), 'kd', 'filled');
hold on
scatter(x_Anchor,y_Anchor,'kd');
legend('Gerçek','Filtrelenmiş(Kalman)','Başlangıç','Bitiş','Anchors')
title('10 saniye süren bir hareket')


figure;
plot2 = scatter(x_measured_temp(1),y_measured_temp(1),'filled');
hold on 
plot3 = scatter(x_raw_temp(1),x_raw_temp(1),'filled');
hold on
plot4 = scatter(x_Anchor,y_Anchor,'kd','filled');
legend('LMS','Gerçek','Anchors')
title('10 saniye süren bir hareket')
ylim([0 15])
xlim([0 15])
xlabel('X Ekseni(Metre)');
ylabel('Y Ekseni(Metre)');
f = getframe;
[im,map] = rgb2ind(f.cdata,256,'nodither');
im(1,1,1,length(x_kalman_temp)) = 0;
for k = 2:length(x_kalman_temp) 
     plot2.XData = x_measured_temp(1:k); 
     plot2.YData = y_measured_temp(1:k); 
     hold on
     plot3.XData = x_raw_temp(1:k); 
     plot3.YData = y_raw_temp(1:k); 
       f = getframe;
    im(:,:,1,k) = rgb2ind(f.cdata,map,'nodither');
%      pause(0.002)

    % draw stuff
    
end
imwrite(im,map,'lms.gif','DelayTime',0,'LoopCount',inf)


figure;
plot1 = scatter(x_kalman_temp(1),y_kalman_temp(1),'filled');
hold on
plot3 = scatter(x_raw_temp(1),x_raw_temp(1),'filled');
hold on
plot4 = scatter(x_Anchor,y_Anchor,'kd','filled');
legend('LMS + Kalman','Gerçek','Anchors')
title('10 saniye süren bir hareket')
ylim([0 15])
xlim([0 15])
xlabel('X Ekseni(Metre)');
ylabel('Y Ekseni(Metre)');
f = getframe;
[im,map] = rgb2ind(f.cdata,256,'nodither');
im(1,1,1,length(x_kalman_temp)) = 0;
for k = 2:length(x_kalman_temp) 
     plot1.XData = x_kalman_temp(1:k); 
     plot1.YData = y_kalman_temp(1:k); 
     hold on
     plot3.XData = x_raw_temp(1:k); 
     plot3.YData = y_raw_temp(1:k); 
       f = getframe;
    im(:,:,1,k) = rgb2ind(f.cdata,map,'nodither');
%      pause(0.002)

    % draw stuff
    
end
imwrite(im,map,'kalman.gif','DelayTime',0,'LoopCount',inf)