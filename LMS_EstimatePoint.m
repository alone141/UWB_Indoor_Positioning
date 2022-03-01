function tag_estimated = LMS_EstimatePoint(distance_measured,x_anchor,y_anchor)

N = 200; %Iterasyon
mu = 0.1; %step size

tag_estimated = [0.01 0.01]; % Initial guess

for n = 1:N
    
    % tag_estimated pozisyonunun her anchora olan uzaklığını 
    distance_estimated = calculateDistance(tag_estimated,x_anchor,y_anchor); 
    
    %Error_distance ın karesinin gradienti
    diff_Ex = sum((-2/3)*(1-distance_measured./distance_estimated).*(x_anchor-tag_estimated(1))); % x e göre partial türev
    diff_Ey = sum((-2/3)*(1-distance_measured./distance_estimated).*(y_anchor-tag_estimated(2))); % y ye göre partial türev
    
    %Erroru azaltmak için gradientin tersi yönde bir adım atarak bir minimum arıyoruz 
    tag_estimated(1)=tag_estimated(1)-mu*diff_Ex;
    tag_estimated(2)=tag_estimated(2)-mu*diff_Ey;

  
end
end
