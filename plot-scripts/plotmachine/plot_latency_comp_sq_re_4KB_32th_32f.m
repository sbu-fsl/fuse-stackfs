function plot_latency_comp_sq_re_4KB_32th_32f()

hd_type = 'HDD';

commdir1 = sprintf('/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/Stack_bars/%s/Stat-files-sq-re-4KB-32th-32f-1/', hd_type);

filename1 = strcat(commdir1, '/read-stats.txt');
filename2 = strcat(commdir1, '/stackfs_pread_details.txt');

fuse_reads = load(filename1);
user_reads = load(filename2);

comps = [ user_reads(:, 2) (fuse_reads(:, 2) - user_reads(:, 2))];

figure;
clf;
hold on;
axis([0 size(comps)(1)+1 0 max(fuse_reads(:, 2))*1.2]);
fig1 = bar(comps, 'stacked');
h_leg = legend(fig1, sprintf('User daemon(%s)', hd_type), 'Fuse F/S');
xlabel('Different Files', 'fontsize', 15);
ylabel('Average Latencies (msecs)', 'fontsize', 15);
title('Latency split up of Fuse and user daemon for reads', 'fontsize', 15);
grid minor;
hold off;
outfilename = strcat(commdir1, '/latency_comps.png');
print(outfilename, "-dpng");
close();
