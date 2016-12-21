function plot_latency_analysis_sq_re_32th_32f()

commdir1 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/Analysis/';
outputDir = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/Analysis/plots/';

Types{1} = 'No-Fuse';
%Types{2} = 'Default-Fuse';
%Types{2} = 'Multi-Fuse';
Types{2} = 'Multi-100th-Fuse';

work_load_type = 'sq';
work_load_op = 're';

io_size = '4KB';

thread = 32;
file = '32f';

dir1=strcat(commdir1, sprintf('%s/', Types{1}));
dir2=strcat(commdir1, sprintf('%s/', Types{2}));

inputDir1 = strcat(dir1, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, 1));
inputDir2 = strcat(dir2, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, 1));

filename1 = strcat(inputDir1, 'read-stats.txt');
filename2 = strcat(inputDir2, 'read-stats.txt');

no_fuse_read_stats = load(filename1);
default_fuse_read_stats = load(filename2);

read_comparision = [no_fuse_read_stats default_fuse_read_stats];

figure;
clf;
hold on;

h = bar(read_comparision);
set(h(1), 'facecolor', 'b');
set(h(2), 'facecolor', 'g');

axis([0 size(read_comparision)(1)+1 0 max(max(read_comparision))*1.5]);
xlabel('Different Files', 'fontsize', 15);
ylabel('Different times (msecs)', 'fontsize', 15);
title('Avg. Latency per read reqs. (HDD)(Fuse-Multi-100th)', 'fontsize', 15);
h_leg = legend('Ext4', 'Fuse-Ext4(Multi-100th)');
set(h_leg, 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, sprintf('/Latency-Read-Reqs-%s-%s-%dth-%s.png',  work_load_type, work_load_op, thread, file));
print(outfilename, "-dpng");
close();


filename2 = strcat(inputDir2, 'bg-stats.txt');
filename3 = strcat(inputDir2, 'pending-stats.txt');
filename4 = strcat(inputDir2, 'processing-stats.txt');

bg_stats = load(filename2);
pending_stats = load(filename3);
processing_stats = load(filename4);

comparision = [bg_stats pending_stats processing_stats];

figure;
clf;
hold on;

h = bar(comparision);
set(h(1), 'facecolor', 'b');
set(h(2), 'facecolor', 'g');
set(h(3), 'facecolor', 'r');

axis([0 size(comparision)(1)+1 0 max(max(comparision))*1.5]);
xlabel('Different Files', 'fontsize', 15);
ylabel('Different times (msecs)', 'fontsize', 15);
title('Avg Latency per req. in diff. queues (HDD)(Fuse-Multi-100th)', 'fontsize', 15);
h_leg = legend('BG', 'Pending', 'Processing');
set(h_leg, 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, sprintf('/Latency-Reqs-diff-queues-%s-%s-%dth-%s.png',  work_load_type, work_load_op, thread, file));
print(outfilename, "-dpng");
close();

filename1 = strcat(inputDir2, 'bg_lengths.txt');
filename2 = strcat(inputDir2, 'pending_lengths.txt');
filename3 = strcat(inputDir2, 'processing_lengths.txt');

bg_lengths = load(filename1);
pending_lengths = load(filename2);
processing_lengths = load(filename3);

figure;
clf;
hold on;
h = plot(bg_lengths);
axis([0 size(bg_lengths)(1)+1 0 max(bg_lengths)*1.5]);
xlabel('After Every Request Completion', 'fontsize', 15);
ylabel('Length of BG queue', 'fontsize', 15);
title('Requests across Bg Queue (HDD)(Fuse-Multi-100th)', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, sprintf('/BG-Queue-Lengths-%s-%s-%dth-%s.png',  work_load_type, work_load_op, thread, file));
print(outfilename, "-dpng");
close();

figure;
clf;
hold on;
h = plot(pending_lengths);
axis([0 size(pending_lengths)(1)+1 0 max(pending_lengths)*1.5]);
xlabel('After Every Request Completion', 'fontsize', 15);
ylabel('Length of Pending queue', 'fontsize', 15);
title('Requests across Pending Queue (HDD)(Fuse-Multi-100th)', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, sprintf('/Pending-Queue-Lengths-%s-%s-%dth-%s.png',  work_load_type, work_load_op, thread, file));
print(outfilename, "-dpng");
close();

figure;
clf;
hold on;
h = plot(processing_lengths);
axis([0 size(processing_lengths)(1)+1 0 max(processing_lengths)*1.5]);
xlabel('After Every Request Completion', 'fontsize', 15);
ylabel('Length of Processing queue', 'fontsize', 15);
title('Requests across Processing Queue (HDD)(Fuse-Multi-100th)', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, sprintf('/Processing-Queue-Lengths-%s-%s-%dth-%s.png',  work_load_type, work_load_op, thread, file));
print(outfilename, "-dpng");
close();
