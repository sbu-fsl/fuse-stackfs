function write_getxattr_latencies()

%inputDir1 = '/Users/Bharath/Downloads/FUSE/fuse-playground/Results/Stat-files-diff_max-diff_bdi_min_max/';
inputDir1  = '/Users/Bharath/Downloads/FUSE/fuse-playground/Results/';
outputDir = '/Users/Bharath/Downloads/FUSE/plots/Plots-HotStorage/';

max_writes = [1048576];
%max_writes = [32768;65536;131072;262144;524288;1048576;2097152;4194304;8388608;16777216;33554432;67108864];

io_sizes = [1048576];
iterations = 1024;
min_ratio = 0;
max_ratio = 1;
%max_ratios = [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 99]; %Max Bdi wil be 100, and Min Bdi will be 99
%max_ratios = [70, 80, 90, 99];

Total_iters = 1;
Final_value = {};

reasons{1} = 'Single-Yes';
reasons{2} = 'Single-No';
reasons{3} = 'Multi-Yes';
reasons{4} = 'Multi-No';

mutliply_factor = 1000;
for k=1:size(reasons)(2)
reason=reasons{k};
%for k=1:size(max_ratios)(2)
%max_ratio = max_ratios(k);
%min_ratio = max_ratio;
for i=1:size(max_writes)(1)
        for j=1:size(io_sizes)(1)
		max_write = max_writes(i);
                io_size = io_sizes(j);
%		inputDir = strcat(inputDir1, sprintf('/Stat-files-diff-max-%s-GETXATTR/Stat-files-%d-%d-%d-%d-%d-Final-1/', reason, io_size, max_write, iterations, min_ratio, max_ratio));
%		inputDir = strcat(inputDir1, sprintf('/Stat-files-%d-%d-%d-%d-%d-Final-1', io_size, max_write, iterations, min_ratio, max_ratio));
		inputDir = strcat(inputDir1, sprintf('/Stat-files-%d-%s-GETXATTR', iterations, reason));
		filename = strcat(inputDir, '/write_iter_begin_times');
		write_iter_begin_times = load(filename);
		write_iter_begin_times = write_iter_begin_times*mutliply_factor;
		filename = strcat(inputDir, '/write_iter_end_times');
                write_iter_end_times = load(filename);
		write_iter_end_times = write_iter_end_times*mutliply_factor;

		filename = strcat(inputDir, '/getxattr_begin_times');
		getxattr_begin_times = load(filename);
		getxattr_begin_times = getxattr_begin_times*mutliply_factor;
		filename = strcat(inputDir, '/getxattr_end_times');
                getxattr_end_times = load(filename);
		getxattr_end_times = getxattr_end_times*mutliply_factor;

		filename = strcat(inputDir, '/setattr_begin_times');
                setattr_begin_times = load(filename);
                setattr_begin_times = getxattr_begin_times*mutliply_factor;
                filename = strcat(inputDir, '/setattr_end_times');
                setattr_end_times = load(filename);
                setattr_end_times = getxattr_end_times*mutliply_factor;

		write_iter_diff = write_iter_end_times - write_iter_begin_times;
		getxattr_diff = getxattr_end_times - getxattr_begin_times;
		setattr_diff  = setattr_end_times - setattr_begin_times;

		filename = strcat(inputDir, '/pending_queue_lengths.txt');
		getxattr_pending_queue_lengths = load(filename);

		filename = strcat(inputDir, '/pauseTimes.txt');
		paused_times = load(filename); %Already in msecs
