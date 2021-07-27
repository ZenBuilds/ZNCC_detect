function FI = fastExpoFuse(Io, r)

[Hei,Wid,~,N] = size(Io);

%---< ����>---%
alpha = 1.1; % �������ں��е�Ȩ��
gSig = 0.2;
lSig = 0.5;
SigD = 0.12;%��˹�˲���Χ

% r = (wSize-1)/2;
epsil = 0.25;%(0.5*1)^2;
np = Hei*Wid;%���˿�
H = ones(7); %��ֵ�˲�
H = H/sum(H(:));
L = zeros(Hei,Wid,N); 
gMu = zeros(Hei, Wid, N); % ȫ��ƽ��ǿ��
lMu   = zeros(Hei, Wid, N); % �ֲ�ƽ��ǿ��
Iones = ones(Hei, Wid);

for i = 1:N
    
    %---- luminance component
    Ig = rgb2grey(Io(:,:,:,i)); 
    %�����ɫͼ��RGBת��Ϊ�Ҷ�ǿ��ͼ�� 
    %Matlab��rgb2gray�������õ��Ƕ�R��G��B�������м�Ȩƽ�����㷨
    %�������ȷ���
    IgPad = padimage(Ig,[3,3]);
    L(:,:,i) = conv2(IgPad, H, 'valid');%���

    %ȫ��ƽ��ǿ��
    gMu(:,:,i) = Iones * sum(Ig(:))/np;
    
    %�ֲ�ƽ��ǿ�� (Base layer)�����˲�
    lMu(:,:,i) = fastGF(Ig, r, epsil, 2.5);
    
end


%============< Computing Weight Maps  >================%
%ϸ�ڲ��ع��ں�Ȩ��
Sig2 = 2*SigD.^2;
sMap = exp(-1*(L - .5).^2 /Sig2)+1e-6; 
normalizer = sum(sMap, 3);
%sum(A,3)������ֵΪÿ��ͨ����Ӧλ�õ�ֵ�������
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

origSize = size(X);%��*��*ͨ��

% ȷ�������Ƿ�Ϊ3-D����
threeD = (ndims(X)==3);

%����任����
coef = [0.2,0.6,0.2];

if threeD
  %RGB
  
  % ����ת��
  if isa(X, 'double') || isa(X, 'single')
  %�ж���������Ƿ�Ϊָ�����͵Ķ���
    % ��������������״��ʹ���Ϊn x 3���鲢��ʼ���������
    X = reshape(X(:),origSize(1)*origSize(2),3);
    %�����е�˳�����ת���ģ�Ҳ���ǵ�һ�ж��꣬���ڶ��У����д�ţ�
    sizeOutput = [origSize(1), origSize(2)];
    I = X * coef';
    I = min(max(I,0),1);%����0Ϊ1

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
