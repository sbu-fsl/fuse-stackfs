function automatePlot()
max_writes = [32768;65536;131072;262144;524288;1048576;2097152;4194304;8388608;16777216;33554432;67108864];
iterations = [1;2;4;8;16;32;64;128;256;512;1024;2048;4096;8192;16384;32768];

dir = '/Users/Bharath/Downloads/FUSE/raw_data/Stat-files-WRITEBACK/';
%details{1} = 'Experiment type : Sequential Write';
details{1} = 'Write Back Cache : Yes';
details{2} = 'Max Write : %s, %d pages';
details{3} = 'Iterations : %d of 1 MB I/O';
details{4} = 'Big Writes : No';
details{5} = 'Max Bg Length : 12 (default)';
details{6} = 'Congestion Threshold : 9 (default)';

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

for i=1:33
	if mod(i,2)==0 || mod(i, 3)==0
		temp_labels{i} = '';
	else
		temp_labels{i} = labels{i};
	end
end

for i=1:10
	for j=16:size(iterations)(1)
		max_write = max_writes(i);
		if max_write < 1048576
			details{2} = sprintf(details{2}, sprintf('%d KB', max_write/1024), max_write/4096);
		else
			details{2} = sprintf(details{2}, sprintf('%d MB', max_write/(1024*1024)), max_write/4096);
		end
		iteration = iterations(j);
		details{3} = sprintf(details{3}, iteration);
		req_count_type = 0;
		%Get the different request types	
		filename = strcat(dir, sprintf('Stat-files-%d-%d-Final/different_request_types.txt', max_write, iteration));
		fileID = fopen(filename, 'r');
		while (!feof(fileID))
			text_line = fgetl(fileID);
			req_count_type++;
			req_types{req_count_type} = text_line;
		endwhile
		fclose(fileID);

		%Escaping the request type names
		for k=1:req_count_type
        		if (strcmp(req_types{k}, 'FUSE_WRITE'))
                		write_index = k;
        		end
			print_req_types{k} = req_types{k}(6:size(req_types{k})(2));
		end
		%Extract different req's timing values (from Final)
		Matrix_count = [];
		for i=1:req_count_type
        		%bg_queue
			filename = strcat(dir, sprintf('Stat-files-%d-%d-Final/', max_write, iteration), req_types{i}, '_background_distribution.txt');
        		fileID = fopen(filename, 'r');
        		bg_queue = fscanf(fileID,'%f');
			bg_queue_count = bg_queue(size(bg_queue)(1));
        		bg_queue = bg_queue(1:size(bg_queue)(1)-1);
        		fclose(fileID);
        		%pending_queue
			filename = strcat(dir, sprintf('Stat-files-%d-%d-Final/', max_write, iteration), req_types{i}, '_pending_distribution.txt');
			fileID = fopen(filename, 'r');
        		pending_queue = fscanf(fileID,'%f');
			pending_queue_count = pending_queue(size(pending_queue)(1));
        		pending_queue = pending_queue(1:size(pending_queue)(1)-1);
        		fclose(fileID);
        		%processing_queue
			filename = strcat(dir, sprintf('Stat-files-%d-%d-Final/', max_write, iteration), req_types{i}, '_processing_distribution.txt');
        		fileID = fopen(filename, 'r');
        		processing_queue = fscanf(fileID,'%f');
			processing_queue_count = processing_queue(size(processing_queue)(1));
        		processing_queue = processing_queue(1:size(processing_queue)(1)-1);
        		fclose(fileID);
        		%user_processing_queue
			filename = strcat(dir, sprintf('Stat-files-%d-%d-Final/', max_write, iteration), req_types{i}, '_user_processing_distribution.txt');
        		fileID = fopen(filename, 'r');
        		user_processing_queue = fscanf(fileID,'%f');
			user_processing_queue_count = user_processing_queue(size(user_processing_queue)(1));
        		user_processing_queue = user_processing_queue(1:size(user_processing_queue)(1)-1);
        		fclose(fileID);
        		big_matrix = [bg_queue, pending_queue, processing_queue, user_processing_queue];
			big_matrix_count = [bg_queue_count, pending_queue_count, processing_queue_count, user_processing_queue_count];
			Matrix_count = [Matrix_count; big_matrix_count];
        		Matrix{i} = big_matrix;
		end

		%Write Req in different queues (from 2 ns to 4s)
		details{7} = 'Total Write Requests : %d';
                details{7} = sprintf(details{7}, Matrix_count(write_index, 2));
		figure;
		clf;
		hold on;
		h = bar(log(Matrix{write_index}));
		axis([0 size(Matrix{write_index})(1)+1 0 max(max(log(Matrix{write_index})))*1.5]);
		ybuff=0.1;
                for i=1:length(h)
                	XDATA=get(get(h(i),'Children'),'XData');
			YDATA=get(get(h(i),'Children'),'YData');
                        for j=1:size(XDATA,2)
                        	x=XDATA(1,j)+(XDATA(3,j)-XDATA(1,j))/2;
                                y=YDATA(2,j)+ybuff;
                                t=[num2str(e.^YDATA(2,j)) ,''];
				if y != -Inf
                                	text(x,y,t,'Color','k','HorizontalAlignment','left','Rotation',90, 'FontSize', 6);
				end
                        end
                end
		text(0, (max(max(log(Matrix{write_index})))) * 1.3, details, 'Color', 'red', 'FontSize', 12);
		set(gca, 'XTick', 1:size(Matrix{write_index})(1), 'XTickLabel', temp_labels);
		legend('Background queue', 'Pending queue', 'Processing queue', 'User Processing queue');
		xlabel('Different Timed buckets', 'fontsize', 15);
		ylabel('No. of req. in each bucket (log)', 'fontsize', 15);
		title ('FUSE WRITE Req. distribution', 'fontsize', 15);
		hold off;
                filename = strcat(dir, sprintf('Stat-files-%d-%d-Final/Write_req_distribution.png', max_write, iteration));
                print(filename, "-dpng");
                close();

		%Total Request distribution (after experiment, Final)
		figure;
		clf;
		hold on;
		temp_Matrix_count = log(Matrix_count);
		h = bar(temp_Matrix_count);
		axis([0 req_count_type+1, 0 (max(max(temp_Matrix_count)) * 1.4 )]);
		for i=1:req_count_type
			text(i, temp_Matrix_count(i, 2)+0.2, num2str(Matrix_count(i, 2)), 'Color','k','HorizontalAlignment','center','VerticalAlignment', 'bottom', 'FontSize', 14);
		end
		text(write_index+1, temp_Matrix_count(write_index, 2), details, 'Color', 'red', 'FontSize', 14);
		set(gca, 'XTick', 1:req_count_type, 'XTickLabel', print_req_types);
		legend('Background queue', 'Pending queue', 'Processing queue', 'User Processing queue');
		xlabel('Different Request Types', 'fontsize', 15);
		ylabel('Total No. of requests in each queue (log)', 'fontsize', 15);
		title ('Total Request Count Distribution', 'fontsize', 15);
		hold off;
		filename = strcat(dir, sprintf('Stat-files-%d-%d-Final/Total_req_count_distribution.png', max_write, iteration));
		print(filename, "-dpng");
		close();


		%Extracting Each Write Req's num pages details
		filename = strcat(dir, sprintf('Stat-files-%d-%d-Final/writeback_req_sizes', max_write, iteration));
		req_sizes = importdata(filename);
		[U, ~, J] = unique(req_sizes);
		req_sizes =[U, accumarray(J, 1)];
		figure;
                clf;
                hold on;
		temp_req_sizes = log(req_sizes(:, 2));
		bar(temp_req_sizes);
		axis([0 (size(temp_req_sizes)(1))+1, 0 (max(temp_req_sizes) * 1.4 )]);
		for i=1:size(req_sizes)(1)
			text(i, (temp_req_sizes(i))+0.1, num2str(req_sizes(i, 2)), 'Color','k','HorizontalAlignment','center','VerticalAlignment', 'bottom', 'FontSize', 10);
		end
		details{7} = 'Total Write Requests : %d';
		details{7} = sprintf(details{7}, sum(req_sizes(:, 2)));
		text((size(temp_req_sizes)(1))*0.5, (max(temp_req_sizes)) * 1.2, details, 'Color', 'red', 'FontSize', 14);
		for i=1:size(req_sizes(:, 1))(1)
			if mod(i, 3) == 0
				req_sizes_labels{i} = num2str(req_sizes(:, 1)(i));
			else
				req_sizes_labels{i} = '';
			end
		end
		set(gca, 'XTick', 1:size(req_sizes)(1), 'XTickLabel', req_sizes_labels);
		xlabel('Different Pages (in sizes) packed inside a single Write Request', 'fontsize', 15);
                ylabel('Total Count of Write Requests (log)', 'fontsize', 15);
                title ('FUSE WRITE Request Size Distribution', 'fontsize', 15);
		hold off;
		filename = strcat(dir, sprintf('Stat-files-%d-%d-Final/Write_req_size_distribution.png', max_write, iteration));
		print(filename, "-dpng");
		close();

		%Extract queue details from all the running time of experiment(5secs to Final)
		queue_stats = [];
		max_queue_stats = [];
		count = 0;
		for secs=5:5:1000 %hardcoded_as_of_now
			filename = strcat(dir, sprintf('Stat-files-%d-%d-%d/queue_lengths', max_write, iteration, secs));
			if exist(filename, 'file')
				temp_queue_stats = importdata(filename);
				temp_max_queue_stats = [temp_queue_stats(3), temp_queue_stats(6), temp_queue_stats(9)];
				temp_queue_stats = [temp_queue_stats(1), temp_queue_stats(2), temp_queue_stats(4), temp_queue_stats(5), temp_queue_stats(7), temp_queue_stats(8)];
				queue_stats = [queue_stats; temp_queue_stats];
				max_queue_stats = [max_queue_stats; temp_max_queue_stats];
				count = count+1;
				queue_labels{count} = sprintf('%ds', secs);
			else
				filename = strcat(dir, sprintf('Stat-files-%d-%d-Final/queue_lengths', max_write, iteration));
				temp_queue_stats = importdata(filename);
                                temp_max_queue_stats = [temp_queue_stats(3), temp_queue_stats(6), temp_queue_stats(9)];
                                temp_queue_stats = [temp_queue_stats(1), temp_queue_stats(2), temp_queue_stats(4), temp_queue_stats(5), temp_queue_stats(7), temp_queue_stats(8)];
                                queue_stats = [queue_stats; temp_queue_stats];
                                max_queue_stats = [max_queue_stats; temp_max_queue_stats];
                                count = count+1;
                                queue_labels{count} = 'Final';
				break;
			end
		end
		%Total queue lengths
		figure;
                clf;
                hold on;
		h = bar(queue_stats);
		axis([0 size(queue_stats)(1)+1 0 max(max(queue_stats))*1.5]);
		ybuff=2;
		for i=1:length(h)
			if mod(i, 2)==1
				XDATA=get(get(h(i),'Children'),'XData');
				YDATA=get(get(h(i),'Children'),'YData');
				for j=1:size(XDATA,2)
					x=XDATA(1,j)+(XDATA(3,j)-XDATA(1,j))/2;
					y=YDATA(2,j)+ybuff;
					t=[num2str(YDATA(2,j),3) ,''];
					text(x,y,t,'Color','k','HorizontalAlignment','left','Rotation',90)
				end
			end
		end
		details{7} = 'Total Requests count : %d';
                details{7} = sprintf(details{7}, sum(Matrix_count(:, 2)));
                text(1, max(max(queue_stats)) * 1.2, details, 'Color', 'red', 'FontSize', 14);
		legend('bg queue entered', 'bg queue removed', 'pending queue entered', 'pending queue removed', 'processing queue entered', 'processing queue removed');
		set(gca, 'XTick', 1:size(queue_stats)(1), 'XTickLabel', queue_labels);
                xlabel('Different Time intervals over the run of experiment (in secs)', 'fontsize', 15);
                ylabel('Total Count of Requests across different queues', 'fontsize', 15);
                title ('Request Count distribution across different queues', 'fontsize', 15);
		hold off;
                filename = strcat(dir, sprintf('Stat-files-%d-%d-Final/queue_lengths.png', max_write, iteration));
                print(filename, "-dpng");
                close();

		%Max queue lengths
		figure;
                clf;
                hold on;
		h = bar(max_queue_stats);
		ybuff=0;
                for i=1:length(h)
                	XDATA=get(get(h(i),'Children'),'XData');
                        YDATA=get(get(h(i),'Children'),'YData');
                        for j=1:size(XDATA,2)
                        	x=XDATA(1,j)+(XDATA(3,j)-XDATA(1,j))/2;
                                y=YDATA(2,j)+ybuff;
                                t=[num2str(YDATA(2,j),3) ,''];
				text(x,y,t,'Color','k','HorizontalAlignment','center','VerticalAlignment', 'bottom');
                        end
                end
		axis([0 size(max_queue_stats)(1)+1 0 max(max(max_queue_stats))*1.5]);
		details{7} = '';
		text(1, max(max(max_queue_stats)) * 1.3, details, 'Color', 'red', 'FontSize', 14);
		legend('bg queue', 'pending queue', 'processing queue');
		set(gca, 'XTick', 1:size(queue_stats)(1), 'XTickLabel', queue_labels);
		xlabel('Different Time intervals over the run of experiment (in secs)', 'fontsize', 15);
                ylabel('Max No. of Requests across different queues', 'fontsize', 15);
                title ('Max Requests in each queue over the experiment', 'fontsize', 15);
                hold off;
		filename = strcat(dir, sprintf('Stat-files-%d-%d-Final/max_queue_lengths.png', max_write, iteration));
                print(filename, "-dpng");
                close();
	end
end
