[test_audio,fs]=audioread('EDM.wav');
test_audio_l=test_audio(:,1);
test_audio_r=test_audio(:,2);
n_framesize=512;
n_overlap=256;
%Split audio in the frames
buffered_audio=buffer(test_audio_l,n_framesize,n_overlap);
%window the frames
hann_window=hanning(n_framesize);
window_vector= repmat(hann_window',length(buffered_audio),1);
windowed_audio=buffered_audio'.*window_vector;
%Take fourier transform
fft_size=512;
fdomain_audio=fft(windowed_audio,fft_size,2);
%compute magnitude and apply adjustment
PN=90.3;
adjusted_mag=PN+20.*log10(abs(fdomain_audio));
%take half of the mags
adjusted_mag=adjusted_mag(:,1:256);

%%

%Compute tonal flags
tonal_flags=zeros(size(adjusted_mag));
tonal_mags=zeros(size(adjusted_mag));

for i=1:length(tonal_flags)
    audio_segment=adjusted_mag(i,:);
    for j=2:length(audio_segment)-6
        %check for local maxima
        if(audio_segment(1,j)>audio_segment(1,j-1) && audio_segment(1,j)>audio_segment(1,j+1))
            if(j>2&&j<63)
                if(audio_segment(1,j)>(audio_segment(1,j-2)+7) && audio_segment(1,j)>(audio_segment(1,j+2)+7))
                    tonal_flags(i,j)=1;
                end
            elseif(j>=63 && j<127)
                   if(audio_segment(1,j)>(audio_segment(1,j-2)+7) && audio_segment(1,j)>(audio_segment(1,j+3)+7))
                    tonal_flags(i,j)=1;
                   end
            elseif(j>=127 && j<=256)
                  if(audio_segment(1,j)>(audio_segment(1,j-2)+7) && audio_segment(1,j)>(audio_segment(1,j+6)+7))
                    tonal_flags(i,j)=1;
                   end
            end
            if(tonal_flags(i,j)==1)
                temp_sum=0;
                for k=-1:1
                    temp_sum=temp_sum+10^(0.1.*(audio_segment(1,j+k)));
                end
                tonal_mags(i,j)=10*log10(temp_sum);
            end
        end
        
    end
end
%%
audio_segment=adjusted_mag(4,:);
tonal_mag=tonal_mags(4,:);
x_axis=1:256;
filtered_rows=find(tonal_mag>0);
plot(x_axis,audio_segment);
hold on;
plot(x_axis(:,filtered_rows),tonal_mag(:,filtered_rows),'x');
ylim([50 130]);



