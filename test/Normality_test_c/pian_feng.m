% 读取 Excel 文件中的数据
[num, txt, raw] = xlsread('ture.xlsx'); 

x_data = num(:, 1); 
y_data = num(:, 2); 

x_skewness = skewness(x_data);
y_skewness = skewness(y_data);
x_kurtosis = kurtosis(x_data);
y_kurtosis = kurtosis(y_data);

figure;
subplot(2,2,1);
histogram(x_data);
title('Histogram of X Data');

subplot(2,2,2);
histogram(y_data);
title('Histogram of Y Data');

subplot(2,2,3);
bar({'X Skewness', 'Y Skewness'}, [x_skewness, y_skewness]);
title('Skewness');

subplot(2,2,4);
bar({'X Kurtosis', 'Y Kurtosis'}, [x_kurtosis, y_kurtosis]);
title('Kurtosis');

disp(['X Skewness: ', num2str(x_skewness)]);
disp(['Y Skewness: ', num2str(y_skewness)]);
disp(['X Kurtosis: ', num2str(x_kurtosis)]);
disp(['Y Kurtosis: ', num2str(y_kurtosis)]);
