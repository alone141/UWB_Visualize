clear all;
close all;

N = 1000;  % X ICIN 3 ANCHORDAN N KEZ ALINAN INPUTLAR
mu = 0.00005; % Step size
w = zeros([3 1]);  % Filtrenin ağırlık katsayıları

x_Anchor = [0 11 0]; % X coordinates of anchors
y_Anchor = [0 0 6 6];  % Y coordinates of anchors
distance_measured = zeros([N 3]); % Ölçülen uzaklık değerleri
x_measured = zeros([1 N]); % Saf ölçümlerle hesaplanan x değerleri
y_measured = zeros([1 N]); % Saf ölçümlerle hesaplanan y değerleri
x_estimated = zeros([1 N]);% Algoritmadan tahmin edilen x değerleri
y_estimated = zeros([1 N]);% Algoritmadan tahmin edilen x değerleri
% error_value = zeros([1 N]);% Algoritmadan tahmin edilen x değerleri
% Gerçek uzaklık değerleri
%  distance_real = [8.546 4.247 8.542]; xy_tag = [8,3]; % Test case 1 (8,3)
distance_real = [5.010 8.950 3.599]; xy_tag = [3,4]; % Test case 2 (3,4)
%  distance_real = [10.82 6.33 9];      xy_tag = [9,6]; % Test case 3 (9,6)
% distance_real = [1.423 10.044 5.094];xy_tag = [1,1]; % Test case 4 (1,1)

for k = 1:500
%     [x_tag_real,y_tag_real] = multilateration(x_Anchor,y_Anchor,distance_real);
    distance_measured = distance_real + error; 
    for n = 1:N
        distance_measured(n,:) = distance_real + error; % Hata payı ekleme
    end
    [x_measured,y_measured] = multilateration(x_Anchor,y_Anchor,distance_measured); % Ölçülen x ve y değerleri
    
    w = zeros([3 1]); % Filtre ağırlık matrixi
    for n = 1:N
        x_estimated(n) = distance_measured(1,:)*w;  % Tahmin edilen değer
        error_value(n) = x_measured(n) - x_estimated(n); % Hata deeğeri hesaplanması 
        w = w + (mu*error_value(n)*distance_measured(1,:))'; % Hata değeri, step size ve inputa göre ağırlık matrixini güncelleme
    end
    
    for n = 1:N
        y_estimated(n) = distance_measured(1,:)*w;
        error_value(n) = y_measured(n) - y_estimated(n);
        w = w + (mu*error_value(n)*distance_measured(1,:))';
    end
    % K farklı tahminin hata payını kaydetme
    FINAL_ESTIMATE_ERROR_DISTANCE(k) = sqrt((xy_tag(1)-x_estimated(end))^2 + (xy_tag(2) - y_estimated(end))^2);
    FINAL_MEASURED_ERROR_DISTANCE(k) = sqrt((xy_tag(1)-x_measured(end))^2 + (xy_tag(2) - x_measured(end))^2);
end
% GRAFİKLER

figure; % X İterasyon vs Metre grafiği
plot(x_measured);
hold on
plot(x_estimated);
hold on
yline(xy_tag(1));
title('Ölçülen X vs Tahmin Edilen X');
legend('Ölçülen','Tahmin Edilen','Gerçek');
xlabel('İterasyon'); 
ylabel('Metre'); 


figure; % X ve Y İterasyon vs Metre grafiği
plot(y_measured);
hold on
plot(y_estimated);
hold on
yline(xy_tag(2));
title('Ölçülen Y vs Tahmin Edilen Y');
legend('Ölçülen','Tahmin Edilen','Gerçek');
xlabel('İterasyon'); 
ylabel('Metre'); 


figure; % Pozisyon Tahmin grafiği
scatter(xy_tag(1),xy_tag(2), 'ks', 'filled');
hold on
scatter(x_measured,y_measured );
hold on
scatter(x_estimated(end),y_estimated(end), 'bd', 'filled');
hold on
scatter(x_measured(1),y_measured(1), 'rd', 'filled');
xlabel('X Ekseni (Metre)'); 
ylabel('Y Ekseni (Metre)'); 
legend('Gerçek', 'N Ölçüm', 'Son Tahmin', 'İlk Ölçüm');
title('Pozisyon Grafiği');

figure; % Hata değerlerinin histogram grafiği
subplot(2,1,1);
histogram(FINAL_MEASURED_ERROR_DISTANCE);
title('Birbirinden Bağımsız N Ölçümün Gerçek Değere Göre Hata Değerleri');
xlabel('Metre'); 
ylabel('Frekans'); 
subplot(2,1,2);
histogram(FINAL_ESTIMATE_ERROR_DISTANCE);
title('Birbirinden Bağımsız N Tahminin Gerçek Değere Göre Hata Değerleri');
xlabel('Metre'); 
ylabel('Frekans'); 

% En son tahmin edilen değerin hata payı
FINAL_ESTIMATE_ERROR_DISTANCE = sqrt((xy_tag(1)-x_estimated(end))^2 + (xy_tag(2) - y_estimated(end))^2)

function y= error % Error function
% mean = -0.023;
% stddev = 0.2;
mean = -0.41;
stddev = 0.62;
y= randn([1 3])*stddev + mean;
end

function [x_tag,y_tag] = multilateration(x_anchor,y_anchor,distance)


A = 2*x_anchor(2) - 2*x_anchor(1);
B = 2*y_anchor(2) - 2*y_anchor(1);
C = distance(:,1).^2 - distance(:,2).^2 - x_anchor(1)^2 + x_anchor(2)^2 - y_anchor(1)^2 + y_anchor(2)^2;
D = 2*x_anchor(3) - 2*x_anchor(2);
E = 2*y_anchor(3) - 2*y_anchor(2);
F = distance(:,2).^2 - distance(:,3).^2 - x_anchor(2)^2 + x_anchor(3)^2 - y_anchor(2)^2 + y_anchor(3)^2;
x_tag = (C*E - F*B) / (E*A - B*D);
y_tag = (C*D - A*F) / (B*D - A*E);

end

