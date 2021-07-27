function FI = fastExpoFuse(Io, r)

[Hei,Wid,~,N] = size(Io);

%---< 参数>---%
alpha = 1.1; % 在最终融合中的权重
gSig = 0.2;
lSig = 0.5;
SigD = 0.12;%高斯滤波范围

% r = (wSize-1)/2;
epsil = 0.25;%(0.5*1)^2;
np = Hei*Wid;%长乘宽
H = ones(7); %均值滤波
H = H/sum(H(:));
L = zeros(Hei,Wid,N); 
gMu = zeros(Hei, Wid, N); % 全局平均强度
lMu   = zeros(Hei, Wid, N); % 局部平均强度
Iones = ones(Hei, Wid);

for i = 1:N
    
    %---- luminance component
    Ig = rgb2grey(Io(:,:,:,i)); 
    %将真彩色图像RGB转换为灰度强度图像 
    %Matlab的rgb2gray函数采用的是对R、G、B分量进行加权平均的算法
    %过滤亮度分量
    IgPad = padimage(Ig,[3,3]);
    L(:,:,i) = conv2(IgPad, H, 'valid');%卷积

    %全局平均强度
    gMu(:,:,i) = Iones * sum(Ig(:))/np;
    
    %局部平均强度 (Base layer)引导滤波
    lMu(:,:,i) = fastGF(Ig, r, epsil, 2.5);
    
end


%============< Computing Weight Maps  >================%
%细节层曝光融合权重
Sig2 = 2*SigD.^2;
sMap = exp(-1*(L - .5).^2 /Sig2)+1e-6; 
normalizer = sum(sMap, 3);
%sum(A,3)运算后的值为每个通道对应位置的值各自相加
sMap = sMap ./ repmat(normalizer,[1, 1, N]); 
%--- Base layer's blending weights
muMap =  exp( -.5 * ( (gMu - .5).^2 /gSig.^2 +  (lMu - .5).^2 /lSig.^2 ) ); % mean intensity weighting map
normalizer = sum(muMap, 3);
muMap = muMap ./ repmat(normalizer,[1, 1, N]);
%=====================< Fusion >======================%
FI  = zeros(Hei, Wid, 3);
% sMap = alpha*sMap;
for j=1:3
    Ist = (squeeze(Io(:,:,j,:))-lMu);
    FI(:,:,j) = sum((alpha*sMap.*Ist + muMap.*lMu),3);
end
FI(FI > 1) = 1;
FI(FI < 0) = 0;
return


function I = rgb2grey(X)

origSize = size(X);%长*宽*通道

% 确定输入是否为3-D数组
threeD = (ndims(X)==3);

%计算变换矩阵
coef = [0.2,0.6,0.2];

if threeD
  %RGB
  
  % 进行转换
  if isa(X, 'double') || isa(X, 'single')
  %判断输入参量是否为指定类型的对象
    % 调整输入矩阵的形状，使其成为n x 3数组并初始化输出矩阵
    X = reshape(X(:),origSize(1)*origSize(2),3);
    %按照列的顺序进行转换的，也就是第一列读完，读第二列，按列存放，
    sizeOutput = [origSize(1), origSize(2)];
    I = X * coef';
    I = min(max(I,0),1);%补偿0为1

    %Make sure that the output matrix has the right size
    I = reshape(I,sizeOutput);
    
  else
    %uint8 or uint16
    I = imapplymatrix(coef, X, class(X));
  end

else
  I = X * coef';
  I = min(max(I,0),1);
  I = [I,I,I];
end
