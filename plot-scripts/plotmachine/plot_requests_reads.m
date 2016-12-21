function plot_requests_reads()
commdir1 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/';
outputDir = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/plots/';

Types{1} = 'HDD';
Types{2} = 'SSD';

work_load_types{1} = 'sq';
work_load_ops{1} = 're';

io_sizes{1} = '4KB';

threads = [1];
iterations = 1;
files{1} = '1f';

%different requests

reqs{1} = 'INIT';
reqs{2} = 'LOOKUP';
reqs{3} = 'OPEN';
reqs{4} = 'READ';
reqs{5} = 'FLUSH';
reqs{6} = 'RELEASE';
reqs{7} = 'GETATTR';

labels = [1 2 3 4 5 6 7];
results = [ 1 1 1 0; 0 34 34 34; 0 32 32 32; 491595 491595 491595 491595; 0 32 32 32; 32 32 32 32; 0 1 1 1];
figure;
clf;
hold on;
h = bar(log(results));

set(h(1), 'facecolor', 'r');
set(h(2), 'facecolor', 'b');
set(h(3), 'facecolor', 'g');
set(h(4), 'facecolor', 'y');

a = results(:, 3);
b = num2str(a);
c = cellstr(b);
dx=1;
dy=0.5;
text(labels-dx, log(results(:, 3))+dy, c, 'FontSize', 20);

axis([0 size(results)(1)+1 0 (max(max(log(results))))*1.2]);

set(gca, 'XTick', labels, 'XTickLabel', reqs);

xlabel('Different FUSE Operations', 'fontsize', 15);
ylabel('Fuse Requests absolute numbers(in log scale)', 'fontsize', 15);
h_leg = legend('Background Queue', 'Pending Queue', 'Processing Queue', 'User daemon');
set(h_leg, 'fontsize', 10);
title('Different operations across all the read workloads', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/Requests/different-operations-read-workloads.png');
print(outfilename, "-dpng");
close();
