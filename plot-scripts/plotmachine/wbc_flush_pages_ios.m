function wbc_flush_pages_ios()

%inputDir1  = '/Users/Bharath/Downloads/FUSE/fuse-playground/Results/Stat-files-diff_max-diff_bdi_min_max/';
inputDir1  = '/Users/Bharath/Downloads/FUSE/fuse-playground/Results/';
outputDir = '/Users/Bharath/Downloads/FUSE/plots/Plots-HotStorage/';

%max_writes = [32768;65536;131072;262144;524288;1048576;2097152;4194304;8388608;16777216;33554432;67108864];
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
for k=1:size(reasons)(2)
reason=reasons{k};
%for k=1:size(max_ratios)(2)
%max_ratio = max_ratios(k);
%min_ratio = max_ratio;
for i=1:size(max_writes)(1)
	for j=1:size(io_sizes)(1)
		ios_submitted = [];
		wbc_flush_pages = [];
		for count=1:Total_iters
			temp = [];
			max_write = max_writes(i);
			io_size = io_sizes(j);
                        iteration = iterations;
%			inputDir = strcat(inputDir1, sprintf('/Stat-files-diff-max-%s-GETXATTR/Stat-files-%d-%d-%d-%d-%d-Final-%d/', reason, io_size, max_write, iterations, min_ratio, max_ratio, count));
%			inputDir = strcat(inputDir1, sprintf('/Stat-files-%d-%d-%d-%d-%d-Final-1', io_size, max_write, iterations, min_ratio, max_ratio));
			inputDir = strcat(inputDir1, sprintf('/Stat-files-%d-%s-GETXATTR', iterations, reason));
			filename = strcat(inputDir, '/wbc_writepages_kernel.txt');
			temp = load(filename);
%			temp_ios = temp(:, 1);
			temp_pages = temp;
			if (eq(count, 1))
%				ios_submitted = zeros(size(temp_ios)(1), 1, "uint64");
				wbc_flush_pages = zeros(size(temp_pages)(1), 1, "uint64");
			endif
			wbc_flush_pages += temp_pages;
		end		
%		ios_submitted = ios_submitted*1024;
%		percentage_data_flushed = (wbc_flush_pages*4096)/1048576;
%		wbc_flush_pages = wbc_flush_pages;
		wbc_flush_pages = (wbc_flush_pages*4096)/1048576;
%		percentage = (double(wbc_flush_pages)./double(ios_submitted)) * 100.0;
		details{1} = sprintf('Experiment type : Sequential Write of %d GB', (iterations*io_size)/(1024*1024*1024));
		details{2} = 'Write Back Cache : Yes';
		details{3} = sprintf('Max Write : %d KB', max_write/1024);
		details{4} = sprintf('Iterations : %d of 1 MB I/O (Hot Storage)', io_size);
		details{5} = 'Big Writes : No';
		details{6} = 'Max Bg Length : 12 (default)';
		details{7} = sprintf('Min BDI : %d, Max BDI : %d', min_ratio, max_ratio);
		details{8} = 'Ram Size : 4 GB (Hot Storage)';
		details{9} = sprintf('Reason : %s GETXATTR', reason);
		figure;
		clf;
		hold on;
		axis([0 size(wbc_flush_pages)(1)+10 0 max(wbc_flush_pages)*1.6]);
		grid minor;
		xlabel('fuse write pages iteration count', 'fontsize', 12);
		ylabel('Write back data flushed (in each iter)(in MB)', 'fontsize', 12);
		title (sprintf('wbc data flushed across each write pages iteration with %s', reason), 'fontsize', 12);
		text(size(wbc_flush_pages)(1) * 0.2, max(wbc_flush_pages) * 1.4, details, 'Color', 'blue', 'FontSize', 12);
		fig1 = plot(wbc_flush_pages, 'r');
		set(fig1(1), "linewidth", 2);
		hold off;
		outfilename = strcat(inputDir, '/wbc_data_flushed.png');
		print(outfilename, "-dpng");
		close();
	end
end
end
