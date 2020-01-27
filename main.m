% This is the main file for the homework program. It suppose to setup and
% coordinate all other modules to funciton

clearvars;
close all;

%************* Control Section**********************%

%This section should be the declaration of all the available variable 

seed = uint32(sum(clock));

byte_count = 10000; % The number of random bytes generated

modulation_scheme = "16QAM"; % Choose from {QPSK,16QAM,256QAM}

carrier_count = 64; % The number of subcarriers used, usually referred to as N

cyclic_prefix = 4; % The length of cyclic prefix, in terms of sample. 

channel_response = [1,0.1,0.2,0.4,0.5,0.6];

SNR = 100; % in dB

%************Control Section Ends******************%




%************Initialize some classes used *********%

modulator_class = modulator(modulation_scheme);

ofdm_modulator_class = ofdm_modulator(carrier_count,cyclic_prefix);

channel_effect_class = channel_effect(channel_response,SNR);

%***********Initialize ends************************%


%***********Compute Region************************%

%Generate Input
input_vector=generate_input(byte_count,seed);

%Baseband modulation
complex_symbols = modulator_class.modulate(input_vector); 

%OFDM modulation
ofdm_samples=ofdm_modulator_class.ofdm_modulation(complex_symbols);

%Apply channel effect

noised_samples = channel_effect_class.apply_channel_effect(ofdm_samples);

%OFDM demodulation
demodulated_ofdm_symbols=ofdm_modulator_class.ofdm_demodulation(noised_samples,channel_effect_class.channel_response);

%Baseband demodulation
output_vector = modulator_class.demodulate(demodulated_ofdm_symbols);

%Cut down the output to fit the input
output_vector= output_vector(1:byte_count);

%********Compute Region Ends************************%


% Constallation 

plot(2);
hold on;

% For reference input, we plot 2 times the amount of signal modulation
% order to hopefully exhaust all the possible constallation.

%Pick the symbols to plot on constellation. This amount is chosen as the
%minumum of 200,5 times modulation order and the total trasmitted symbols.

plotting_range = randi(numel(complex_symbols),[1,min([numel(complex_symbols),modulator_class.modulation_order*5,2e2])]);

scatter(real(complex_symbols(plotting_range)),imag(complex_symbols(plotting_range)),100,'x');

scatter(real(demodulated_ofdm_symbols(plotting_range)),imag(demodulated_ofdm_symbols(plotting_range)),20,'filled');

title("Constallation");

ax = gca;

ax.XAxisLocation='origin';

ax.YAxisLocation='origin';

axis([-6,6,-6,6]);
