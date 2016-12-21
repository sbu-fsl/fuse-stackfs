function dirty_threshold_limits()

inputDir = '/Users/Bharath/Downloads/FUSE/fuse-playground/Results/Stat-files-MIN-MAX/';
outputDir = '/Users/Bharath/Downloads/FUSE/plots/Plots-HotStorage/';

max_writes = [32768;65536;131072;262144;524288;1048576;2097152;4194304;8388608;16777216;33554432;67108864];
%max_writes = [32768];
max_writes_pages = max_writes/4096;
max_bdis = [1;10;20;30;40;50;60;70;80;90;100];
iterations = 61440;
io_size = 1048576; %Fixed
Total_iters = 1;
X = [1;2;3;4;5;6;7;8;9;10;11];

for i=1:size(max_writes)
	AvgAvailableMem = [];
	AvgBdiDirtyThresh = [];
	AvgDirtyThresh = [];
	AvgBgThresh = [];
	max_write = max_writes(i);
	for j=1:size(max_bdis)
		max_bdi = max_bdis(j);
		min_bdi = max_bdis(j);
		filename = strcat(inputDir, sprintf('/Stat-files-%d-%d-%d-%d-%d-Final-%d/AvailableMem.txt', io_size, max_write, iterations, min_bdi, max_bdi, Total_iters));
		availableMem = load(filename);
		avgavailableMem = sum(availableMem)/(size(availableMem)(1));
		AvgAvailableMem = [AvgAvailableMem; avgavailableMem];
		filename = strcat(inputDir, sprintf('/Stat-files-%d-%d-%d-%d-%d-Final-%d/BdiDirtyThershold.txt', io_size, max_write, iterations, min_bdi, max_bdi, Total_iters));
		bdiDirtyThreshold = load(filename);
		avgbdiDirtyThreshold = sum(bdiDirtyThreshold)/(size(bdiDirtyThreshold)(1));
		AvgBdiDirtyThresh = [AvgBdiDirtyThresh; avgbdiDirtyThreshold];
		filename = strcat(inputDir, sprintf('/Stat-files-%d-%d-%d-%d-%d-Final-%d/DirtyThershold.txt', io_size, max_write, iterations, min_bdi, max_bdi, Total_iters));
		dirtyThreshold = load(filename);
		avgdirtyThreshold = sum(dirtyThreshold)/(size(dirtyThreshold)(1));
		AvgDirtyThresh = [AvgDirtyThresh; avgdirtyThreshold];
		filename = strcat(inputDir, sprintf('/Stat-files-%d-%d-%d-%d-%d-Final-%d/BackgroundThershold.txt', io_size, max_write, iterations, min_bdi, max_bdi, Total_iters));
		backgroundThreshold = load(filename);
		avgbackgroundThreshold = sum(backgroundThreshold)/(size(backgroundThreshold)(1));
		AvgBgThresh = [AvgBgThresh; avgbackgroundThreshold];
	end
	AvgAvailableMem = AvgAvailableMem/1024; %to MB
        AvgBdiDirtyThresh = AvgBdiDirtyThresh/1024; %to MB
        AvgDirtyThresh = AvgDirtyThresh/1024; %to MB
        AvgBgThresh = AvgBgThresh/1024; %to MB
	figure;
	clf;
	hold on;
	fig1 = plot(AvgDirtyThresh, 'b--*');
	fig2 = plot(AvgAvailableMem, 'g--*');
	fig3 = plot(AvgBgThresh, 'k--*');
	fig4 = plot(AvgBdiDirtyThresh, 'r--*');
	set(fig1(1), "linewidth", 6);
	set(fig2(1), "linewidth", 6);
	set(fig3(1), "linewidth", 6);
	set(fig4(1), "linewidth", 6);
	axis([0 size(AvgAvailableMem)(1)+1 0 max(AvgAvailableMem)*1.2]);
	legend('Avg Global Dirty', 'Avg Availale Mem', 'Avg Global Background', 'Avg BDI Dirty');
	grid minor;
	a = round(AvgAvailableMem);
	b = num2str(a);
	c = cellstr(b);
	dx=0;
	dy=100;
	text(X+dx, AvgAvailableMem+dy,c, 'FontSize', 10);

	a = round(AvgBdiDirtyThresh);
        b = num2str(a);
        c = cellstr(b);
        dx=0;
        dy=100;
        text(X+dx, AvgBdiDirtyThresh+dy,c, 'FontSize', 10);

	a = round(AvgBgThresh);
        b = num2str(a);
        c = cellstr(b);
        dx=0;
        dy=100;
        text(X+dx, AvgBgThresh+dy,c, 'FontSize', 10);

	a = round(AvgDirtyThresh);
        b = num2str(a);
        c = cellstr(b);
        dx=0;
        dy=100;
        text(X+dx, AvgDirtyThresh+dy,c, 'FontSize', 10);
	
	details = sprintf('Max Write size : %d', max_write);
	text(4, max(AvgAvailableMem)*0.6, details, 'Color', 'red', 'FontSize', 14);
	set(gca, 'XTick', 1:size(max_bdis)(1), 'XTickLabel', max_bdis);
	xlabel('Different Min, Max BDI ratio limits (%)', 'fontsize', 15);
	ylabel('Avg Available and Dirty Memory limits (in MB)', 'fontsize', 15);
	title ('Different Global and BDI Dirty imits varying MAX BDI ratios', 'fontsize', 15);
	hold off;
	outfilename = strcat(outputDir, sprintf('/Dirty_Limits_Comparision-minmaxvary-%d.png', max_write));
	print(outfilename, "-dpng");
	close();
end
