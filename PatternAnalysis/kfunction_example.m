function kfunction_example
% example of K-function analysis of the data

% generate synthetic data with 1000 datapoints in the area [10, 45, 20, 60]
% dataXY_all = generateNoise(1000, [10, 50, 20, 70]);

%load data
load 09-07-10_Cell10_PALM1_1-160_t11000-7700-28000_npt3-12.mat

%creates data from xf_all, and yf_all
dataXY_all = [xf_all; yf_all]';


% ROI
xlim1=50; xlim2 = 100; ylim1 = 60; ylim2 = 120; 
plotROI = 1; %plot data with selected ROI
% select region of interest (ROI) of the data ans plots:
dataXY = ROIdata(dataXY_all, xlim1, xlim2, ylim1, ylim2, plotROI);

% plot data in red color in size 5
colorData = 'r'; sizeData = 5;
figure
plotData(dataXY, [xlim1, xlim2, ylim1, ylim2], colorData, sizeData)

% plot data in default
figure
plotData(dataXY)


% computes K function in for values between Klim with nSteps steps for ROI
% and simulation envelopes for
Klim = [0 10]; % range of the K function
nSteps = 100; % step of the position of the K function esstimation
envelopes = 1;  %to compute simulatyion envelopes
Nsimul = 5; % number of simulations for envelope coputation
filename = 'Kfunction_example'; % name of the file where K function values are stored
 
[xK, K, KNMax, KNMin, Kall] = ...
    kfunction_main(dataXY_all, xlim1, xlim2, ylim1, ylim2, Klim, nSteps,...
    envelopes, Nsimul, filename); 

% plot K function with theoretical line for Poisson process K_p = pi*xK^2:
plot (xK, K, xK, pi*xK.^2, '--k')

% plot simulation envelopes:
hold on 
plot (xK, KNMax, '-.r', xK, KNMin, '-.r')

% plot all simulations
plot (xK, Kall,':');

% compute L function 
L = computeL(xK, K);


figure
% plot L function for all simulations:
hold on
plot(xK, computeL(xK, Kall),':m');
% plot L function with computed envelopes
plot(xK, L, xK, computeL(xK, KNMax), '-.r', xK, computeL(xK, KNMin), '-.r')

%fiting:
%select the range (in units of xK - xaxes...) where L function should be fit
fitrange = [0 4];
[x_ind1, x_ind2] = fitrange_ind(xK, fitrange);
% selects range in xK and L:
xK_fit = xK(x_ind1:x_ind2); 
L_fit = L(x_ind1:x_ind2);

errval = ones(size(L_fit)); %error in L function - set equal for all values...
initval = [0.1 sqrt(0.2)]; %initial values of the fit

[pbestL,perrorL,nchiL]=nonlinft('fitL' ,xK_fit,L_fit,errval,initval,[1 1]);

% pbestL(1) - kappa
% pbestL(2) - sigma (in units of xK)

%plot fit
figure
plot(xK, L, xK, fitL(xK, pbestL),'r')

fL = fitL(xK, pbestL);
% save fit values in file
filename_fit = 'Lfunction_fit';
writedata(xK, fL, pbestL, filename_fit, 'fit of L function' )