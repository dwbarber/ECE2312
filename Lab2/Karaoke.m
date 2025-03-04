% MATLAB Script: Karaoke-Style Audio Recording
% This script records audio from a microphone while playing a backing track.

% Clear workspace and close all figures
clear;
close all;
clc;

% Parameters
fs = 44100; % Sampling rate (Hz)
outputFileName = 'karaoke_recording.mp3'; % Output file name

% Initialize audio player for the backing track
% Replace 'backing_track.wav' with the path to your backing track file
[backingTrack, backingFs] = audioread('music_AI.mp3');

player = audioplayer(backingTrack, fs);

% Initialize audio recorder for the microphone input
recorder = audiorecorder(fs, 16, 2); % 16-bit, stereo

% Start playing the backing track
disp('Playing backing track...');
play(player);       

% Start recording from the microphone
    disp('Recording...');
    recordblocking(recorder, size(backingTrack,1)/fs);
    
    % Stop recording and playing
    stop(recorder);
    stop(player);
    
    % Retrieve the recorded data
    disp('Recording finished.');
    recordedAudio = getaudiodata(recorder);
    player1 = audioplayer(recordedAudio, fs);

    % Normalize the recorded audio to avoid clipping
    recordedAudio = recordedAudio / max(abs(recordedAudio(:)));
    
    % Mix the recorded audio with the backing track
    mixedAudio = backingTrack + recordedAudio;
    
    % Normalize the mixed audio to avoid clipping
    mixedAudio = mixedAudio / max(abs(mixedAudio(:)));
    
    % Save the mixed audio to a file
    audiowrite(outputFileName, mixedAudio, fs);
    disp(['Mixed audio saved as ' outputFileName]);

% Playback the mixed audio (optional)
disp('Playing back the mixed audio...');
sound(mixedAudio, fs);
