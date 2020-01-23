classdef channel_effect
    %CHANNEL_EFFECT This class applies channel effect to 
    %   This channel convolutes input samples with channel effect and then
    %   adding AWGN. Note that the noise power is calculated based on the
    %   average signal power. In the scenario where we have limited input,
    %   or heavily biased samples, this may be inaccurate.
    
    properties
        channel_response;% Time domain response
        SNR; % Signal to Noise Ratio. Measured in dB
    end
    
    methods
        function obj = channel_effect(channel_response_input,SNR_input)
            %CHANNEL_EFFECT Defines a channel
            %   The SNR must be in dB.
            
            assert((size(channel_response_input,1)==1),"channel response must be a vector");
            obj.channel_response = channel_response_input;
            obj.SNR=SNR_input;
        end
        
        function distorted_time_samples = apply_channel_effect(obj,time_samples,seed)
            %apply_channel_effect Apply channel effect to specific time
            %samples
            %   Note that signal power is averaged over all the samples.
            
            
            %Perform the convolution
            
            convoluted_samples = conv(time_samples,obj.channel_response);
            
            %Note that we would have to make sure the output sample has the
            %same amount of input samples.
            
            convoluted_samples = convoluted_samples(1:numel(time_samples));
            
            %Then we apply the AGWN
            
            signal_power=(convoluted_samples*convoluted_samples')/numel(convoluted_samples);
            
            snr = 10^(obj.SNR/10); % linear scale snr
            
            noise_power = signal_power/snr;
            
            % Setup seed
            
            if nargin == 3
                engine = rng(seed);
            end
            
            %The white noise is calculated as half in in phase and half in
            %quadrature
            awgn = sqrt(noise_power/2)*randn(1,numel(convoluted_samples))+1i*sqrt(noise_power/2)*randn(1,numel(convoluted_samples));
            
            distorted_time_samples=convoluted_samples+awgn;
            
        end
    end
end

