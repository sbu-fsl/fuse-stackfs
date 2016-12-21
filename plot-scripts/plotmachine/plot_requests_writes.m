function plot_requests_writes()
commdir1 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/';
outputDir = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/plots/';

Types{1} = 'HDD';
Types{2} = 'SSD';

work_load_types{1} = 'sq';
work_load_ops{1} = 'wr';

io_sizes{1} = '4KB';

threads = [1];
iterations = 1;
files{1} = '1f';

%different requests

reqs{1} = 'INIT';
reqs{2} = 'LOOKUP';
reqs{3} = 'GETATTR';
reqs{4} = 'CREATE';
reqs{5} = 'GETXATTR';
reqs{6} = 'WRITE';
reqs{7} = 'FLUSH';
reqs{8} = 'RELEASE';

labels = [1 2 3 4 5 6 7 8];
requests = [1 1 1 0; 0 34 34 34; 0 12 12 12; 0 32 32 32; ; 0 1 1 0; 0 15728640 15728640 15728640; 0 32 32 32; 32 32 32 32];

figure;
clf;
hold on;
h = bar(log(requests));

set(h(1), 'facecolor', 'r');
set(h(2), 'facecolor', 'b');
set(h(3), 'facecolor', 'g');
set(h(4), 'facecolor', 'y');

a = requests(:, 3);
b = num2str(a);
c = cellstr(b);
dx=1.3;
dy=0.5;
text(labels-dx, log(requests(:, 3))+dy, c, 'FontSize', 20);

axis([0 size(requests)(1)+1 0 (max(max(log(requests))))*1.2]);

set(gca, 'XTick', labels, 'XTickLabel', reqs);

xlabel('Different FUSE Operations', 'fontsize', 15);
ylabel('Fuse Requests absolute numbers(in log scale)', 'fontsize', 15);
h_leg = legend('Background Queue', 'Pending Queue', 'Processing Queue', 'User daemon');
set(h_leg, 'fontsize', 10);
title('Different operations across all the write workloads', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/Requests/different-operations-write-workloads.png');
print(outfilename, "-dpng");
close();
