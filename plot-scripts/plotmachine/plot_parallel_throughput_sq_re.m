function plot_parallel_throughput_sq_re()

hd_type = 'HDD';

commdir1 = sprintf('/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/fio_results/%s/', hd_type);

counts{1} = '1';
counts{2} = '2';
counts{3} = '4';
counts{4} = '8';
counts{5} = '16';
counts{6} = '32';
counts{7} = '64';

io_sizes{1} = '128KB';
io_sizes{2} = '256KB';
io_sizes{3} = '512KB';
io_sizes{4} = '1MB';

X=[1;2;3;4;5;6;7];
ops_sec_comp = [];
for j=1:size(io_sizes)(2)
	io_size=io_sizes{j};
	temp = [];
	for i=1:size(counts)(2)
		count=counts{i};
		filename = strcat(commdir1, sprintf('/%s/Stat-files-rand-read-disk-%s-%d/iops.txt', io_size, count, 1));
		ops_sec = load(filename);
		temp = [temp ; ops_sec];
	end
	ops_sec_comp = [ops_sec_comp temp];
end

ops_sec_comp


figure;
clf;
hold on;

fig1 = plot(ops_sec_comp(:,1), 'b--*');
set(fig1(1), "linewidth", 6);

fig2 = plot(ops_sec_comp(:,2), 'g--*');
set(fig2(1), "linewidth", 6);

fig3 = plot(ops_sec_comp(:,3), 'r--*');
set(fig3(1), "linewidth", 6);

fig4 = plot(ops_sec_comp(:,4), 'k--*');
set(fig4(1), "linewidth", 6);

legend('128KB I/O', '256KB I/O', '512KB I/O', '1MB I/O');

axis([0 size(ops_sec_comp(:,1))(1)+1 0 max(ops_sec_comp(:,1))*1.2]);
set(gca, 'XTick', 1:7, 'XTickLabel', counts);
grid minor;

a = ops_sec_comp(:, 1);
b = num2str(ops_sec_comp(:, 1));
c = cellstr(b);
dx=0.25;
dy=10;
text(X-dx, ops_sec_comp(:, 1)+dy, c, 'FontSize', 10);

a = ops_sec_comp(:, 2);
b = num2str(ops_sec_comp(:, 2));
c = cellstr(b);
dx=0.25;
dy=10;
text(X-dx, ops_sec_comp(:, 2)+dy, c, 'FontSize', 10);

a = ops_sec_comp(:, 3);
b = num2str(ops_sec_comp(:, 3));
c = cellstr(b);
dx=0.25;
dy=10;
text(X-dx, ops_sec_comp(:, 3)+dy, c, 'FontSize', 10);

a = ops_sec_comp(:, 4);
b = num2str(ops_sec_comp(:, 4));
c = cellstr(b);
dx=0.25;
dy=10;
text(X-dx, ops_sec_comp(:, 4)+dy, c, 'FontSize', 10);

xlabel('Different threads used for workload', 'fontsize', 15);
ylabel('Fio operations per second', 'fontsize', 15);

title(sprintf('ops/sec comparision on parallel I/O (%s)', hd_type), 'fontsize', 15);
outfilename = strcat(commdir1, 'throughput_comp_parallel_io.png');
print(outfilename, "-dpng");
close();
