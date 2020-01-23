%This is the function file for generating input, all the input genearation
%method are stored here. The input function should take at least one input,
%which would be the number of bytes to generate. And generate output in an
%array(vector) of unit8 numbers.


function [output_array] = generate_input(number_of_bytes,seed)
%GENERATE_INPUT This function generates input for our modulator
%   This function generates input at random. The function will generate
%   input in an array of unit8(1 byte) numbers. This function also has a
%   seeding capability. If this seed is not input, we would use a default
%   seed from time

% Setup Seed

if nargin <2
    seed=5849;
end

engine_state = rng(seed);

rng(engine_state);

output_array = randi(255,1,number_of_bytes,'uint8');

end
