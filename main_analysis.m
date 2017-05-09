% MMI610 - MP3 Project
% Madhur Murli & Evan Shenkman

clear all;
close all;

% Setup the PATH
addpath('audio', 'functions', 'resources');

% Ask the user for the Audio file name
fileToEncode = input('Please type the name of the audio you wish to encode.\n > ', 's');

% Name the output file
fileToWriteTo = input('Please enter the name of the file to write to.\n > ', 's');

% For Development...
if isempty(fileToEncode)
    fileToEncode = 'EDM.wav';
    fileToWriteTo = 'output.wav';
end

% Try to read the audio file
try
    [test_audio, fs] = audioread(fileToEncode);
    test_audio = test_audio';
catch
    error('Could not find file: %s.\nPlease add the audio file to the audio directory.', fileToEncode);
end

% Break the audio into overlapping frames of 1152 points
test_audio_frames = getFrames(test_audio);

% Do the MP3 algorithm frame-by-frame
for frameNumber = 1:size(test_audio_frames,2)
    frame_audio = squeeze(test_audio_frames(:, frameNumber, :));
    
    % DO PSYCHOACOUSTIC MODEL
    % ...
    
    % HYBRID FILTERBANK
    S = QMF_FilterBank(frame_audio);
    
    % MDCT
    M = MDCT(S);
end

test_audio = test_audio';
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
        cur_bark=getBarkBandNumber(j*(fs/fft_size));
        [tonal_flags(i,j),is_nm]=tonalMaskerTest(audio_segment,j,is_nm);
        if(tonal_flags(i,j)==1)
            t_mag=0;
            for k=-1:1:1
                t_mag=t_mag+10^(0.1*audio_segment(1,j+k));
            end
            tonal_mags(i,j)=10.*log10(t_mag);
            %        tonal_mags(i,j)=audio_segment(1,j);
        end
    end
    %is_nm=ones(1,length(audio_segment));
    [bark_index,bark_mag] = calculateNoiseMaskers(is_nm, audio_segment, fs);
    bark_indexes=[bark_indexes;bark_index];
    bark_mags=[bark_mags;bark_mag];
end

%%
view_index=1;
audio_segment=adjusted_mag(view_index,:);
tonal_mag=tonal_mags(view_index,:);
x_axis=1:256;
x_axis=x_axis.*(fs/fft_size);
x_axis=x_axis/1000;
x_axis_2=30:50:20000;
threshold_hearing=[];
hearing_masking=[];
for i=1:length(x_axis_2)
    f=x_axis_2(1,i)/1000;
    t=3.64*(f^-0.8)-6.5*exp(-0.6*((f-3.33)^2))+1e-3*(f^4);
    threshold_hearing=[threshold_hearing t];
    if(i<=length(x_axis))
        f2=x_axis(1,i);
        t2=3.64*(f2^-0.8)-6.5*exp(-0.6*((f2-3.33)^2))+1e-3*(f2^4);
        hearing_masking=[hearing_masking t2];
    end
end

noise_indexes=bark_indexes(view_index,:);
noise_indexes=noise_indexes.*(fs/(fft_size*1000));
noise_mags=bark_mags(view_index,:);
filtered_rows=find(tonal_mag>0);
plot(x_axis,audio_segment);
hold on;
plot(x_axis(:,filtered_rows),tonal_mag(:,filtered_rows),'x');
%ylim([50 130]);
hold on;
plot(noise_indexes,noise_mags,'o');
hold on;
plot(x_axis_2/1000,threshold_hearing,'-');
hold on;
vline(bark_lims/1000);

xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
%%
%Remove maskers below hearing threshold
min_thresh_mags=tonal_mags;
for i=1:length(tonal_flags)
    tonal_mag=min_thresh_mags(i,:);
    for j=1:length(x_axis)
        if(hearing_masking(1,j)>tonal_mag(1,j))
            min_thresh_mags(i,j)=0;
        end
    end
end
%%
%Take largest maskers in each bark band
decimation_thresh_mags=min_thresh_mags;

