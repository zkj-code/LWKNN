clc;
clear;

% ************AP参数设置***********
AP_Num = 4;             %AP数量
Simu_Num = 200;
APx = [0 30 0 30];
APy = [0 0 30 30];
ap_power = 30; %dbm
ap_gain = 10; %dbm

% ************指纹点参数设置**********
FP_Num = 45; %指纹点数量
fp_gain = 10; %db
FPx = zeros(1, FP_Num); %指纹点位置
FPy = zeros(1, FP_Num);

index = 1; %初始化指纹点位置，排除与AP位置相同的情况
for i = 1:1:7
    for j = 1:1:7
        if ~(i == 1 && j == 1 || i == 1 && j == 7 || i == 7 && j == 1 || i == 7 && j == 7)
            FPx(1, index) = (j - 1) * 5;
            FPy(1, index) = (i - 1) * 5;
            index = index + 1;
        end
    end
end

% *************指纹点接收功率计算*************
fp_power = ReceivePowerFun(APx, APy, FPx, FPy, ap_power, ap_gain, fp_gain);

% *************定位误差累积分布函数初始化*************
nn_cdf = zeros(1, 11);
knn2_cdf = zeros(1, 11);
knn3_cdf = zeros(1, 11);
knn4_cdf = zeros(1, 11);
wknn2_cdf = zeros(1, 11);
wknn3_cdf = zeros(1, 11);
wknn4_cdf = zeros(1, 11);
bayes_cdf = zeros(1, 11);
lwknn_cdf = zeros(1, 11); % 添加LWKNN算法的CDF

base_array = [0:0.5:5];
n = 0;
nn_sum = 0;
knn2_sum = 0;
knn3_sum = 0;
knn4_sum = 0;
wknn2_sum = 0;
wknn3_sum = 0;
wknn4_sum = 0;
bayes_sum = 0;
lwknn_sum = 0; % 添加LWKNN算法的误差累积和

while (n < Simu_Num)
    p_x = rand * 30; %随机生成目标位置
    p_y = rand * 30;
    noise = normrnd(0, 0);
    
    % 计算定位误差并进行累积
    loc_point = FingerLocFun(APx, APy, FPx, FPy, fp_power, ap_power, ap_gain, fp_gain, p_x, p_y, noise, 1, 1); % NN
    error = sqrt((loc_point(1) - p_x)^2 + (loc_point(2) - p_y)^2);
    nn_sum = nn_sum + error;
    nn_cdf = calculate_cdf(error, nn_cdf, base_array);
    
    loc_point = FingerLocFun(APx, APy, FPx, FPy, fp_power, ap_power, ap_gain, fp_gain, p_x, p_y, noise, 2, 2); % KNN
    error = sqrt((loc_point(1) - p_x)^2 + (loc_point(2) - p_y)^2);
    knn2_sum = knn2_sum + error;
    knn2_cdf = calculate_cdf(error, knn2_cdf, base_array);
    
    % 添加对KNN3、KNN4、WKNN2、WKNN3、WKNN4、Bayes算法的计算
    
    % LWKNN算法
    loc_point = LWKNN(APx, APy, FPx, FPy, fp_power, ap_power, ap_gain, fp_gain, p_x, p_y, noise, 3, 3); % LWKNN
    error = sqrt((loc_point(1) - p_x)^2 + (loc_point(2) - p_y)^2);
    lwknn_sum = lwknn_sum + error;
    lwknn_cdf = calculate_cdf(error, lwknn_cdf, base_array);
    
    n = n + 1;
end

% 输出平均定位误差
fprintf('nn=%f\n', nn_sum / Simu_Num);
fprintf('knn2=%f\n', knn2_sum / Simu_Num);
% 输出其他算法的平均定位误差

% 绘制CDF曲线
plot(base_array, nn_cdf / Simu_Num, 'g+-');
hold on
plot(base_array, knn2_cdf / Simu_Num, 'k:x');
% 绘制其他算法的CDF曲线

% 添加图例和标签
legend('NN', 'KNN2'); % 添加其他算法的图例
xlabel('Error distance(m)');
ylabel('Cumulative distribution function');
title('CDF Comparison');

% 计算CDF的辅助函数
function cdf = calculate_cdf(error, cdf, base_array)
    for i = 1:length(base_array)
        if (error < base_array(i))
            cdf(i) = cdf(i) + 1;
        end
    end
end
