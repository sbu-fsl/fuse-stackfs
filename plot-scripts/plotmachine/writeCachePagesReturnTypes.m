function writeCachePagesReturnTypes()

inputDir = '/Users/Bharath/Downloads/FUSE/raw_data/Results/Stat-files-writebackcache-HotStorage-cacheexits/';
outputDir = '/Users/Bharath/Downloads/FUSE/plots/Plots-HotStorage/';

%X-axis Values
lables{1} = '32KB';
lables{2} = '64KB';
lables{3} = '128KB';
lables{4} = '256KB';
lables{5} = '512KB';
lables{6} = '1MB';
lables{7} = '2MB';
lables{8} = '4MB';
lables{9} = '8MB';
lables{10} = '16MB';
lables{11} = '32MB';
lables{12} = '64MB';

details{1} = 'write\_back\_cache : Yes';
details{2} = 'max\_write : Yes, On X-Axis (in pages)';
details{3} = 'big\_writes : No';
details{4} = 'max\_bg\_length : 12 (default)';
details{5} = 'congestion\_threshold : 9 (default)';
details{6} = '1 MB I/O Iterations = 61440, 60GB (Hot Storage)';
details{7} = 'RAM Size : 4 GB (Hot Storage)';

max_writes = [32768;65536;131072;262144;524288;1048576;2097152;4194304;8388608;16777216;33554432;67108864];
iterations = 61440;

Total_iters = 10;

return_type_cnt = [];
max_write_pages = [];
for i=1:size(max_writes)(1)		%Maximum writes tried
        for j=iterations:iterations	%I/O iteration from filebench
		temp_return_type_cnt = zeros(5, 1, "uint64");
                for count=1:Total_iters	%avergae over these many iterations
                        max_write = max_writes(i);
                        iteration = iterations;
                        filename = strcat(inputDir, sprintf('/Stat-files-%d-%d-Final-%d/write_cache_pages_return', max_write, iteration, count));
                        return_types = load(filename);
                        pages = max_write/4096;
			temp_return_type_cnt = temp_return_type_cnt + return_types;
                end
                max_write_pages = [max_write_pages;pages];
		temp_return_type_cnt = temp_return_type_cnt./Total_iters;
		return_type_cnt = [return_type_cnt temp_return_type_cnt];
        end
end
return_type_cnt = transpose(return_type_cnt(2:end, :));
figure;
clf;
hold on;
h = bar(return_type_cnt);
axis([0 size(return_type_cnt)(1)+2 0 max(max(return_type_cnt))*1.2]);
set(gca, 'XTick', 1:size(return_type_cnt)(1), 'XTickLabel', lables);
xlabel('Different max\_write sizes and return types from write cache pages', 'fontsize', 15);
ylabel('No. of times write cache page func. returned', 'fontsize', 15);
title ('Different return types count over the experiment', 'fontsize', 15);
legend('No Pages (Lookup)', 'Already truncated/Invalidated', 'Error in Write Page', 'No Pages (wbc)');
ybuff=2;
for i=1:length(h)
    XDATA=get(get(h(i),'Children'),'XData');
    YDATA=get(get(h(i),'Children'),'YData');
    for j=1:size(XDATA,2)
        x=XDATA(1,j)+(XDATA(3,j)-XDATA(1,j))/2;
        y=YDATA(2,j)+ybuff;
        t=[num2str(YDATA(2,j),3) ,''];
        text(x,y,t,'Color','k','HorizontalAlignment','left','Rotation',90)
%        text(x,y,t,'Color','k','HorizontalAlignment','center','VerticalAlignment', 'bottom')
    end
end
text(3, max(max(return_type_cnt)) * 0.9, details, 'Color', 'red', 'FontSize', 14);
hold off;
outfilename = strcat(outputDir, '/write_cache_return_type.png');
print(outfilename, "-dpng");
close();
