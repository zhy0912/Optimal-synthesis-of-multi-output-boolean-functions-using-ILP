addpath(genpath("./../src/"))

rng('shuffle')

MAX_TEST_NUMBER = 100;
TIMEOUT = 2 * 60;

% if this variables are not set, set them to default values
if exist('outputsNumber','var') ~= 1 ; outputsNumber = 5 ; end
if exist('inputsNumber','var') ~= 1 ; inputsNumber = 4 ; end

biggest_value = 2^inputsNumber;

for test = 1:MAX_TEST_NUMBER 
    
    outputs = cell(outputsNumber, 1); 
    one_out_cost = 0;

    % one output synthesis

    for i = 1:outputsNumber
        
        p = randperm(biggest_value);

        minterms_count = round(biggest_value * rand(1,1));
        
        while minterms_count < 1   
            minterms_count = round(biggest_value * rand(1,1));
        end

        dontcares_count = round(biggest_value * rand(1,1));
        
        while (minterms_count + dontcares_count) > biggest_value   
            dontcares_count = round(biggest_value * rand(1,1));
        end

        p_1 = sort(p(1:minterms_count));
        
        if minterms_count < biggest_value
            p_2 = sort(p(minterms_count + 1: minterms_count + dontcares_count));
        else
            p_2 = [];
        end

        out = {p_1, p_2}; 

        [implicants_k, v, timedOut] = oneOutputSynthesis( ...
            out{1}, ...
            out{2}, ...
            InputsNumber = inputsNumber, ...
            Timeout = TIMEOUT ...
        );

        if timedOut ; break ; end
        

        if ~ synteshisCheck(implicants_k, out{1}, out{2})
            disp("ERROR: single output synthesis")
        end

        one_out_cost = one_out_cost + v;

        outputs{i} = out;
    end 

    if timedOut ; fprintf('%d timed_out\n', test) ; continue ; end

    % multiple output synthesis
    
    [implicants, multiple_out_cost, timedOut] = multipleOutputSynthesis( ...
        inputsNumber, ...
        outputs, ...
        Timeout = TIMEOUT ...
    );
        
    if timedOut ; fprintf('%d timed_out\n', test) ; continue ; end
    
    for j =1:length(implicants)
        out = outputs{j};
        if ~ synteshisCheck(implicants{j}, out{1}, out{2})
            disp("ERROR: multiple output synthesis")
        end
    end
    
end

disp("TEST PASSED")
