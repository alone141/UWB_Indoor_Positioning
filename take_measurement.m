function distance_measured = take_measurement(position_real,x_anchor,y_anchor,stddev)
%distance_measured = take_measurement(position_real,x_anchor,y_anchor,stddev)
distance_real = calculateDistance(position_real, x_anchor,y_anchor); % Gerçek uzaklık değerlerinin hesaplanması
distance_measured = add_error(distance_real,stddev); % Add 0 mean gaussian error
end