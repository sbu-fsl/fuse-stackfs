function writebackTrend()
val = 32;
for k=1:15
	val = val*2;
	filename = sprintf('/Users/Bharath/Downloads/FUSE/raw_data/WriteBack-Trend/Stat-files-%d/writeback_req_sizes', val);
	outfilename = sprintf('/Users/Bharath/Downloads/FUSE/plots/WriteBack-Trend/Stat-files-%d.png', val);

	req_sizes = importdata(filename);
	count = 0;
	for i=1:size(req_sizes)(1)
		if (req_sizes(i) == 64)
			count++;
		end
	end

	%Hard coded experiment details
	details{1} = 'Experiment type : 4KB I/O with varying iterations (filebench)';
	details{2} = 'write\_back\_cache : Yes';
	details{3} = 'max\_write : Yes , 262144 (64 Pages)';
	details{4} = 'big\_writes : No';
	details{5} = 'max\_bg\_length : 12 (default)';
	details{6} = 'congestion\_threshold : 9 (default)';
	details{7} = sprintf('4096 I/O Iterations = %d', val);
	details{8} = sprintf('No. of FUSE WRITE Req. : %d', size(req_sizes)(1));
	details{9} = sprintf('No. of completely filled requests : %d, percentage : %f', count, count/(size(req_sizes)(1)));
	figure;
	clf;
	hold on;
	grid minor;
	fig3 = plot(req_sizes);
	set(fig3(1), "linewidth", 10);
	axis([0 size(req_sizes)(1)+2 0 max(req_sizes)+50]);
	text((size(req_sizes)(1)+2)/20, max(req_sizes)+30, details, 'Color', 'red', 'FontSize', 14);
	xlabel('Total Write back requsests (one by one)', 'fontsize', 15);
	ylabel('No. of Pages in each request', 'fontsize', 15);
	title ('FUSE WRITE Req. distribution in Writeback Option', 'fontsize', 15);
	hold off;
	print(outfilename, "-dpng");
	close();
end