%		paused_times = paused_times*mutliply_factor; 

		filename = strcat(inputDir, '/pos_ratios.txt');
		pos_ratios = load(filename);
		pos_ratios = pos_ratios/1024;

		filename = strcat(inputDir, '/task_dirty_pages_limit.txt');
		task_dirty_pages_limit = load(filename);

		details{1} = sprintf('Min BDI : %d, Max BDI : %d', min_ratio, max_ratio);

		%write_iter_latencies
		figure;
                clf;
                hold on;
                fig1 = bar(write_iter_diff, 'b');
		axis([0 size(write_iter_diff)(1)+10 0 max(write_iter_diff)*1.2]);
                grid minor;
		text(size(write_iter_diff)(1)*0.2, max(write_iter_diff) * 1.1, details, 'Color', 'red', 'FontSize', 14);
                xlabel('fuse write iteration count', 'fontsize', 12);
                ylabel('Each Write Iteration time (in msecs)', 'fontsize', 12);
                title (sprintf('write latencies, %d GB Write, with %s GETXATTR', (io_size*iterations)/(1024*1048576), reason), 'fontsize', 12);
		hold off;
                outfilename = strcat(inputDir, '/write-iter-latencies.png');
                print(outfilename, "-dpng");
                close();
		%getxattr_latencies
		figure;
                clf;
                hold on;
                fig1 = bar(getxattr_diff, 'b');
                axis([0 size(getxattr_diff)(1)+10 0 max(getxattr_diff)*1.2]);
                grid minor;
		text(size(getxattr_diff)(1)*0.2, max(getxattr_diff)*1.1, details, 'Color', 'red', 'FontSize', 14);
                xlabel('fuse getxattr iteration count', 'fontsize', 12);
                ylabel('Each getxattr Iteration time (in msecs)', 'fontsize', 12);
                title (sprintf('getxattr latencies, %d GB Write, with %s GETXATTR', (io_size*iterations)/(1024*1048576), reason), 'fontsize', 12);
                hold off;
                outfilename = strcat(inputDir, '/getxattr_diff-latencies.png');
                print(outfilename, "-dpng");
                close();

		%setattr_latencies
		figure;
                clf;
                hold on;
                fig1 = bar(setattr_diff, 'b');
                axis([0 size(setattr_diff)(1)+10 0 max(setattr_diff)*1.2]);
                grid minor;
                text(size(setattr_diff)(1)*0.2, max(setattr_diff)*1.1, details, 'Color', 'red', 'FontSize', 14);
                xlabel('fuse setattr iteration count', 'fontsize', 12);
                ylabel('Each setattr Iteration time (in msecs)', 'fontsize', 12);
                title (sprintf('setattr latencies, %d GB Write, with %s GETXATTR', (io_size*iterations)/(1024*1048576), reason), 'fontsize', 12);
                hold off;
                outfilename = strcat(inputDir, '/setattr_diff-latencies.png');
                print(outfilename, "-dpng");
                close();

		%getxattr pending queue length
		figure;
                clf;
                hold on;
		fig1 = bar(getxattr_pending_queue_lengths, 'b');
		if (max(getxattr_pending_queue_lengths) == 0)
			axis([0 size(getxattr_pending_queue_lengths)(1)+10 0 10]);
			text(size(getxattr_pending_queue_lengths)(1)*0.2, 8, details, 'Color', 'red', 'FontSize', 14);
		else
                	axis([0 size(getxattr_pending_queue_lengths)(1)+10 0 max(getxattr_pending_queue_lengths)*1.2]);
			text(size(getxattr_pending_queue_lengths)(1)*0.2, max(getxattr_pending_queue_lengths)*1.1, details, 'Color', 'red', 'FontSize', 14);
		endif
                grid minor;
                xlabel('fuse getxattr iteration count', 'fontsize', 12);
                ylabel('Requests head of GETXATTR in pending queue', 'fontsize', 12);
                title (sprintf('Pending Queue lengths before GETXATTR, %d GB Write, with %s GETXATTR', (io_size*iterations)/(1024*1048576), reason), 'fontsize', 12);
                hold off;
                outfilename = strcat(inputDir, '/getxattr_pending_queue_lengths.png');
                print(outfilename, "-dpng");
                close();
		%filebench pause latencies
		figure;
                clf;
                hold on;
                fig1 = bar(paused_times, 'b');
		if (max(paused_times) == 0)
                	axis([0 size(paused_times)(1)+10 0 10]);
		else
			axis([0 size(paused_times)(1)+10 0 max(paused_times)*1.2]);
		endif
                grid minor;
		text(size(paused_times)(1)*0.2, max(paused_times)*1.1, details, 'Color', 'red', 'FontSize', 14);
                xlabel('filebench iteration count', 'fontsize', 12);
                ylabel('Filebench paused time (in msecs)', 'fontsize', 12);
                title (sprintf('filebench paused time latencies, %d GB Write, with %s GETXATTR', (io_size*iterations)/(1024*1048576), reason), 'fontsize', 12);
                hold off;
                outfilename = strcat(inputDir, '/filebench-paused-times.png');
                print(outfilename, "-dpng");
                close();
		%Getxattr latencies percentage to total write latency
		getxattr_percentage = (getxattr_diff./write_iter_diff)*100;
		figure;
                clf;
                hold on;
                fig1 = bar(getxattr_percentage, 'b');
                axis([0 size(getxattr_percentage)(1)+10 0 110]);
		text(size(getxattr_percentage)(1)*0.2, 105, details, 'Color', 'red', 'FontSize', 14);
                grid minor;
                xlabel('iteration count', 'fontsize', 12);
                ylabel('Percentage of time taken by getxattr (%)', 'fontsize', 12);
                title (sprintf('percentage of time in getxattr out of write iter, %d GB Write, with %s GETXATTR', (io_size*iterations)/(1024*1048576), reason), 'fontsize', 12);
                hold off;
                outfilename = strcat(inputDir, '/getxattr_percentage-latencies.png');
                print(outfilename, "-dpng");
                close();

		%filebench paused percentage to total write latency
                paused_percentage = (paused_times./write_iter_diff)*100;
                figure;
                clf;
                hold on;
                fig1 = bar(paused_percentage, 'b');
                axis([0 size(paused_percentage)(1)+10 0 110]);
                grid minor;
		text(size(paused_percentage)(1)*0.2, 105, details, 'Color', 'red', 'FontSize', 14);
                xlabel('iteration count', 'fontsize', 12);
                ylabel('Percentage of time taken by filebench pause (%)', 'fontsize', 12);
                title (sprintf('percentage of time filbench was paused out of write iter, %d GB Write, with %s GETXATTR', (io_size*iterations)/(1024*1048576), reason), 'fontsize', 12);
                hold off;
                outfilename = strcat(inputDir, '/filebench_paused_percentage-latencies.png');
                print(outfilename, "-dpng");
                close();

		%pos_ratio of the bdi device
		figure;
                clf;
                hold on;
                fig1 = plot(pos_ratios, 'b');
                axis([0 size(pos_ratios)(1)+10 0 max(pos_ratios)+1]);
                grid minor;
		text(size(pos_ratios)(1)*0.2, max(pos_ratios)+0.5, details, 'Color', 'red', 'FontSize', 14);
                xlabel('iteration count', 'fontsize', 12);
                ylabel('Position ratio (in decimals (0 <= pos_ratio <= 2))', 'fontsize', 12);
                title (sprintf('Postion ratio across the experiment, %d GB Write, with %s GETXATTR', (io_size*iterations)/(1024*1048576), reason), 'fontsize', 12);
                hold off;
                outfilename = strcat(inputDir, '/position_ratio.png');
                print(outfilename, "-dpng");
                close();

		%task_dirty_pages_limit
		figure;
                clf;
                hold on;
                fig1 = bar(task_dirty_pages_limit, 'b');
                axis([0 size(task_dirty_pages_limit)(1)+10 0 max(task_dirty_pages_limit)+5]);
                grid minor;
		text(size(task_dirty_pages_limit)(1)*0.2, max(task_dirty_pages_limit)+3, details, 'Color', 'red', 'FontSize', 14);
                xlabel('iteration count', 'fontsize', 12);
                ylabel('Task dirty pages limit', 'fontsize', 12);
                title (sprintf('Task dirty pages limit across the experiment, %d GB Write, with %s GETXATTR', (io_size*iterations)/(1024*1048576), reason), 'fontsize', 12);
                hold off;
                outfilename = strcat(inputDir, '/task_dirty_pages_limit.png');
                print(outfilename, "-dpng");
                close();

	end
end
end
