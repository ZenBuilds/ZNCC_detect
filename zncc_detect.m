function m_ik = zncc_detect(mask, i_base, i_k)

[h, w] = size(mask);
[L,n] = bwlabel(ones(h,w)-mask, 4);

i_base = i_base - mean(mean(mean(i_base)));
i_k    = i_k - mean(mean(mean(i_k)));
imshow(i_base)
imshow(i_k)

for i = 1:n
    [r, c] = find(L==i);
    rc = [r c];
    [r, ~] = size(rc);
    domain = zeros(h, w);
    for j = 1:r
        domain(rc(j,1), rc(j,2)) = 1;
    end
    domain = logical(domain);
    i_basek_bar = mean(i_base(domain));
    d_basek     = i_base(domain) - i_basek_bar;
    i_ik_bar    = mean(i_k(domain));
    d_ik        = i_k(domain) - i_ik_bar;
    
    tmp = sum(d_basek .* d_ik);
%     for k = 1:size(d_basek)
%         tmp = tmp + d_basek(k) * d_ik(k);
%     end
    
    m_ik = tmp/(sqrt(sum(d_basek))*sqrt(sum(d_ik)))
end


end
