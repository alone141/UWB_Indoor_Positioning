function tag_estimated = LMS_EstimatePoint(distance_measured,x_anchor,y_anchor)

N = 200;
mu = 0.1;

tag_estimated = [4 4];
[tag_estimated(1) ,tag_estimated(2)] = multilateration(x_anchor,y_anchor,distance_measured);
for n = 1:N
    
    error_distance = calculateDistance(tag_estimated,x_anchor,y_anchor); % Tag_estimated değerinin her anchora olan uzaklığını
    
    diff_Ex = sum((-2/3)*(1-distance_measured./error_distance).*(x_anchor-tag_estimated(1))); % x e göre partial türev
    diff_Ey = sum((-2/3)*(1-distance_measured./error_distance).*(y_anchor-tag_estimated(2))); % y ye göre partial türev
    
    tag_estimated(1)=tag_estimated(1)-mu*diff_Ex;
    tag_estimated(2)=tag_estimated(2)-mu*diff_Ey;
end
end