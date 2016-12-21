function wb_kernel_flusher()

inputDir1  = '/Users/Bharath/Downloads/FUSE/fuse-playground/Results/';
max_writes  = [1048576];
io_sizes = [1048576];
iterations = 1024;
min_ratio = 0;
max_ratio = 1;
%max_ratios = [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 99]; %Update accordingly, min will be 99 and max will be 100

Total_iters = 1;
Final_value = {};

reasons{1} = 'Single-Yes';
reasons{2} = 'Single-No';
reasons{3} = 'Multi-Yes';
reasons{4} = 'Multi-No';

multiply_factor = (4096)/(1024*1024); %in MB

for k=1:size(reasons)(2)
	reason=reasons{k};
	for i=1:size(max_writes)(1)
        	for j=1:size(io_sizes)(1)
                	ios_submitted = [];
                	wbc_flush_pages = [];
                	for count=1:Total_iters
                        	temp = [];
                        	max_write = max_writes(i);
                        	io_size = io_sizes(j);
                        	iteration = iterations;
                        	inputDir = strcat(inputDir1, sprintf('/Stat-files-%d-%s-GETXATTR', iterations, reason));
                        	filename = strcat(inputDir, '/kernel_flusher_thread_data.txt');
                        	flusher_thread_data = load(filename);
				flusher_thread_data = flusher_thread_data*multiply_factor;
%				flusher_thread_data (flusher_thread_data == 0) = 1; %make 0's to 1
%				flusher_thread_data = log(flusher_thread_data);
				flusher_thread_data_tmp = flusher_thread_data(:, 2:size(flusher_thread_data)(2));
				details{1} = sprintf('Min BDI : %d, Max BDI : %d', min_ratio, max_ratio);
				figure;
				clf;
				hold on;
				axis([0 size(flusher_thread_data)(1)+10 0 max(flusher_thread_data(:, 1))*1.6]);
				grid minor;
				fig1 = bar(flusher_thread_data(:, 1), 'b');
				set(fig1(1), "linewidth", 1);
				text(size(flusher_thread_data(:, 1))(1)*0.2, max(flusher_thread_data(:, 1)) * 1.1, details, 'Color', 'red', 'FontSize', 14);
                		xlabel('Start to end kernel flusher iteration', 'fontsize', 15);
                		ylabel('Values in MB', 'fontsize', 15);
                		title (sprintf('Data flushed in each flusher iteration in %d GB, %s GETXATTR', (io_size*iterations)/(1024*1024*1024), reason), 'fontsize', 15);
                		hold off;
				outfilename = strcat(inputDir, '/wb_kernel_flusher_data.png');
                		print(outfilename, "-dpng");
                		close();
                	end
		end
	end
end
