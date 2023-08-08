function data_table = LongFormatData_TimeBehavContag(condition1, condition2, condition3,N,time)


% Combine your data into a single data matrix and create grouping variables
Y = [condition1(:); condition2(:); condition3(:)]; % Combine data into a single column vector


num_times = numel(time);
num_conditions = 3;

% Create grouping variables for time and condition
% Initialize empty vectors to store time_group and condition_group
time_group = [];
condition_group = [];

for i = 1:num_conditions
    % Repeat the time vector for the current condition
    current_time_group = repmat(time', N(i), 1);
    
    % Repeat the condition label for each time point and observation within the current condition
    current_condition_group = repmat(i, size(current_time_group, 1), 1);
    
    % Append the current time_group and condition_group to the overall vectors
    time_group = [time_group; current_time_group];
    condition_group = [condition_group; current_condition_group];
end

% Create a subject (or trial) identifier variable for each condition
subject_id_condition1 = repmat(1:N(1), size(condition1, 1), 1); % Subject IDs for condition1 
subject_id_condition2 = repmat(1:N(2), size(condition2, 1), 1); % Subject IDs for condition2
subject_id_condition3 = repmat(1:N(3), size(condition3, 1), 1); % Subject IDs for condition3


% Combine subject IDs for all conditions into a single column vector
subject_id = [subject_id_condition1(:); subject_id_condition2(:); subject_id_condition3(:)];

% Create a dataset array to store the data and grouping variables
data_table = table(Y, time_group, condition_group, subject_id, 'VariableNames', {'Y', 'Time', 'Condition', 'Subject'});


end