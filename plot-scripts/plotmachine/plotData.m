function plotData()

req_count_type = 0;

%Hard coded experiment details
details{1} = 'Experiment type : Sequential Write of 45 GB';
details{2} = 'write\_back\_cache : Yes';
details{3} = 'max\_write : Yes , 64MB';
details{4} = 'big\_writes : No';
details{5} = 'max\_bg\_length : 12 (default)';
details{6} = 'congestion\_threshold : 9 (default)';

%Extract different request types
dir = pwd();
fileID = fopen(strcat(dir, '/../raw_data/different_request_types.txt'), 'r');
while (!feof(fileID))
	text_line = fgetl(fileID);
	req_count_type++;
	req_types{req_count_type} = text_line;
endwhile
fclose(fileID);

%Extract different queue lenegths
dir = pwd();
fileID = fopen(strcat(dir, '/../raw_data/queue_lengths'), 'r');
queue_lengths = fscanf(fileID,'%f');
fclose(fileID);
queue_types{1} = 'Background Queue';
queue_types{2} = 'Pending Queue';
queue_types{3} = 'Processing Queue';

%Extract different req's timing values
for i=1:req_count_type
	%bg_queue
	dir = pwd();
	fileID = fopen(strcat(dir, '/../raw_data/', req_types{i}, '_background_distribution.txt'), 'r');
	bg_queue = fscanf(fileID,'%f');
	bg_queue = bg_queue(1:size(bg_queue)(1)-1);
	fclose(fileID);
	%pending_queue
	dir = pwd();
        fileID = fopen(strcat(dir, '/../raw_data/', req_types{i}, '_pending_distribution.txt'), 'r');
        pending_queue = fscanf(fileID,'%f');
	pending_queue = pending_queue(1:size(pending_queue)(1)-1);
        fclose(fileID);
	%processing_queue
	dir = pwd();
        fileID = fopen(strcat(dir, '/../raw_data/', req_types{i}, '_processing_distribution.txt'), 'r');
        processing_queue = fscanf(fileID,'%f');
	processing_queue = processing_queue(1:size(processing_queue)(1)-1);
        fclose(fileID);
	%user_processing_queue
	dir = pwd();
        fileID = fopen(strcat(dir, '/../raw_data/', req_types{i}, '_user_processing_distribution.txt'), 'r');
        user_processing_queue = fscanf(fileID,'%f');
	user_processing_queue = user_processing_queue(1:size(user_processing_queue)(1)-1);
        fclose(fileID);
	big_matrix = [bg_queue, pending_queue, processing_queue, user_processing_queue];
	Matrix{i} = big_matrix;
end
%req_types -> different req names, 
%Matrix    -> details about each req

for i=1:req_count_type
	if (strcmp(req_types{i}, 'FUSE_WRITE'))
		write_index = i;
	end
end

labels{1} = '2ns';
labels{2} = '4ns';
labels{3} = '8ns';
labels{4} = '16ns';
labels{5} = '32ns';
labels{6} = '64ns';
labels{7} = '128ns';
labels{8} = '256ns';
labels{9} = '512ns';
labels{10} = '1us';
labels{11} = '2us';
labels{12} = '4us';
labels{13} = '8us';
labels{14} = '16us';
labels{15} = '32us';
labels{16} = '64us';
labels{17} = '128us';
labels{18} = '256us';
labels{19} = '512us';
labels{20} = '1ms';
labels{21} = '2ms';
labels{22} = '4ms';
labels{23} = '8ms';
labels{24} = '16ms';
labels{25} = '32ms';
labels{26} = '64ms';
labels{27} = '128ms';
labels{28} = '256ms';
labels{29} = '512ms';
labels{30} = '1s';
labels{31} = '2s';
labels{32} = '4s';
labels{33} = '>4s';

Matrix{write_index} = log(Matrix{write_index});
figure;
clf;
h = bar(Matrix{write_index});
text(26, 8, details, 'Color', 'red', 'FontSize', 14);
set(gca, 'XTick', 1:size(Matrix{write_index})(1), 'XTickLabel', labels);
legend('Background queue', 'Pending queue', 'Processing queue', 'User Processing queue');
xlabel('Different Timed buckets', 'fontsize', 15);
ylabel('No. of req. in each bucket (log)', 'fontsize', 15);
title ('FUSE WRITE Req. distribution', 'fontsize', 15);
hold on;
%close();
