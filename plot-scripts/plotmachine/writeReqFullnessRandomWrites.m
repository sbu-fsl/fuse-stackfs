function writeReqFullnessRandomWrites()

inputDir = '/Users/Bharath/Downloads/FUSE/raw_data/Results/Stat-files-random-writes-writeback-cache/';
outputDir = '/Users/Bharath/Downloads/FUSE/plots/Plots-HotStorage/';

%max_writes = [32768;65536;131072;262144;524288;1048576;2097152;4194304;8388608;16777216;33554432;67108864];
max_writes = [8388608;16777216;33554432;67108864];
io_sizes = [4096; 8192; 16384; 32768; 65536; 131072; 262144; 524288; 1048576];
io_sizes_KB = io_sizes./1024;

details{1} = 'write\_back\_cache : Yes';
details{2} = 'max\_write : %d KB';
details{3} = 'big\_writes : No';
details{4} = 'max\_bg\_length : 12 (default)';
details{5} = 'congestion\_threshold : 9 (default)';
details{6} = '%d KB I/O Iterations = %d, 60GB (Hot Storage)';
details{7} = 'RAM Size : 4 GB (Hot Storage)';

Total_iters = 1;
percentage_fullness = [];
max_write_pages = [];
write_reqs_bckts = [];
for i=1:size(max_writes)(1)
	percentages = [];
        for j=1:size(io_sizes)(1)
		percentage = 0;
                for count=1:Total_iters %avergae over these many iterations
			equal_count = 0;
                        total_count = 0;
                        max_write = max_writes(i);
			io_size = io_sizes(j);
                        iteration = (60*1024*1024*1024)/io_size;
			filename = strcat(inputDir, sprintf('/Stat-files-%d-%d-%d-Final-%d/writeback_req_sizes', io_size, max_write, iteration, count));
                        req_sizes = load(filename);
			equal_count = req_sizes(size(req_sizes)(1)-1);
                        total_count = equal_count + req_sizes(size(req_sizes)(1));
                        percentage = percentage + ((equal_count/total_count) * 100);
		end
		percentages = [percentages; percentage/Total_iters];
	end
	X = [1;2;3;4;5;6;7;8;9];
	figure;
	clf;
	hold on;
	fig3 = plot(percentages, 'b--*');
	set(fig3(1), "linewidth", 10);
	grid minor;
	a = percentages;
	b = num2str(a);
	c = cellstr(b);
	dx=1;
	dy=0.02;
	text(X-dx, percentages+dy,c, 'FontSize', 10);
	if (eq(max(percentages), 0))
		axis([0 size(io_sizes)(1)+1 0 2]);
	else
		axis([0 size(io_sizes)(1)+1 0 max(percentages)*1.5]);
	endif
	details{2} = sprintf('max write : %d KB', max_write/1024);
	details{6} = sprintf('%d KB I/O, File size : 60GB (Hot Storage)', io_size/1024);
	if (eq(max(percentages), 0))
		text(4, 1.6, details, 'Color', 'red', 'FontSize', 14);
	else
		text(4, max(percentages) * 1.3, details, 'Color', 'red', 'FontSize', 14);
	endif
	set(gca, 'XTick', 1:size(io_sizes)(1), 'XTickLabel', io_sizes_KB);
	xlabel('Different I/O sizes (in KB)', 'fontsize', 15);
	ylabel('Percentage write requests fullness (in %)', 'fontsize', 15);
	title ('Random Writes FUSE WRITE Request Fullness percentages', 'fontsize', 15);
	hold off;
	outfilename = strcat(outputDir, sprintf('/random_write_req_fullness-%d.png', max_write));
	print(outfilename, "-dpng");
	close();
end
