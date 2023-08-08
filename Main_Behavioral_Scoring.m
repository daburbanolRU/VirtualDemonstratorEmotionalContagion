

clc
close all
clear all

exp_time = 10*60;  % total experimental time in seconds
Nc = 3;            % number of conditions: Control, HG, LG
c0 = 38.74;        % water height in cm
framerate = 30;    % Frame rate
dt = 1/framerate;  % delta of time
coun = 1;

N_frames = exp_time*framerate;



excelFileName = 'RawData.xlsx';              % Define the Excel file name with extension
sheetNames = {'Sheet1', 'Sheet2', 'Sheet3'}; % Specify sheet names
tables = cell(1, numel(sheetNames));         % Initialize an empty cell array to store tables

%===============================================================
%=======  Load data from each sheet into separate tables
%===============================================================


for i = 1:numel(sheetNames)
    tables{i} = readtable(excelFileName, 'Sheet', sheetNames{i});
end

% Assign the loaded tables to individual variables
table1 = tables{1}; % Control condition
table2 = tables{2}; % High Geotaxis condition
table3 = tables{3}; % Low Geotaxis condition

%===============================================================
%=======  Main loop start
%===============================================================
for condition=1:Nc

    for trial=1:10

        nx = ['X',num2str(trial)]; % table identifier of X data in a table
        ny = ['Y',num2str(trial)]; % table identifier of X data in a table

        switch condition
            case 1
                X = table1.(nx);
                Y = table1.(ny);
            case 2
                X = table2.(nx);
                Y = table2.(ny);
            case 3
                X = table3.(nx);
                Y = table3.(ny);
        end


        %===============================================================
        %======= Fish behavioral scoring
        %===============================================================

        %======= velocities along x and y components
        vx = diff(X)./dt;  % velocity component in x
        vy = diff(Y)./dt;  % velocity component in y
        vmax = 100; % cap on velocities to attenuate noise from derivative computations
        vx(abs(vx)>vmax) = NaN; vx = fillmissing(vx,'next');
        vy(abs(vy)>vmax) = NaN; vy = fillmissing(vy,'next');
        V = sqrt(vx.^2 + vy.^2); % linear speed

        %======= accelerations
        ax = diff(vx)./dt;  % acceleration component in x
        ay = diff(vy)./dt;  % acceleration component in y
        At = diff(V)./dt;   % Tangential acceleration: quantify the extent of  stop-and-go  motions

        %======= Angular acceleration
        [costheta,sintheta,heading,w] = heading_turnrate_sahana(X,Y,dt);

        %======= Latency
        yd = c0/3; % divide tank in 3 sections,
        Y_div = Y< yd; % instances when fish visits the bottom of the tank
        consecutive_counts = Latency2Bottom(Y_div)*dt; % time duration of intervals spent at the bottom

        %======= Average over a time window
        d = 2*60*framerate; % size of the time window 2min
        c = 1;              % counter
        for k=1:d:length(Y)

            % Absolute linear Acceleration
            Acc_timew(c,1) = mean(abs(At(k:k+d-3)));

            % absolute turn rate
            Angular_speedw(c,1) = mean(abs(w(k:k+d-3)));

            % time spent at the bottom
            Y_div_w = Y_div(k:k+d-1)*dt; % instances when fish visits the bottom of the tank
            Time_spent_bott(c,1) = sum(Y_div_w);

            % linear speed
            Linear_speed(c,1) = mean(V(k:k+d-2));

            c = c + 1;

        end

        %========== output variables
        M_time_Tim(:,trial) = Time_spent_bott; % time spent at the bottom
        M_time_V(:,trial) = Linear_speed; % time spent at the bottom
        M_time_A(:,trial) = Acc_timew; % acceleration
        M_time_w(:,trial) = Angular_speedw; % angular speed
       

    end

    switch condition
        case 1
            Time_Bot_C = M_time_Tim;
            Speed_C = M_time_V;
            Accel_C = M_time_A;
            TurnRate_C = M_time_w;
        case 2
            Time_Bot_HG = M_time_Tim;
            Speed_HG = M_time_V;
            Accel_HG = M_time_A;
            TurnRate_HG = M_time_w;
        case 3
            Time_Bot_LG = M_time_Tim;
            Speed_LG = M_time_V;
            Accel_LG = M_time_A;
            TurnRate_LG = M_time_w;
    end
end

vtime = [2,4,6,8,10]; % vector of time bins
data_table_time1 = LongFormatData_TimeBehavContag(Time_Bot_C,Time_Bot_HG,Time_Bot_LG,[10 10 10],vtime);
data_table_time2 = LongFormatData_TimeBehavContag(Speed_C,Speed_HG,Speed_LG,[10 10 10],vtime);
data_table_time3 = LongFormatData_TimeBehavContag(Accel_C,Accel_HG,Accel_LG,[10 10 10],vtime);
data_table_time4 = LongFormatData_TimeBehavContag(TurnRate_C,TurnRate_HG,TurnRate_LG,[10 10 10],vtime);


writetable(data_table_time1,'Data_for_R_Time_EmoCont_Time_Bottom.xlsx')
writetable(data_table_time2,'Data_for_R_Time_EmoCont_Speed.xlsx')
writetable(data_table_time3,'Data_for_R_Time_EmoCont_Acceleration.xlsx')
writetable(data_table_time4,'Data_for_R_Time_EmoCont_AbsTurnRate.xlsx')


