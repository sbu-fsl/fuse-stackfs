function plot_profile_points_sq_re_4KB_32th_32f()

hd_type = 'SSD';

commdir1 = sprintf('/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/Profile_Points_Stats/%s/Stat-files-sq-re-4KB-32th-32f-1/', hd_type);

filename1 = strcat(commdir1, '/profile-points-stats.txt');

profile_stats = load(filename1)

figure;
clf;
hold on;
axis([0 size(profile_stats)(1)+1 0 max(max(profile_stats))*1.8]);
fig1 = bar(profile_stats, 'stacked');
h_leg = legend(fig1, 'Bar 1', 'Bar 2', 'Bar 3', 'Bar 4', 'Bar 5', 'Bar 6');
set(h_leg, 'fontsize', 15);
xlabel('Different Files', 'fontsize', 15);
ylabel('Average Latencies (usecs)', 'fontsize', 15);
title(sprintf('Latency split up of read Requests (%s)', hd_type), 'fontsize', 15);
grid minor;
hold off;
outfilename = strcat(commdir1, '/profile_points_stats.png');
print(outfilename, "-dpng");
close();

% remove the Bar 3
profile_stats(:, [3]) = [];
figure;
clf;
hold on;
axis([0 size(profile_stats)(1)+1 0 max(max(profile_stats))*1.8]);
fig1 = bar(profile_stats, 'stacked');
h_leg = legend(fig1, 'Bar 1', 'Bar 2', 'Bar 4', 'Bar 5', 'Bar 6');
set(h_leg, 'fontsize', 15);
xlabel('Different Files', 'fontsize', 15);
ylabel('Average Latencies (usecs)', 'fontsize', 15);
title(sprintf('Latency split up of read Requests (%s)', hd_type), 'fontsize', 15);
grid minor;
hold off;
outfilename = strcat(commdir1, '/profile_points_stats_without_Bar3.png');
print(outfilename, "-dpng");
close();
