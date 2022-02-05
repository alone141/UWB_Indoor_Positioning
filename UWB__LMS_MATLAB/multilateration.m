function [x_tag,y_tag] = multilateration(x_anchor,y_anchor,distance)
% multilateration(x_anchor,y_anchor,distance) [x_anchor y_anchor] noktalarına olan uzaklıklara göre koordinat bulur  
A = 2*x_anchor(2) - 2*x_anchor(1);
B = 2*y_anchor(2) - 2*y_anchor(1);
C = distance(:,1).^2 - distance(:,2).^2 - x_anchor(1)^2 + x_anchor(2)^2 - y_anchor(1)^2 + y_anchor(2)^2;
D = 2*x_anchor(3) - 2*x_anchor(2);
E = 2*y_anchor(3) - 2*y_anchor(2);
F = distance(:,2).^2 - distance(:,3).^2 - x_anchor(2)^2 + x_anchor(3)^2 - y_anchor(2)^2 + y_anchor(3)^2;
x_tag = (C*E - F*B) / (E*A - B*D);
y_tag = (C*D - A*F) / (B*D - A*E);

end