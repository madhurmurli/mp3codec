function [bark_index,bark_mag,bark_count] = calculate_nm(is_nm,audio_segment,bark_lims)
    bark_count=zeros(1,length(bark_lims));
    bark_mag=zeros(1,length(bark_lims));
    bark_index=ones(1,length(bark_lims));
    for i=1:length(audio_segment)
        if(is_nm(1,i)==1)
            cur_bark=getbark(audio_segment(1,i),bark_lims);
            bark_count(1,cur_bark)=bark_count(1,cur_bark)+1;
            cur_mag=audio_segment(1,i);
            bark_mag(1,cur_bark)=bark_mag(1,cur_bark)+10^(0.1*cur_mag);
            bark_index(1,cur_bark)=bark_index(1,cur_bark)*i;
        end
    end
    bark_mag=10.*log10(bark_mag);
    for i=1:length(bark_lims)
        bark_index(1,i)=nthroot(bark_index(1,i),bark_count(1,i));
    end
    
    

end