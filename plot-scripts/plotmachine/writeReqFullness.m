function writeReqFullness()

%inputDir = '/Users/Bharath/Downloads/FUSE/raw_data/Results/Stat-files-writebackcache-HotStorage/';
inputDir1  = '/Users/Bharath/Downloads/FUSE/fuse-playground/Results/';
outputDir = '/Users/Bharath/Downloads/FUSE/plots/Plots-HotStorage/';

max_writes = [32768;65536;131072;262144;524288;1048576;2097152;4194304;8388608;16777216;33554432;67108864];
io_sizes = [1048576];
iterations = 1024;
min_ratio = 0;
max_ratio = 1;

reasons{1} = 'YES';
reasons{2} = 'NO';

Total_iters = 1;
write_reqs_bckts = [];
for k=1:size(reasons)(2)
max_write_pages = [];
percentage_fullness = [];
reason=reasons{k};
for i=1:size(max_writes)(1)
        for j=1:size(io_sizes)(1)
		percentage = 0;
		tmp_reqs_buckts = zeros(15, 1, "uint64");
		io_size = io_sizes(j);
		for count=1:Total_iters %avergae over these many iterations
			equal_count = 0;
			total_count = 0;
			max_write = max_writes(i);
			iteration = iterations;
			inputDir = strcat(inputDir1, sprintf('/Stat-files-diff-max-%s-GETXATTR/Stat-files-%d-%d-%d-%d-%d-Final-%d/', reason, io_size, max_write, iterations, min_ratio, max_ratio, count));
			filename = strcat(inputDir, '/writeback_req_sizes');
			req_sizes = load(filename);
			pages = max_write/4096;
			equal_count = req_sizes(size(req_sizes)(1)-1);
			total_count = equal_count + req_sizes(size(req_sizes)(1));	
			percentage = percentage + ((equal_count/total_count) * 100);
%			tmp_reqs_buckts = tmp_reqs_buckts + req_sizes(1:15);
		end
		max_write_pages = [max_write_pages;pages];
		percentage = percentage/Total_iters;
		percentage_fullness = [percentage_fullness;percentage];
%		tmp_reqs_buckts = tmp_reqs_buckts./Total_iters;
%		write_reqs_bckts = [write_reqs_bckts, tmp_reqs_buckts];
	end
end
%max_write_pages
%percentage_fullness
%write_reqs_bckts
%Hard coded experiment details
details{1} = 'write\_back\_cache : Yes';
details{2} = 'max\_write : Yes, On X-Axis (in pages)';
details{3} = 'big\_writes : No';
details{4} = 'max\_bg\_length : 12 (default)';
details{5} = 'congestion\_threshold : 9 (default)';
details{6} = '1 MB I/O Iterations = 61440, 60GB (Hot Storage)';
details{7} = 'RAM Size : 4 GB (Hot Storage)';
details{8} = sprintf('Reason : %s GETXATTR', reason);
%faster_plots = [99.94013; 97.83257; 95.66431; 94.34485; 93.32080; 92.75167; 92.35253; 89.54251; 79.44552; 64.66676; 35.71798; 0.00000 ];
%max_write_pages = [8; 16; 32; 64; 128; 256; 512; 1024; 2048; 4096; 8192; 16384];
%Request Percentage Graphs
X = [1;2;3;4;5;6;7;8;9;10;11;12];
figure;
clf;
hold on;
fig3 = plot(percentage_fullness, 'b--*');
set(fig3(1), "linewidth", 10);
grid minor;
a = percentage_fullness;
b = num2str(a);
c = cellstr(b);
dx=0;
dy=4;
text(X, percentage_fullness+dy,c, 'FontSize', 10);
axis([0 size(max_write_pages)(1)+1 0 max(percentage_fullness)*1.5]);
text(4, max(percentage_fullness) * 1.3, details, 'Color', 'red', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_write_pages)(1), 'XTickLabel', max_write_pages);
xlabel('Different max writes (in pages of 4096 each)', 'fontsize', 15);
ylabel('Percentage write requests fullness (in %)', 'fontsize', 15);
title ('FUSE WRITE Request Fullness percentages', 'fontsize', 15);
hold off;
outputDir = strcat(inputDir1, sprintf('/Stat-files-diff-max-%s-GETXATTR/', reason));
outfilename = strcat(outputDir, '/write_req_fullness.png');
print(outfilename, "-dpng");
close();
end
%Distribution of Pages per write Request Graphs
%{
X = [1;2;3;4;5;6;7;8;9;10;11;12;13;14;15];
axisvalues=[];
temp=2;
for i=1:15
	axisvalues=[axisvalues;temp];
	temp=temp*2;
end
%axisvalues
for i=1:size(max_write_pages)(1)
	tmp_log=[];
	for j=1:size(write_reqs_bckts(:, i))(1)
		if (write_reqs_bckts(j, i) > 0)
			tmp_log = [tmp_log;log(write_reqs_bckts(j, i))];
		else
			tmp_log = [tmp_log;0];
		endif
	end
	figure;
	clf;
	hold on;
	details{2} = sprintf('max write : %d (in pages)', max_write_pages(i));
	h = bar(tmp_log);
	a = write_reqs_bckts(:, i);
	b = num2str(a);
	c = cellstr(b);
	dx=0.5;
	dy=0.5;
	text(X-dx, tmp_log+dy, c, 'FontSize', 10);
	axis([0 size(tmp_log)(1)+1 0 max(tmp_log)*1.7]);
	text(2, max(tmp_log) * 1.4, details, 'Color', 'blue', 'FontSize', 14);
	set(gca, 'XTick', 1:15, 'XTickLabel', axisvalues);
	xlabel('Different Page sized Write req buckets', 'fontsize', 15);
	ylabel('No. of write requests count', 'fontsize', 15);
	title ('Pages and Write Request Distribution', 'fontsize', 15);
	hold off;
	outfilename = strcat(outputDir, sprintf('/Write_reqs_pages_distribution-%d.png', max_write_pages(i)));
	print(outfilename, "-dpng");
	close();
end
%}
