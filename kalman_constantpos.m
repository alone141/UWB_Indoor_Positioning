close all;
clear all;
clc

stddev = 0.5;
variance = stddev^2;
delta_time = 10e-1; %10 Hertz
x_Anchor = [0 11 0 11]; % Anchorlar X koordinatları
y_Anchor = [0 0 11 11]; % Anchorlar Y koordinatları

C = get(0, 'PointerLocation');
C(1) = C(1)/148;
C(2) = C(2)/91;
tag_real = C;
% Take measurement
distance_measured = take_measurement(tag_real,x_Anchor,y_Anchor,stddev);

% Least mean square
tag_estimated_LMS = LMS_EstimatePoint(distance_measured,x_Anchor,y_Anchor);


%%
%KALMANIN NE KADAR LAGLI OLACAGI
%YUKSEK OLURSA DAHA AGRESIF TAKIP EDER
%IDEALINI BULUN OYNAYA OYNAYA
kalman_stddev = 0.2;
kalman_var = kalman_stddev^2;
%%

%Ini
x_coordinate = 0;
y_coordinate = 0;

X_state_matrix =...
    [x_coordinate
    y_coordinate];

F_state_transition_matrix = ...
    [1 0
    0 1];

Q_process_noise_matrix = kalman_var/2*...
    [kalman_var 0 ; 0 kalman_var];

H_observation_matrix = [1 0 ; 0 1];

Z_measurement_matrix = [0; 0];
R_measurement_covariance = [kalman_var 0 ; 0 kalman_var];

P_initial_covariance_matrix = eye(2)*100;

P_predicted_covariance_matrix = F_state_transition_matrix*P_initial_covariance_matrix*F_state_transition_matrix' + Q_process_noise_matrix;

X_state_matrix = F_state_transition_matrix*X_state_matrix;

figure;
% subplot(3,1,[1 2]);
plot_anchor = scatter(x_Anchor,y_Anchor,"kd","filled");
hold on
plot_real = plot(tag_real(1),tag_real(2),"-g",'LineWidth',2);
hold on
plot_kalman = plot(X_state_matrix(1),X_state_matrix(2),"k-",'LineWidth',2);
hold on
plot_lms = plot(tag_estimated_LMS(1),tag_estimated_LMS(2),"r.");
legend("Anchors","Real","Kalman","LMS");
title("Koordinat Sistemi")
xlabel("Y Ekseni (Metre)");
ylabel("X Ekseni (Metre)")
% subplot(3,1,3);
% plot_kalman_error = plot(calculateDistance(tag_real, X_state_matrix(1), X_state_matrix(2)));
% hold on
% plot_lms_error = plot(calculateDistance(tag_real, tag_estimated_LMS(1), tag_estimated_LMS(2)));
% legend("Kalman Hata","LMS Hata");
% xlabel("Saniye * 10");
% ylabel("Metre")
% title("Hata Payları")
% xlim([0 200]);
i = 0;
tag_real = [0 0];
while 1 %1 iterasyon = 0.1 saniye
    i = i + 1;
    %Takes the cursors coordinate on the screen
    C = get(0, 'PointerLocation');
    %Normalizes the location of cursor 
    C(1) = C(1)/148;
    C(2) = C(2)/91;

    tag_real = C;

    %Olcum al
    distance_measured = take_measurement(tag_real,x_Anchor,y_Anchor,stddev);
    
    %Least mean square'e sok
    tag_estimated_LMS = LMS_EstimatePoint(distance_measured,x_Anchor,y_Anchor);
    
    %Olcumleri kaydet 
    Z_measurement_matrix = tag_estimated_LMS';

    %Gain hesaplama
    K_kalman_gain = P_predicted_covariance_matrix*H_observation_matrix'*...
        inv(H_observation_matrix*P_predicted_covariance_matrix*H_observation_matrix' + R_measurement_covariance);
    
    %State matrixin guncellenmesi
    X_state_matrix = X_state_matrix + ...
        K_kalman_gain*(Z_measurement_matrix - H_observation_matrix*X_state_matrix);
    
    %Beklenen yeni hata payi matrixi
    P_predicted_covariance_matrix = (eye(2) - K_kalman_gain*H_observation_matrix)*...
        P_predicted_covariance_matrix*(eye(2)-K_kalman_gain*H_observation_matrix)' + ...
        K_kalman_gain*R_measurement_covariance*K_kalman_gain';
    

    X_state_matrix = F_state_transition_matrix*X_state_matrix;
    
    P_predicted_covariance_matrix = F_state_transition_matrix*...
        P_predicted_covariance_matrix*F_state_transition_matrix' + Q_process_noise_matrix;
    

    % GRAFIKLER ICIN ---------------------
    temp_kalmanx(i) = X_state_matrix(1);
    temp_kalmany(i) = X_state_matrix(2);
    
    temp_lmsx(i) = tag_estimated_LMS(1);
    temp_lmsy(i) = tag_estimated_LMS(2);
    
    temp_realx(i) = tag_real(1);
    temp_realy(i) = tag_real(2);
    
    temp_kalman_error(i) = calculateDistance(tag_real, X_state_matrix(1), X_state_matrix(2));
    temp_lms_error(i) = calculateDistance(tag_real, tag_estimated_LMS(1),tag_estimated_LMS(2));
    
    plot_kalman.XData = temp_kalmanx(1:i);
    plot_kalman.YData = temp_kalmany(1:i);
    
    plot_lms.XData = temp_lmsx(1:i);
    plot_lms.YData = temp_lmsy(1:i);
    
    plot_real.XData = temp_realx(1:i);
    plot_real.YData = temp_realy(1:i);
  
    % 10 Hz update frequency
    pause(0.1);
    
    %To reset the graph
    if i > 200
        i = 0;
%         break;
    end
        
end


