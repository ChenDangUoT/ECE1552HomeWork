classdef modulator
    %MODULATOR This is the object for modulating and demodulating symbols
    %   This modulator modulates and demodulates uint8 vectors into complex
    %   symbols. This only supports QAM like modulation and any leftover
    %   bits would be padded with zero. This modulator and demodulator is
    %   implenmented using Gray code and its MATALB implementation bin2gray
    
    
    properties(SetAccess=private)
        modulation_scheme;
        %The name of modulation scheme,we plan to QPSK,16QAM,and 256 QAM
        %available.
        modulation_order;
        %This is the modulation order corresponding to the modulation
        %scheme.
    end
    
    methods
        function obj = modulator(input_modulation_scheme)
            %MODULATOR This will construct a modulator class using the
            %desired modulation scheme. If no supported scheme is
            %inputted(which should not happen), this will default to 16QAM
            
            if(input_modulation_scheme~="QPSK"&&input_modulation_scheme~="16QAM"&&input_modulation_scheme~="256QAM")
                warning("Modulation Scheme %s is not supported,using 16QAM",input_modulation_scheme);
                obj.modulation_scheme="16QAM";
                obj.modulation_order = 16;
                return;
            end
            
            obj.modulation_scheme=input_modulation_scheme;
            
            switch(input_modulation_scheme)
                case("QPSK")
                    obj.modulation_order =4;
                case("16QAM")
                    obj.modulation_order=16;
                case("256QAM")
                    obj.modulation_order=256;
            end
            
            
        end
        
        function complex_symbols = modulate(obj,input_vector)
            %MODULATE this function modulates the input vector
            %   This function modulates input vector into complex symbols.
            %   This function will only accept uint8 vectors. Any
            %   leftover(e.g. 64QAM but we have 8 bits, thus 2 bits
            %   leftover) will be padded with zero.
            
            bits_per_symbol = log2(obj.modulation_order);
            
            if(mod(8,bits_per_symbol)==0)
                
                symbol_per_uint8 = 8/bits_per_symbol;
                
                %Generating the mask. 
                %2^(bits_per_symbol)-1 is all ones.
                masks = bitshift(2^(bits_per_symbol)-1,(symbol_per_uint8-1:-1:0).*bits_per_symbol);
                
                %Convert it to uint8 so that bitand would not complain
                masks = uint8(masks);
                
                %Applying the mask
                %Note that
                %repmat(input_vector,symbol_per_uint8,1) generates copies
                %and make them into a matrix
                %bitand then apply the mask to every row(copy) of input_vector
                masked_input=bitand(repmat(input_vector,symbol_per_uint8,1),masks');
                
                %Then the value is right shifted to fit to qammod.
                for i = 1:symbol_per_uint8
                    masked_input(i,:)=bitshift(masked_input(i,:),-1*(symbol_per_uint8-i)*bits_per_symbol);
                end
                
                
                
                %Reshape to a single vector
                masked_input = reshape(masked_input,1,numel(masked_input));
                
                %Perform the actual modulation
                complex_symbols=qammod(masked_input,obj.modulation_order);
            else
                % TODO, implement 64QAM that requires more complicated
                % modulation scheme
                error("Modulatation scheme %s is not supported",obj.modulation_scheme);
                
            end
        end
        
        function output_vector= demodulate(obj,complex_symbols)
            %DEMODULATE This funciton demodulates the input complex symbols
            %using informaiont stored in this modulator. 
            %   Warning: Do not use complex symbols that are not from this modulator.
            
            bits_per_symbol = log2(obj.modulation_order);
            
            if(mod(8,bits_per_symbol)==0)
                
                symbol_per_uint8 = 8/bits_per_symbol;
                
                % Demodulate
                demodulated_symbol = qamdemod(complex_symbols,obj.modulation_order);
                
                % Reshape the vector so that a single column corresponds to
                % a single unit8 (a byte word)
                demodulated_symbol = reshape(demodulated_symbol,symbol_per_uint8,numel(demodulated_symbol)/symbol_per_uint8);
                 
                % Perform the left shift to recover the byte sized data
                for i = 1:symbol_per_uint8
                    demodulated_symbol(i,:)=bitshift(demodulated_symbol(i,:),(symbol_per_uint8-i)*bits_per_symbol);
                end
                
                % Aggregate over columns
                output_vector = sum(demodulated_symbol,1);
                
                % Convert to uint8
                output_vector = uint8(output_vector);
            
            else 
                % TODO, implement 64QAM that requires more complicated
                % demodulation scheme
                error("Modulatation scheme %s is not supported",obj.modulation_scheme);
            end
        end
    end
end

