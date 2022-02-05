function estimate = Kalman_EstimatePoint(estimate, expected_estimate_error,expected_measurement_error,input_coordinates)

%Steady state kalman filter. Yürüme hızını yok sayarsak x(n+1) = x(n)
%expected_estimate_error: Inital guessin beklenen hata aralığı
%expected_measurement_error: Ölçümlerde beklenen hata değeri
%input_coordinates: input matriximiz

% estimate = [10 10];
for n = 1:length(input_coordinates)
    
    %Esitmate error düştükçe kalman gainde düşüyor
    kalman_gain = expected_estimate_error ./ (expected_estimate_error + expected_measurement_error);
    
    %Kalman gain düştükçe estimated değerlere verdiğimiz değer artıyor
    %ölçümlerin etkisi düşüyor
    estimate = estimate + kalman_gain.*(input_coordinates(n,:)-estimate);
    
    %Covariance Update Equation Estimate error güncelleniyor
    expected_estimate_error = (1-kalman_gain).*expected_estimate_error;
end
end