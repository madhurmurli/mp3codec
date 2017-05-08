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

%bark band limits
bark_lims=[100,200,300,400,510,630,770,920,1080,1270,1480,1720,2000,2320,2700,3150,3700,4400,5300,6400,7700,9500,12000,15500,25000];
%bark_lims=[100,200,300,400,510,630,770,920,1080,1270,1480,1720,2000,2320,2700,3150,3700,4400,5300,6400,7700,9500,12000];

%%

%Compute tonal flags
tonal_flags=zeros(size(adjusted_mag));
tonal_mags=zeros(size(adjusted_mag));
bark_indexes=[];
bark_mags=[];
bark_counts=[];

for i=1:length(tonal_flags)
    audio_segment=adjusted_mag(i,:);
    is_nm=ones(1,length(audio_segment));
    for j=2:length(audio_segment)-6
        %check for local maxima
            cur_bark=getbark(j*(fs/fft_size),bark_lims);
            [tonal_flags(i,j),is_nm]=tonal_test(audio_segment,j,is_nm);        
            if(tonal_flags(i,j)==1)
              tonal_mags(i,j)=audio_segment(1,j);                
            end
    end
    %is_nm=ones(1,length(audio_segment));
    [bark_index,bark_mag,bark_count] = calculate_nm(is_nm,audio_segment,bark_lims,fs/fft_size);
    bark_indexes=[bark_indexes;bark_index];
    bark_mags=[bark_mags;bark_mag];
    bark_counts=[bark_counts; bark_count];
end

%%
view_index=1;
audio_segment=adjusted_mag(view_index,:);
tonal_mag=tonal_mags(view_index,:);
x_axis=1:256;
x_axis=x_axis.*(fs/fft_size);
x_axis=x_axis/1000;
noise_indexes=bark_indexes(view_index,:);
noise_indexes=noise_indexes.*(fs/(fft_size*1000));
noise_mags=bark_mags(view_index,:);
filtered_rows=find(tonal_mag>0);
plot(x_axis,audio_segment);
hold on;
plot(x_axis(:,filtered_rows),tonal_mag(:,filtered_rows),'x');
ylim([50 130]);
hold on;
plot(noise_indexes,noise_mags,'o');
hold on;
vline(bark_lims/1000);
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
%%




