function masking_thresh=calc_tonal_masking_threshold(tonal_thresholds,inc,bark_bands,masker_index,masker_power)
    masking_thresh=zeros(1,length(tonal_thresholds));
    
    for i=1:length(tonal_thresholds)
        masker_bark=getbark2(masker_index*inc,bark_bands);
        masking_thresh(1,i)=masker_power-0.275*(bark_bands(1,round(masker_bark)))-6.025;
        cur_bark=getbark2(i*inc,bark_bands);
        bark_diff=masker_bark-cur_bark;
        sf=0;
        if(bark_diff>=3&&bark_diff<-1)
            sf=17*bark_diff-0.4*masker_power+11;
        elseif(bark_diff>=-1 &&bark_diff<0)
            sf=(0.4*masker_power+6)*bark_diff;
        elseif(bark_diff>=0&&bark_diff<1)
            sf=-17*bark_diff;
        elseif(bark_diff>=1&&bark_diff<8)
            sf=(0.15*masker_power-17)*bark_diff-0.15*masker_power;
        end
        masking_thresh(1,i)=masking_thresh(1,i)+sf;
    end
end