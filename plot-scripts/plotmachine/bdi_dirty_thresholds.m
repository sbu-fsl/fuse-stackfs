function bdi_dirty_thresholds()

%inputDir1  = '/Users/Bharath/Downloads/FUSE/fuse-playground/Results/Stat-files-diff_max-diff_bdi_min_max/';
inputDir1  = '/Users/Bharath/Downloads/FUSE/fuse-playground/Results/';
outputDir = '/Users/Bharath/Downloads/FUSE/fuse-playground/Results/';

%max_writes = [32768;65536;131072;262144;524288;1048576;2097152;4194304;8388608;16777216;33554432;67108864];
max_writes = [1048576];
io_sizes = [1048576];
iterations = 1024;
min_ratio = 0;
max_ratio = 1;
%max_ratios = [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
Total_iters = 1;
Final_value = {};

reasons{1} = 'Single-Yes';
reasons{2} = 'Single-No';
reasons{3} = 'Multi-Yes';
reasons{4} = 'Multi-No';

mutliply_factor = (4096/(1024*1024)); %pages to MB
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
		filename = strcat(inputDir, '/nr_reclaimable.txt');
		nr_reclaimable = load(filename);
		nr_reclaimable = nr_reclaimable*mutliply_factor;

		filename = strcat(inputDir, '/dirty_thresh.txt');
		dirty_thresh = load(filename);
		dirty_thresh = dirty_thresh*mutliply_factor;

		filename = strcat(inputDir, '/bg_thresh.txt');
		bg_thresh = load(filename);
		bg_thresh = bg_thresh*mutliply_factor;

		filename = strcat(inputDir, '/bdi_dirty.txt');
		bdi_dirty = load(filename);
		bdi_dirty = bdi_dirty*mutliply_factor;

		filename = strcat(inputDir, '/bdi_reclaimable.txt ');
                bdi_reclaimable = load(filename);
                bdi_reclaimable = bdi_reclaimable*mutliply_factor;

		filename = strcat(inputDir, '/bdi_writeback.txt');
                bdi_writeback = load(filename);
                bdi_writeback = bdi_writeback*mutliply_factor;

		filename = strcat(inputDir, '/bdi_dirty_thresh.txt');
		bdi_dirty_thresh = load(filename);
		bdi_dirty_thresh = bdi_dirty_thresh*mutliply_factor;

		filename = strcat(inputDir, '/bdi_bg_thresh.txt');
		bdi_bg_thresh = load(filename);
		bdi_bg_thresh = bdi_bg_thresh*mutliply_factor;

		details{1} = sprintf('Min BDI : %d, Max BDI : %d', min_ratio, max_ratio);
%{
		figure;
		clf;
		hold on;
                axis([0 size(dirty_thresh)(1)+10 0 max(dirty_thresh)*1.2]);
		fig1 = plot(dirty_thresh, 'k');
		fig2 = plot(bg_thresh, 'g');
		fig3 = plot(nr_reclaimable, 'c');
		fig4 = plot(bdi_dirty, 'b');
		fig5 = plot(bdi_bg_thresh, 'r');
		fig6 = plot(bdi_dirty_thresh, 'm');
		h_leg = legend('G\_Dirty\_Thres', 'G\_Bg\_Thres', 'G\_NR\_Dirty', 'Bdi\_Dirty', 'Bdi\_Bg\_Thresh', 'Bdi\_Dirty\_Thresh');
		set(fig1(1), "linewidth", 1);
		set(fig2(1), "linewidth", 1);
		set(fig3(1), "linewidth", 1);
		set(fig4(1), "linewidth", 1);
		set(fig5(1), "linewidth", 1);
		set(fig6(1), "linewidth", 1);
		text(size(dirty_thresh)(1)*0.2, max(dirty_thresh) * 1.1, details, 'Color', 'red', 'FontSize', 14);
		xlabel('Start to end page', 'fontsize', 15);
		ylabel('Values in MB', 'fontsize', 15);
		title (sprintf('Dirty Data in %d GB, %s GETXATTR', (io_size*iterations)/(1024*1024*1024), reason), 'fontsize', 15);
                grid minor;
		hold off;
                outfilename = strcat(inputDir, '/Dirty_data_distribution.png');
                print(outfilename, "-dpng");
                close();

		figure;
                clf;
                hold on;
                axis([0 size(bdi_dirty_thresh)(1)+10 0 max(bdi_dirty_thresh)*1.2]);
                fig4 = plot(bdi_dirty, 'b');
                fig5 = plot(bdi_bg_thresh, 'r');
                fig6 = plot(bdi_dirty_thresh, 'k');
                h_leg = legend('Bdi\_Dirty', 'Bdi\_Bg\_Thresh', 'Bdi\_Dirty\_Thresh');
                set(fig4(1), "linewidth", 1);
                set(fig5(1), "linewidth", 1);
                set(fig6(1), "linewidth", 1);
		text(size(bdi_dirty_thresh)(1)*0.2, max(bdi_dirty_thresh) * 1.1, details, 'Color', 'red', 'FontSize', 14);
                xlabel('Start to end page', 'fontsize', 15);
                ylabel('Values in MB', 'fontsize', 15);
                title (sprintf('Bdi Dirty Data in %d GB, %s GETXATTR', (io_size*iterations)/(1024*1024*1024), reason), 'fontsize', 15);
                grid minor;
                hold off;
                outfilename = strcat(inputDir, '/Bdi_Dirty_data_distribution.png');
                print(outfilename, "-dpng");
                close();
%}
		figure;
                clf;
		hold on;
                axis([0 size(bdi_dirty_thresh)(1)+10 0 max(bdi_dirty_thresh)*1.2]);
%                fig4 = plot(bdi_reclaimable, 'b');
                fig5 = plot(bdi_bg_thresh, 'r');
                fig6 = plot(bdi_dirty_thresh, 'k');
%		fig7 = plot(bdi_writeback, 'g');
%                h_leg = legend('Bdi\_Reclaimable', 'Bdi\_Bg\_Thresh', 'Bdi\_Dirty\_Thresh', 'Bdi\_Writeback');
		h_leg = legend('Bdi\_Bg\_Thresh', 'Bdi\_Dirty\_Thresh');
		stacked_details = [bdi_reclaimable bdi_writeback];
		fig7 = bar(stacked_details, 'stacked');
		h_leg = legend(fig7, 'Bdi\_Reclaimable', 'Bdi\_Writeback');
%                set(fig4(1), "linewidth", 1);
                set(fig5(1), "linewidth", 1);
                set(fig6(1), "linewidth", 1);
%		set(fig7(1), "linewidth", 1);
                text(size(bdi_dirty_thresh)(1)*0.2, max(bdi_dirty_thresh) * 1.1, details, 'Color', 'red', 'FontSize', 14);
                xlabel('Start to end page', 'fontsize', 15);
                ylabel('Values in MB', 'fontsize', 15);
                title (sprintf('Bdi Dirty Growth in %d GB, %s GETXATTR', (io_size*iterations)/(1024*1024*1024), reason), 'fontsize', 15);
                grid minor;
                hold off;
                outfilename = strcat(inputDir, '/Bdi_reclaimable_writeback.png');
                print(outfilename, "-dpng");
                close();		
	end
end
end