bark_maskers=zeros(length(tonal_flags),length(bark_lims));
bark_locs=zeros(length(tonal_flags),length(bark_lims));
masker_levels=zeros(length(tonal_flags),length(bark_lims));
masker_indexes=zeros(length(tonal_flags),length(bark_lims));

for i=1:length(tonal_flags)
    tonal_mag=min_thresh_mags(i,:);
    loc_max=0;
    max_loc=1;
    cur_bark=1;
    for j=1:length(tonal_mag)
        f=(fs/fft_size)*j;
        bark=getBarkBandNumber(f);
        cur_mag=tonal_mag(1,j);
        if(bark==cur_bark)
            if(cur_mag>loc_max)
                decimation_thresh_mags(i,max_loc)=0;
                loc_max=cur_mag;
                max_loc=j;
            else
                decimation_thresh_mags(i,j)=0;
            end
        else
            if(cur_mag>loc_max)
                bark_maskers(i,cur_bark)=cur_mag;
                bark_locs(i,cur_bark)=j;
            else
                bark_maskers(i,cur_bark)=loc_max;
                bark_locs(i,cur_bark)=max_loc;
            end
        
            
            loc_max=0;
            max_loc=1;
            cur_bark=cur_bark+1;
        end
    end
    %Check Noise Maskers
    %     bark_indexes(isnan(bark_indexes)) = 0 ;
    %     bark_mags(find(bark_mags<0))=0;
    %     noise_mags=bark_mags(i,:);
    %     noise_indexes=bark_indexes(i,:);
    %     masker_level=zeros(1,length(noise_mags));
    %     masker_index=zeros(1,length(noise_mags));
    %     for k=1:size(noise_mags)
    %         if(bark_maskers(i,k)>noise_mags(1,k))
    %             masker_levels(i,k)=bark_maskers(1,k);
    %             masker_indexes(i,k)=bark_locs(1,k);
    %         else
    %             masker_levels(i,k)=noise_mags(1,k);
    %             masker_indexes(i,k)=noise_indexes(1,k);
    %         end
    %     end
end



%%


view_index=1;
audio_segment=adjusted_mag(view_index,:);
tonal_mag=decimation_thresh_mags(view_index,:);
x_axis=1:256;
x_axis=x_axis.*(fs/fft_size);
x_axis=x_axis/1000;
x_axis_2=30:50:20000;
threshold_hearing=[];
hearing_masking=[];
for i=1:length(x_axis_2)
    f=x_axis_2(1,i)/1000;
    t=3.64*(f^-0.8)-6.5*exp(-0.6*((f-3.33)^2))+1e-3*(f^4);
    threshold_hearing=[threshold_hearing t];
    if(i<=length(x_axis))
        f2=x_axis(1,i);
        t2=3.64*(f2^-0.8)-6.5*exp(-0.6*((f2-3.33)^2))+1e-3*(f2^4);
        hearing_masking=[hearing_masking t2];
    end
end

noise_indexes=bark_indexes(view_index,:);
noise_indexes=noise_indexes.*(fs/(fft_size*1000));
noise_mags=bark_mags(view_index,:);
filtered_rows=find(tonal_mag>0);
plot(x_axis,audio_segment);
hold on;
plot(x_axis(:,filtered_rows),tonal_mag(:,filtered_rows),'x');
%ylim([50 130]);
hold on;
plot(noise_indexes,noise_mags,'o');
hold on;
plot(x_axis_2/1000,threshold_hearing,'-');
hold on;
vline(bark_lims/1000);

xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');

%%

