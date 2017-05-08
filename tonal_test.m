function [is_tonal,is_nm_o]=tonal_test(audio_segment,j,is_nm)
is_tonal=1;
%local maxima
uplim=0;
downlim=0;
if(audio_segment(1,j)>audio_segment(1,j-1) && audio_segment(1,j)>audio_segment(1,j+1))
    if(j>2&&j<63) 
        uplim=2;
        downlim=2;
    elseif(j>=63 && j<127)
        downlim=2;
        uplim=3;
    elseif(j>=127 && j<=256)
        downlim=2;
        uplim=6;
    end
    startInd=j-downlim;
    endInd=j+uplim;
  
   for indexes=startInd:endInd
       if(audio_segment(1,indexes)>audio_segment(1,j))
           is_tonal=0;
       else
           is_nm(1,indexes)=0;
       end
   end 
   
else
    is_tonal=0;
    
end
is_nm_o=is_nm;


end