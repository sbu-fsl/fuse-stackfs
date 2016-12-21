function plot_analysis_sq_re_32th_32f()

commdir1 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/';
outputDir = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/plots/';

Types{1} = 'HDD';
Types{2} = 'SSD';

work_load_type = 'sq';
work_load_op = 're';

io_size = '4KB';

buckets{1} = '2ns';
buckets{2} = '';
buckets{3} = '';
buckets{4} = '';
buckets{5} = '32ns';
buckets{6} = '';
buckets{7} = '';
buckets{8} = '';
buckets{9} = '';
buckets{10} = '1us';
buckets{11} = '';
buckets{12} = '';
buckets{13} = '';
buckets{14} = '';
buckets{15} = '32us';
buckets{16} = '';
buckets{17} = '';
buckets{18} = '';
buckets{19} = '';
buckets{20} = '1ms';
buckets{21} = '';
buckets{22} = '';
buckets{23} = '';
buckets{24} = '';
buckets{25} = '32ms';
buckets{26} = '';
buckets{27} = '';
buckets{28} = '';
buckets{29} = '';
buckets{30} = '1s';
buckets{31} = '';
buckets{32} = '4s';
buckets{33} = '';

yaxis{1} = '2';
yaxis{2} = '4';
yaxis{3} = '8';
yaxis{4} = '16';
yaxis{5} = '32';
yaxis{6} = '64';
yaxis{7} = '128';
yaxis{8} = '256';
yaxis{9} = '512';
yaxis{10} = '1024';
yaxis{11} = '2048';
yaxis{12} = '4096';
yaxis{13} = '8192';
yaxis{14} = '16384';
yaxis{15} = '32768';
yaxis{16} = '65536';
yaxis{17} = '131072';
yaxis{18} = '262144';
yaxis{19} = '524288';
yaxis{20} = '1048576';


thread = 32;
file = '32f';

dir1=strcat(commdir1, sprintf('%s-FUSE-EXT4-Results', Types{1}));
dir2=strcat(commdir1, sprintf('%s-FUSE-EXT4-Results', Types{2}));

inputDir1 = strcat(dir1, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, 1));
inputDir2 = strcat(dir2, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, 1));

filename1 = strcat(inputDir1, 'FUSE_READ_user_processing_distribution.txt');
filename2 = strcat(inputDir2, 'FUSE_READ_user_processing_distribution.txt');

hdd_read_reqs = load(filename1);
ssd_read_reqs = load(filename2);

hdd_read_reqs = hdd_read_reqs(1 : (size(hdd_read_reqs)(1) - 1));
ssd_read_reqs = ssd_read_reqs(1 : (size(ssd_read_reqs)(1) - 1));

ex = [hdd_read_reqs ssd_read_reqs];
log2(ex);
figure;
clf;
hold on;

h = bar(log2(ex));
set(h(1), 'facecolor', 'b');
set(h(2), 'facecolor', 'g');
axis([0 size(log2(ex))(1)+1 0 20]);
set(gca, 'XTick', 1:size(log2(ex))(1), 'XTickLabel', buckets);
set(gca, 'YTick', 1:20, 'YTickLabel', yaxis);
xlabel('Absolute values of requests', 'fontsize', 15);
ylabel('Different times', 'fontsize', 15);
title(sprintf('%s %s %d %s Read request user->ext4 latency buckets', work_load_type, work_load_op, thread, file), 'fontsize', 15);
h_leg = legend('HDD', 'SSD');
set(h_leg, 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, sprintf('/Requests/Read-dist-user-proc-%s-%s-%dth-%s.png',  work_load_type, work_load_op, thread, file));
print(outfilename, "-dpng");
close();

filename1 = strcat(inputDir1, 'FUSE_READ_processing_distribution.txt');
filename2 = strcat(inputDir2, 'FUSE_READ_processing_distribution.txt');

hdd_read_reqs = load(filename1);
ssd_read_reqs = load(filename2);

hdd_read_reqs = hdd_read_reqs(1 : (size(hdd_read_reqs)(1) - 1));
ssd_read_reqs = ssd_read_reqs(1 : (size(ssd_read_reqs)(1) - 1));

ex = [hdd_read_reqs ssd_read_reqs];
log2(ex);
figure;
clf;
hold on;

h = bar(log2(ex));
set(h(1), 'facecolor', 'b');
set(h(2), 'facecolor', 'g');
axis([0 size(log2(ex))(1)+1 0 20]);
set(gca, 'XTick', 1:size(log2(ex))(1), 'XTickLabel', buckets);
set(gca, 'YTick', 1:20, 'YTickLabel', yaxis);
xlabel('Absolute values of requests', 'fontsize', 15);
ylabel('Different times', 'fontsize', 15);
title(sprintf('%s %s %d %s Read request proc->user latency buckets', work_load_type, work_load_op, thread, file), 'fontsize', 15);
h_leg = legend('HDD', 'SSD');
set(h_leg, 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, sprintf('/Requests/Read-dist-kern-proc-%s-%s-%dth-%s.png',  work_load_type, work_load_op, thread, file));
print(outfilename, "-dpng");
close();

filename1 = strcat(inputDir1, 'FUSE_READ_pending_distribution.txt');
filename2 = strcat(inputDir2, 'FUSE_READ_pending_distribution.txt');

hdd_read_reqs = load(filename1);
ssd_read_reqs = load(filename2);

hdd_read_reqs = hdd_read_reqs(1 : (size(hdd_read_reqs)(1) - 1));
ssd_read_reqs = ssd_read_reqs(1 : (size(ssd_read_reqs)(1) - 1));

ex = [hdd_read_reqs ssd_read_reqs];
log2(ex);
figure;
clf;
hold on;

h = bar(log2(ex));
set(h(1), 'facecolor', 'b');
set(h(2), 'facecolor', 'g');
axis([0 size(log2(ex))(1)+1 0 20]);
set(gca, 'XTick', 1:size(log2(ex))(1), 'XTickLabel', buckets);
set(gca, 'YTick', 1:20, 'YTickLabel', yaxis);
xlabel('Absolute values of requests', 'fontsize', 15);
ylabel('Different times', 'fontsize', 15);
title(sprintf('%s %s %d %s Read request pend->proc latency buckets', work_load_type, work_load_op, thread, file), 'fontsize', 15);
h_leg = legend('HDD', 'SSD');
set(h_leg, 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, sprintf('/Requests/Read-dist-pend-proc-%s-%s-%dth-%s.png',  work_load_type, work_load_op, thread, file));
print(outfilename, "-dpng");
close();
