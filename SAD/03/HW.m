data;
k = 3;
k_cnf = k_cnf_learn(examples, labels, k);
if ~isempty(k_cnf)
    cnf2str(k_cnf, header);
    k_dnf = cnf2dnf(k_cnf);
    dnf2str(k_dnf, header)
end
%(tear-prod-rate_normal & ~age_presbyopic & ~age_pre-presbyopic & age_young)
%| (tear-prod-rate_normal & ~age_presbyopic & ~astigmatism_yes & ~age_young & age_pre-presbyopic)
%| (tear-prod-rate_normal & ~age_presbyopic & spectacle-prescrip_myope & ~age_young & age_pre-presbyopic)
%| (~age_presbyopic & ~spectacle-prescrip_myope & ~astigmatism_yes & ~age_pre-presbyopic & ~age_young & ~tear-prod-rate_normal)
%| (tear-prod-rate_normal & ~spectacle-prescrip_myope & ~astigmatism_yes & ~age_pre-presbyopic & ~age_young & age_presbyopic)
%| (tear-prod-rate_normal & astigmatism_yes & spectacle-prescrip_myope & ~age_pre-presbyopic & ~age_young & age_presbyopic)


%tear-prod-ratenormal& :agepresbyopic & :agepre-presbyopic & ageyoung)
%or
%(tear-prod-ratenormal & :agepresbyopic & :astigmatismyes & :ageyoung & agepre-presbyopic)
%or
%(tear-prod-ratenormal & :agepresbyopic & spectacle-prescripmyope & :ageyoung & agepre-presbyopic)
%or
%(tear-prod-ratenormal & :spectacle-prescripmyope & :astigmatismyes & :agepre-presbyopic & :ageyoung & agepresbyopic)
%or
%(tear-prod-ratenormal & astigma-tismyes & spectacle-prescripmyope & :agepre-presbyopic & :ageyoung & agepresbyopic