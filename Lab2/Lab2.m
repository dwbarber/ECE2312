% %%ECE 2312_Lab 2. Part of the code has been already released in 
% https://www.mathworks.com/matlabcentral/answers/506350-separate-voice-from-background-music
%Dream on by Aerosmith is acquired by the instructor through Amazon Music. The selected part of the 
% song is extracted using QuickTime Player. The file DreamOn_trimmed.m4a is restricted to individuals 
% enrolled in the course ECE 2312_C25 and must not be shared, distributed, or disclosed to any 
% unauthorized persons outside of this course.

clear all
close all
clc

warning('off')
[audio_in,audio_freq_samp] = audioread(['mysong.m4a']);

%ALLIGNING THE VALUES TO LENGTH OF AUDIO, AND DF IS THE MINIMUM FREQUENCY RANGE
length_audio = length(audio_in);
df = audio_freq_samp/length_audio;
 
%CALCULATING FREQUENCY VALUES TO BE ASSIGNED ON THE X-AXIS OF THE GRAPH
frequency_audio = -audio_freq_samp/2:df:audio_freq_samp/2-df;
 
%APPLYING FOURIER TRANSFORM TO THE AUDIO FILE
FFT_audio_in = fftshift(fft(audio_in)/length(fft(audio_in)));

% PLOTTING
plot(frequency_audio,abs(FFT_audio_in));
title('FFT of input Audio');
xlabel('frequency(HZ)');
ylabel('Amplitude');
 
%NOW LETS SEPARATE THE VARIOUS COMPONENTS BY CUTTING IT IN FREQUENCY RANGE

%%%Human-being voiceband 
% lower_threshold = 300;
% upper_threshold = 3400;

%%%Human-being voice frequency range
% lower_threshold = 80;
% upper_threshold = 255;

%%%Steven Tyler's octave range spans multiple octaves. In the music "Dream
%%%on", his range was 174.61 Hz (F3) to 830.61 Hz (G#5). He hits E6 1318.51
%%%hertz (Hz), too. 
lower_threshold = 174.61;
upper_threshold = 1318.51; 

% WHEN THE VALUES IN THE ARRAY ARE IN THE FREQUENCY RANGE THEN WE HAVE 1 AT
% THAT INDEX AND 0 FOR OTHERS I.E; CREATING AN BOOLEAN INDEX ARRAY
 
val = abs(frequency_audio)<upper_threshold & abs(frequency_audio)>lower_threshold;
%"Dream On" by Aerosmith is recorded in stereo, meaning the sound is
%distributed across both left and right speakers. Therefore, both
%FFT_audio_in(:,1) and FFT_audio_in(:,2) contain frequency coefficients of
%vocalist and instruments. 
FFT_ins = FFT_audio_in(:,2);
FFT_voc = FFT_audio_in(:,2); 

%BY THE LOGICAL ARRAY THE FOURIER IN FREQUENCY RANGE IS KEPT IN VOCALS;AND
%REST IN INSTRUMENTAL AND REST OF THE VALUES TO ZERO
FFT_ins(val) = 0;
FFT_voc(~val) = 0;
 
%NOW WE PERFORM THE INVERSE FOURIER TRANSFORM TO GET BACK THE SIGNAL
FFT_a = ifftshift(FFT_audio_in(:,1));
FFT_music = ifftshift(FFT_ins);
FFT_vocal = ifftshift(FFT_voc);

%CREATING THE TIME DOMAIN SIGNAL
music = real(ifft(FFT_music*length(FFT_music))); 
vocal = real(ifft(FFT_vocal*length(FFT_vocal)));
audio = ifft(FFT_a*length(FFT_a));

%WRITING THE FILE
audiowrite('./Lab2/sound.m4a',audio,audio_freq_samp);
audiowrite('./Lab2/sound_music.m4a',music,audio_freq_samp);
audiowrite('./Lab2/sound_voice.m4a',vocal,audio_freq_samp);

%%%%Part 2
 FFT_ins_diff = FFT_audio_in(:,2)-FFT_audio_in(:,1); %FFT_vocal
 FFT_music_diff= ifftshift(FFT_ins_diff);
 music_diff = real(ifft(FFT_music_diff*length(FFT_music_diff)));
 audiowrite('./Lab2/sound_music_diff.m4a',music_diff,audio_freq_samp);
 
% %%%%Part 3
 music_centroid = spectralCentroid(music,audio_freq_samp);
 music_centroid_diff = spectralCentroid(music_diff,audio_freq_samp);
 vocal_centroid = spectralCentroid(vocal,audio_freq_samp);
 
 figure (2)
 subplot(3,1,1)
 t = linspace(0,size(music,1)/audio_freq_samp,size(music,1));
 plot(t,music)
 hold on
 plot(t,vocal)
legend('Music','Vocal')
ylabel('Amplitude')

subplot(3,1,2)
t = linspace(0,size(music,1)/audio_freq_samp,size(music_centroid,1));
plot(t,music_centroid)
hold on

plot(t,vocal_centroid)
legend('Music','Vocal')
xlabel('Time (s)')
ylabel('Centroid (Hz)')

subplot(3,1,3)
t = linspace(0,size(music_diff,1)/audio_freq_samp,size(music_centroid_diff,1));
plot(t,music_centroid_diff)
hold on
plot(t,vocal_centroid)
legend('Music after taking the channels difference','Vocal')
xlabel('Time (s)')
ylabel('Centroid (Hz)')

figure (3)
subplot(2,1,1)
h1 = histogram(music_centroid,'Normalization','probability');
hold on
h2 = histogram(vocal_centroid,'Normalization','probability');
legend('Music','Vocal')
xlabel('Centroid (Hz)')
ylabel('Probability')

subplot(2,1,2)
h1 = histogram(music_centroid_diff,'Normalization','probability');
hold on
h2 = histogram(vocal_centroid,'Normalization','probability');
legend('Music after taking the channels difference','Vocal')
xlabel('Centroid (Hz)')
ylabel('Probability')

%%%Part 4
figure (4)
subplot(4,1,1)
r = spectralRolloffPoint(audio_in,audio_freq_samp);
plot(t,r)
legend('Stereo--CH1','Stereo--CH2')
ylabel('Rolloff Point (Hz)')
xlabel('Time (s)')

subplot(4,1,2)
r_music = spectralRolloffPoint(music,audio_freq_samp);
plot(t,r_music)
legend('Music')
ylabel('Rolloff Point (Hz)')
xlabel('Time (s)')

subplot(4,1,3)
r_music = spectralRolloffPoint(music_diff,audio_freq_samp);
plot(t,r_music)
legend('Music after taking the channels difference')
ylabel('Rolloff Point (Hz)')
xlabel('Time (s)')

subplot(4,1,4)
r_vocal = spectralRolloffPoint(vocal,audio_freq_samp);
plot(t,r_vocal)
legend('Vocal')
ylabel('Rolloff Point (Hz)')
%ylim([0 15000])
xlabel('Time (s)')
