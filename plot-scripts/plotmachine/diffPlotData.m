function diffPlotData()
%Hard coded experiment details
details{1} = 'Experiment type : Sequential Write of 45 GB';
%details{2} = 'write\_back\_cache : No (default)';
details{2} = 'max\_write : Along the X-axis';
%details{4} = 'big\_writes : Yes';
details{3} = 'max\_bg\_length : 12 (default)';
details{4} = 'congestion\_threshold : 9 (default)';

%X-axis Values
lables{1} = '4KB';
lables{2} = '8KB';
lables{3} = '16KB';
lables{4} = '32KB';
lables{5} = '64KB';
lables{6} = '128KB';
lables{7} = '256KB';
lables{8} = '512KB';
lables{9} = '1MB';
lables{10} = '2MB';
lables{11} = '4MB';
lables{12} = '8MB';
lables{13} = '16MB';
lables{14} = '32MB';
lables{15} = '64MB';

%Different queue lengths
%{
no_write_back_queue =  [  1  2 1;   1 1  1; 1   1  1; 1  1  1; 1  1  1; 1 1  1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1; 1 1 1];
yes_write_back_queue = [240 13 1; 212 13 1; 105 13 1; 46 13 1; 16 13 1; 2 13 1; 1 9 1; 1 8 1; 1 3 1; 1 9 1; 1 9 1; 1 4 1; 1 9 1; 1 2 1; 1 2 1];


figure;
clf;
hold on;
bar(no_write_back_queue);
axis([0 size(no_write_back_queue)(1)+2 0 max(max(no_write_back_queue))+5]);
set(gca, 'XTick', 1:size(no_write_back_queue)(1), 'XTickLabel', lables);
xlabel('Different max\_write sizes', 'fontsize', 15);
ylabel('Max. No. of Requests in each queue', 'fontsize', 15);
title ('Requests in each queue over the experiments', 'fontsize', 15);
legend('Background queue', 'Pending queue', 'Processing queue');
text(2, min(min(no_write_back_queue))+3, details, 'Color', 'red', 'FontSize', 14);
hold off;
dir = pwd();
print(strcat(dir, '/../plots/diff_no_write_back_queuelengths.png'), "-dpng");
close();
figure;
clf;
hold on;
h = bar(yes_write_back_queue);
axis([0 size(yes_write_back_queue)(1)+2 0 max(max(yes_write_back_queue))+20]);
set(gca, 'XTick', 1:size(yes_write_back_queue)(1), 'XTickLabel', lables);
xlabel('Different max\_write sizes', 'fontsize', 15);
ylabel('Max. No. of Requests in each queue', 'fontsize', 15);
title ('Requests in each queue over the experiments', 'fontsize', 15);
legend('Background queue', 'Pending queue', 'Processing queue');
ybuff=2;
for i=1:length(h)
    XDATA=get(get(h(i),'Children'),'XData');
    YDATA=get(get(h(i),'Children'),'YData');
    for j=1:size(XDATA,2)
        x=XDATA(1,j)+(XDATA(3,j)-XDATA(1,j))/2;
        y=YDATA(2,j)+ybuff;
        t=[num2str(YDATA(2,j),3) ,''];
%        text(x,y,t,'Color','k','HorizontalAlignment','left','Rotation',90)
	text(x,y,t,'Color','k','HorizontalAlignment','center','VerticalAlignment', 'bottom')
    end
end
%grid minor;
details{2} = 'write\_back\_cache : Yes';
details{4} = 'big\_writes : No';
text(5, 150, details, 'Color', 'red', 'FontSize', 14);
hold off;
dir = pwd();
print(strcat(dir, '/../plots/diff_yes_write_back_queuelengths.png'), "-dpng");
close();


%FUSE_WRITE Reqs
no_writeback_writereqs =  [11796480; 5898240; 2949120; 1474560; 737280; 368640; 184320; 92160; 46080; 23040; 11520; 5760; 2880; 1440; 720];
yes_writeback_writereqs = [10725537; 5620396; 2865048; 1454872; 730927; 368797; 196222; 99224; 64762; 32349; 32330; 32330; 32339; 32275; 33887];
no_writeback_writereqs1 = log(no_writeback_writereqs);
yes_writeback_writereqs1 = log(yes_writeback_writereqs);
figure;
clf;
hold on;
fig3 = plot(no_writeback_writereqs1, 'r');
grid minor;
set(fig3(1), "linewidth", 2);
for i=1:size(no_writeback_writereqs)(1)
	text(i, no_writeback_writereqs1(i)-2, num2str(no_writeback_writereqs(i)),'HorizontalAlignment','center');
end
fig4 = plot(yes_writeback_writereqs1, 'g');
set(fig4(1), "linewidth", 2);
for i=1:size(yes_writeback_writereqs)(1)
	text(i, yes_writeback_writereqs1(i)+2, num2str(yes_writeback_writereqs(i)),'HorizontalAlignment','center');
end
axis([0 size(yes_writeback_writereqs)(1)+2 0 max(max(no_writeback_writereqs1), max(yes_writeback_writereqs1))+50]);
text(1, 50, details, 'Color', 'red', 'FontSize', 14);
set(gca, 'XTick', 1:size(no_writeback_writereqs)(1), 'XTickLabel', lables);
xlabel('Different max\_write sizes', 'fontsize', 15);
ylabel('FUSE\_WRITE Req count (in log)', 'fontsize', 15);
title ('Comparison of Write Req. Counts', 'fontsize', 15);
legend('writeback\_cache = No, big\_writes = Yes', 'writeback\_cache = Yes');
hold off;
dir = pwd();
print(strcat(dir, '/../plots/diff_write_req_count.png'), "-dpng");
close();
%}
%Run Time Comparision
no_writeback_times  = [  393;  227; 175; 122;  95; 107;  80; 78;  91; 82; 77; 82; 82; 82; 137];
yes_writeback_times = [14466; 7233; 364; 166; 135; 105; 113; 95; 104; 96; 94; 93; 96; 92; 102];
figure;
clf;
hold on;
fig3 = plot(no_writeback_times, 'r');
grid minor;
set(fig3(1), "linewidth", 2);
%for i=1:size(no_writeback_times)(1)
%        text(i, no_writeback_writereqs1(i)-2, num2str(no_writeback_writereqs(i)),'HorizontalAlignment','center');
%end
fig4 = plot(yes_writeback_times, 'g');
set(fig4(1), "linewidth", 2);
%for i=1:size(yes_writeback_writereqs)(1)
%        text(i, yes_writeback_writereqs1(i)+2, num2str(yes_writeback_writereqs(i)),'HorizontalAlignment','center');
%end
axis([0 size(yes_writeback_times)(1)+2 0 max(max(no_writeback_times), max(yes_writeback_times))+1000]);
text(4, 8000, details, 'Color', 'red', 'FontSize', 14);
set(gca, 'XTick', 1:size(yes_writeback_times)(1), 'XTickLabel', lables);
xlabel('Different max\_write sizes', 'fontsize', 15);
ylabel('Time(sec) to complete the experiment', 'fontsize', 15);
title ('Comparison of Time (from filebench)', 'fontsize', 15);
legend('writeback\_cache = No, big\_writes = Yes', 'writeback\_cache = Yes');
hold off;
dir = pwd();
print(strcat(dir, '/../plots/diff_times.png'), "-dpng");
close();
