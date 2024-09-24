%% Run once on each new computer to allow V3D and MATLAB to communicate
% comserver('register','User','current')
%%

% Ensure all files are closed and clear variables
fclose('all');
close all;

% Participant information
subject_session = '01-1';
sex = 'F';
weight = '70';    % Weight in kg (as string)
height = '1.70';  % Height in meters (as string)

% Conditions to process
conditions = {'Condition1', 'Condition2', 'Condition3', 'Condition4'};

% Base paths (adjusted to be generic)
visual3d_base_path = "C:\FakePath\Visual3D";
data_base_path = "C:\FakePath\Data";

% Loop through each condition
for i = 1:length(conditions)
    condition = conditions{i};
    fclose('all');
    
    % Paths to Visual3D pipelines (read-only and write versions)
    v3d_pipeline_read1 = fullfile(visual3d_base_path, "TreadmillPipelineRead1.v3s");
    v3d_pipeline_write1 = fullfile(visual3d_base_path, "TreadmillPipelineWrite1.v3s");
    
    % Read the original Visual3D pipeline template (Pipeline #1 - Processes to gait events)
    fid = fopen(v3d_pipeline_read1, 'r');
    v3d_pipeline_text1 = fscanf(fid, '%c');
    fclose(fid);
    
    % Define folder paths
    subject_folder = fullfile(data_base_path, subject_session);
    data_folder = fullfile(subject_folder, condition);
    
    % Replace placeholders with actual values in the pipeline text
    v3d_pipeline_text1 = strrep(v3d_pipeline_text1, 'MAT_REPLACE1', ['"' subject_session '"']); % Subject and session
    v3d_pipeline_text1 = strrep(v3d_pipeline_text1, 'MAT_REPLACE2', ['"' subject_folder '"']); % Subject folder
    v3d_pipeline_text1 = strrep(v3d_pipeline_text1, 'MAT_REPLACE3', ['"' data_folder '"']); % Data folder
    v3d_pipeline_text1 = strrep(v3d_pipeline_text1, 'MAT_REPLACE4', weight); % Participant's weight
    v3d_pipeline_text1 = strrep(v3d_pipeline_text1, 'MAT_REPLACE5', height); % Participant's height
    v3d_pipeline_text1 = strrep(v3d_pipeline_text1, 'MAT_REPLACE6', condition); % Condition
    v3d_pipeline_text1 = strrep(v3d_pipeline_text1, 'MAT_REPLACE7', sex); % Participant's sex
    
    % Write the modified pipeline to a new file (Pipeline #1)
    fid = fopen(v3d_pipeline_write1, 'w');
    fprintf(fid, '%c', v3d_pipeline_text1);
    fclose(fid);
    
    % Run the Visual3D pipeline (Pipeline #1)
    dos_command = ['"' fullfile('C:\Program Files\Visual3D x64', 'Visual3D.exe') '" /s "' v3d_pipeline_write1 '" &'];
    dos(dos_command);
    pause(150);  % Wait for Visual3D pipeline to finish processing
    
    % Call MATLAB function to remove steps with bad force plate data from Visual3D 'Events'
    V3D_steps('Events');
    pause(5);  % Ensure corrected 'Events' are saved before running the next pipeline
    
    % Paths to Visual3D pipelines (Pipeline #2 - Reads in corrected 'Events' and processes to dependent variables)
    v3d_pipeline_read2 = fullfile(visual3d_base_path, "TreadmillPipelineRead2.v3s");
    v3d_pipeline_write2 = fullfile(visual3d_base_path, "TreadmillPipelineWrite2.v3s");
    
    % Read the original Visual3D pipeline template (Pipeline #2)
    fid = fopen(v3d_pipeline_read2, 'r');
    v3d_pipeline_text2 = fscanf(fid, '%c');
    fclose(fid);
    
    % Replace placeholders with actual values in the pipeline text (Pipeline #2)
    v3d_pipeline_text2 = strrep(v3d_pipeline_text2, 'MAT_REPLACE1', ['"' subject_session '"']);
    v3d_pipeline_text2 = strrep(v3d_pipeline_text2, 'MAT_REPLACE2', ['"' subject_folder '"']);
    v3d_pipeline_text2 = strrep(v3d_pipeline_text2, 'MAT_REPLACE3', ['"' data_folder '"']);
    v3d_pipeline_text2 = strrep(v3d_pipeline_text2, 'MAT_REPLACE4', weight);
    v3d_pipeline_text2 = strrep(v3d_pipeline_text2, 'MAT_REPLACE5', height);
    v3d_pipeline_text2 = strrep(v3d_pipeline_text2, 'MAT_REPLACE6', condition);
    v3d_pipeline_text2 = strrep(v3d_pipeline_text2, 'MAT_REPLACE7', sex);
    
    % Write the modified pipeline to a new file (Pipeline #2)
    fid = fopen(v3d_pipeline_write2, 'w');
    fprintf(fid, '%c', v3d_pipeline_text2);
    fclose(fid);
    
    % Run the Visual3D pipeline (Pipeline #2)
    dos_command = ['"' fullfile('C:\Program Files\Visual3D x64', 'Visual3D.exe') '" /s "' v3d_pipeline_write2 '" &'];
    dos(dos_command);
    pause(90);  % Wait for Visual3D pipeline to finish processing
end