%reindex markers
bark_indexes(isnan(bark_indexes)) = 0 ;
bark_mags(find(bark_mags<0))=0;
reindexed_TM_indexes=bark_locs;
reindexed_NM_indexes=bark_indexes;
for i=1:length(tonal_flags)
    for j=1:length(bark_lims)
        idx1=reindexed_TM_indexes(i,j);
        idx2=reindexed_NM_indexes(i,j);
        if(idx1<=48)
            reindexed_TM_indexes(i,j)=idx1;
        elseif(idx1>48&&idx1<=96)
            reindexed_TM_indexes(i,j)=idx1+mod(idx1,2);
        elseif(idx1>96&&idx1<=232)
            reindexed_TM_indexes(i,j)=idx1+3-mod(idx1-1,4);
        end
        if(idx2<=48)
            reindexed_NM_indexes(i,j)=idx2;
        elseif(idx2>48&&idx2<=96)
            reindexed_NM_indexes(i,j)=idx2+mod(idx2,2);
        elseif(idx2>96&&idx2<=232)
            reindexed_NM_indexes(i,j)=idx2+3-mod(idx2-1,4);
        end
        
    end
end

%%
    i=1;
    
    tonal_mag=decimation_thresh_mags(i,:);
    TM_indexes=reindexed_TM_indexes(i,:);
   TM_masking_thresholds=[];
    
    for j=1:length(TM_indexes)
        
        if(bark_maskers(i,j)>0&&TM_indexes(1,j)>0)
            masking_thresh=calc_tonal_masking_threshold(tonal_mag,fs/fft_size,bark_lims,TM_indexes(1,j),bark_maskers(i,j));
            TM_masking_thresholds=[TM_masking_thresholds ;masking_thresh];    
        end
        
    end
    NM_indexes=reindexed_NM_indexes(i,:);
   NM_masking_thresholds=[];
   %bark indexes and bark mags
   for j=1:length(NM_indexes)
         if(bark_mags(i,j)>0&&NM_indexes(1,j)>0)
            masking_thresh=calc_noise_masking_threshold(tonal_mag,fs/fft_size,bark_lims,NM_indexes(1,j),bark_mags(i,j));
            NM_masking_thresholds=[NM_masking_thresholds ;masking_thresh];            
        end
   end
   
 
  
   
   view_index=1;
audio_segment=adjusted_mag(view_index,:);
tonal_mag=decimation_thresh_mags(view_index,:);
x_axis=1:256;
x_axis=x_axis.*(fs/fft_size);
x_axis=x_axis/1000;
x_axis_2=30:50:20000;
threshold_hearing=[];
hearing_masking=[];
for i=1:length(x_axis_2)
    f=x_axis_2(1,i)/1000;
    t=3.64*(f^-0.8)-6.5*exp(-0.6*((f-3.33)^2))+1e-3*(f^4);
    threshold_hearing=[threshold_hearing t];
    if(i<=length(x_axis))
        f2=x_axis(1,i);
        t2=3.64*(f2^-0.8)-6.5*exp(-0.6*((f2-3.33)^2))+1e-3*(f2^4);
        hearing_masking=[hearing_masking t2];
    end
end
x_axis_bark=getbark2(x_axis*1000,bark_locs);
noise_indexes=bark_indexes(view_index,:);
noise_indexes=noise_indexes.*(fs/(fft_size*1000));
noise_indexes_bark=getbark2(noise_indexes*1000,bark_locs);
noise_mags=bark_mags(view_index,:);
filtered_rows=find(tonal_mag>0);
plot(x_axis_bark,audio_segment);
hold on;
plot(x_axis_bark(:,filtered_rows),tonal_mag(:,filtered_rows),'x');
%ylim([50 130]);
hold on;
plot(noise_indexes_bark,noise_mags,'o');
hold on;
% plot(x_axis_2/1000,threshold_hearing,'-');
% hold on;
vline(getbark2(bark_lims,bark_lims));
hold on;
% 
% for p=1:size(TM_masking_thresholds,1)
%     plot(x_axis_bark,TM_masking_thresholds(p,:));
%     hold on;
% end

for p=1:size(NM_masking_thresholds,1)
        plot(x_axis_bark,NM_masking_thresholds(p,:));
    hold on;
end
hold off;
ylim([0 150]);
xlabel('Barks');
ylabel('Magnitude (dB)');
   