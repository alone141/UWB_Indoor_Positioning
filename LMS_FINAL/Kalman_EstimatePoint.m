function tag_estimated = Kalman_EstimatePoint(expected_estimate_error,expected_measurement_error,input_coordinates)

tag_estimated = [10 10];
for n = 1:length(input_coordinates)
    kalman_gain = expected_estimate_error ./ (expected_estimate_error + expected_measurement_error);
    tag_estimated = tag_estimated + kalman_gain.*(input_coordinates(n,:)-tag_estimated);
    expected_estimate_error = (1-kalman_gain).*expected_estimate_error;
end
end