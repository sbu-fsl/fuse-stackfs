function writeReqFullnessMinMaxBdi()

%inputDir = '/Users/Bharath/Downloads/FUSE/fuse-playground/Results/Stat-files-MIN-MAX/';

inputDir  = '/Users/Bharath/Downloads/FUSE/fuse-playground/Results/Stat-files-diff_max-diff_bdi_min_max/';
outputDir = '/Users/Bharath/Downloads/FUSE/plots/Plots-HotStorage/';

max_writes = [32768;65536;131072;262144;524288;1048576;2097152;4194304;8388608;16777216;33554432;67108864];
max_writes_pages = max_writes/4096;
max_bdis = [1;10;20;30;40;50;60;70;80;90;99];%Update accordingly, min will be 99 and max will be 100.
iterations = 1024;
io_size = 1048576; %Fixed
Total_iters = 1;

percentage_fullness_diff_min_max = [];
for k=1:size(max_bdis)
	percentage_fullness = [];
	for i=1:size(max_writes)(1)
        	for j=iterations:iterations
			percentage = 0;
			for count=1:Total_iters %avergae over these many iterations
				equal_count = 0;
				total_count = 0;
				max_write = max_writes(i);
				iteration = iterations;
				max_bdi = max_bdis(k);
				min_bdi = max_bdis(k);
%				min_bdi = 0;
				filename = strcat(inputDir, sprintf('/Stat-files-%d-%d-%d-%d-%d-Final-%d/writeback_req_sizes', io_size, max_write, iteration, min_bdi, max_bdi, count));
				req_sizes = load(filename);
				pages = max_write/4096;
				equal_count = req_sizes(size(req_sizes)(1)-1);
				total_count = equal_count + req_sizes(size(req_sizes)(1));
				percentage = percentage + ((equal_count/total_count) * 100);
			end
			percentage = percentage/Total_iters;
			percentage_fullness = [percentage_fullness;percentage];
		end
	end
	percentage_fullness_diff_min_max = [percentage_fullness_diff_min_max percentage_fullness];
end
%percentage_fullness_diff_min_max
%max_write_pages
%Hard coded experiment details
details{1} = 'write\_back\_cache : Yes';
details{2} = 'max\_write : Yes, On X-Axis (in pages)';
details{3} = 'big\_writes : No';
details{4} = 'Global Dirty Threshold : 20% (default)';
details{5} = 'Global Background Threshold : 10% (default)';
details{6} = '1 MB I/O Iterations = 61440, 60GB';
details{7} = 'RAM Size : 4 GB, Avail : 3.6 GB(approx)';
%Request Percentage Graphs
X = [1;2;3;4;5;6;7;8;9;10;11;12];
figure;
clf;
hold on;
fig3 = plot(percentage_fullness_diff_min_max, '--*');
set(fig3(1), "linewidth", 1);
grid minor;
a = percentage_fullness_diff_min_max(:, 11);
b = num2str(a);
c = cellstr(b);
dx=0;
dy=4;
text(X, percentage_fullness_diff_min_max(:, 11)+dy,c, 'FontSize', 10);
axis([0 size(max_writes_pages)(1)+1 0 max(max(percentage_fullness_diff_min_max))*1.5]);
text(1, max(percentage_fullness) * 1.3, details, 'Color', 'red', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_writes_pages)(1), 'XTickLabel', max_writes_pages);
legend('Min, Max BDI 1%  ', 'Min, Max BDI 10% ', 'Min, Max BDI 20% ', 'Min, Max BDI 30% ', 'Min, Max BDI 40% ', 'Min, Max BDI 50% ', 'Min, Max BDI 60% ', 'Min, Max BDI 70% ', 'Min, Max BDI 80% ', 'Min, Max BDI 90% ', 'Min, Max BDI 99%');
%legend('Min BDI 0%, Max BDI 1%  ', 'Min BDI 0%, Max BDI 10% ', 'Min BDI 0%, Max BDI 20% ', 'Min BDI 0%, Max BDI 30% ', 'Min BDI 0%, Max BDI 40% ', 'Min BDI 0%, Max BDI 50% ', 'Min BDI 0%, Max BDI 60% ', 'Min BDI 0%, Max BDI 70% ', 'Min BDI 0%, Max BDI 80% ', 'Min BDI 0%, Max BDI 90% ', 'Min BDI 0%, Max BDI 100%');
xlabel('Different max writes (in pages of 4096 each)', 'fontsize', 15);
ylabel('Percentage write requests fullness (in %)', 'fontsize', 15);
title ('Write Request Fullness percentages varying FUSE Min, Max BDI', 'fontsize', 15);
hold off;
outfilename = strcat(inputDir, '/write_req_fullness_min_max_bdi.png');
print(outfilename, "-dpng");
close();
%Try Plotting Bar graph showing differences among the percentages
%percentage_fullness_diff_min_max_trans = transpose(percentage_fullness_diff_min_max);
figure;
clf;
hold on;
h = bar(percentage_fullness_diff_min_max);
axis([0 size(percentage_fullness_diff_min_max)(1)+2 0 max(max(percentage_fullness_diff_min_max))*1.2]);
set(gca, 'XTick', 1:size(max_writes_pages)(1), 'XTickLabel', max_writes_pages);
legend('Min, Max BDI 1%  ', 'Min, Max BDI 10% ', 'Min, Max BDI 20% ', 'Min, Max BDI 30% ', 'Min, Max BDI 40% ', 'Min, Max BDI 50% ', 'Min, Max BDI 60% ', 'Min, Max BDI 70% ', 'Min, Max BDI 80% ', 'Min, Max BDI 90% ', 'Min, Max BDI 100%');
%legend('Min BDI 0%, Max BDI 1%  ', 'Min BDI 0%, Max BDI 10% ', 'Min BDI 0%, Max BDI 20% ', 'Min BDI 0%, Max BDI 30% ', 'Min BDI 0%, Max BDI 40% ', 'Min BDI 0%, Max BDI 50% ', 'Min BDI 0%, Max BDI 60% ', 'Min BDI 0%, Max BDI 70% ', 'Min BDI 0%, Max BDI 80% ', 'Min BDI 0%, Max BDI 90% ', 'Min BDI 0%, Max BDI 100%');
xlabel('Different max\_write sizes', 'fontsize', 15);
ylabel('Percentage write requests fullness (in %)', 'fontsize', 15);
title ('WRITE Request Fullness percentages varying FUSE Min, Max BDI', 'fontsize', 15);
ybuff=2;
for i=[1  5 length(h)]
    XDATA=get(get(h(i),'Children'),'XData');
    YDATA=get(get(h(i),'Children'),'YData');
    for j=1:size(XDATA,2)
        x=XDATA(1,j)+(XDATA(3,j)-XDATA(1,j))/2;
    	y=YDATA(2,j)+ybuff;
    	t=[num2str(YDATA(2,j),3) ,''];
    	text(x,y,t,'Color','k','HorizontalAlignment','left','Rotation',90)
    end
end
%text(7.5, max(max(percentage_fullness_diff_min_max)) * 0.5, details, 'Color', 'red', 'FontSize', 14);
hold off;
outfilename = strcat(inputDir, '/write_req_fullness_min_max_bdi_bar.png');
print(outfilename, "-dpng");
close();
