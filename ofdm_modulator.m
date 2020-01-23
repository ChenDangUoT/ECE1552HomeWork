classdef ofdm_modulator
    %ODFM_MODULATOR This is the OFDM modulator that modulates complex
    %symbols into ofdm complex samples and demodulate those samples back
    %into symbols
    %   Note that this modulator does not perform up conversion nor D/A.
    
    properties(SetAccess=private)
        N;
        cyclic_prefix;        
    end
    
    methods
        function obj = ofdm_modulator(FFT_size,cyclic_prefix_length)
            %ODFM_MODULATOR Initiate the odfm modulator
            %   Note that the FFT size must be a power of 2 and between 16
            %   to 256( inclusive on both).
            
            assert((2^round(log2(FFT_size))==FFT_size)&&(FFT_size<=256)&&(FFT_size>=16),'FFT size %d is not accepted',FFT_size);
            
            obj.N=FFT_size;
            obj.cyclic_prefix=cyclic_prefix_length;
        end
        
        function complex_samples = ofdm_modulation(obj,complex_symbols)
            %ofdm_modulation Performs OFDM modulation
            %   Note that:
            %  
            %   This modulator only operates on sample level. This means
            %   there is no concept of carrier frequency
            %
            %   Zero padding would be used.
            
            %We append zeros if necessary
            %This assumes the input is a vector.
            input_size = numel(complex_symbols);
            complex_symbols_padded = [complex_symbols,zeros(1,obj.N-mod(input_size,obj.N))];
            
            %Then we prepare the complex_symbol_padded into a matrix with size a times
            %N. This means that each ROW is a set of input symbols to transmit

            %Note that to work around the reshape, we first let each column to be the
            %set of input symbols and then transpose.
            complex_symbols_padded = reshape(complex_symbols_padded,obj.N,numel(complex_symbols_padded)/obj.N);

            complex_symbols_padded = transpose(complex_symbols_padded);
            
            %Performs the iFFT
            complex_samples = ifft(complex_symbols_padded,obj.N,2);
            
            %Find the cylic prefix
            cyclic_prefix_samples = complex_samples(:,obj.N-obj.cyclic_prefix+1:obj.N);
            
            %Attach them
            complex_samples=[cyclic_prefix_samples,complex_samples];
            
            %Reshape it to a vector
            complex_samples = reshape(transpose(complex_samples),1,numel(complex_samples));
        end
        
        function complex_symbols = ofdm_demodulation(obj,complex_samples,channel_response)
            %ofdm_demodulation demodulates time samples 
            %   Note that: If the channel response is not present, we would
            %   not use the channel response,hence not exploiting the
            %   cyclic prefix
            
            %First we transform the complex samples into a matrix whose ROW
            %is corresponds to 1 sample.
            
            complex_samples = reshape(complex_samples,obj.N+obj.cyclic_prefix,numel(complex_samples)/(obj.N+obj.cyclic_prefix));
            
            complex_samples = transpose(complex_samples);
            
            %Then we remove the cyclic prefix
            
            samples_no_prefix = complex_samples(:,obj.cyclic_prefix+1:obj.N+obj.cyclic_prefix);
        
            %Then if the channel_response is present, we perform frequency
            %domain equalization
            
            if nargin==3
                
                frequency_response = fft(samples_no_prefix,obj.N,2);
            
                channel_frequency_response=fft(channel_response,obj.N);
            
                frequency_response=frequency_response./channel_frequency_response;
                
                samples_no_prefix = ifft(frequency_response,obj.N,2);
            
            end
            
            %Then we perform FFT here, in an ideal scenario, this would
            %recover the transmitted complex symbols
            
            complex_symbols=fft(samples_no_prefix,obj.N,2);
            
            %Then we reorder them to a single vector
            
            complex_symbols=reshape(transpose(complex_symbols),1,numel(complex_symbols));
        
        end
        
    end
end

