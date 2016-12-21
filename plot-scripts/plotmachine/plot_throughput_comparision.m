function plot_throughput_comparision()

%{
What does this plot do ?
1. Read throughput numbers that were obtained from filebench results,
2. Compare them with Ext4, Fuse-Ext4 results,
3. Read ops/sec numbers that were obtained from filebench results,
4. Compare them with Ext4, Fuse-Ext4 results,
5. Standard deviation numbers but just to check (will remove)
%}

commdir1 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/';
commdir2 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/';
outputDir = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/plots/';

Types{1} = 'HDD';
%Types{1} = 'SSD';

work_load_types{1} = 'sq';
work_load_types{2} = 'rd';

work_load_ops{1} = 'wr';
work_load_ops{2} = 're';

io_sizes{1} = '4KB';
io_sizes{2} = '32KB';
io_sizes{3} = '128KB';
io_sizes{4} = '1MB';

threads = [1 ; 32];
iterations = 3;
files=[];
throughput_comp=[];

X = [1; 2; 3; 4];
for t=1:size(Types)(2)
type=Types{t};
dir1=strcat(commdir1, sprintf('%s-EXT4-Results', type));
dir2=strcat(commdir2, sprintf('%s-FUSE-EXT4-Results', type));
dir3=strcat(commdir1, sprintf('%s-FUSE-OPTS-EXT4-Results', type));
for i=1:size(work_load_types)(2)
	work_load_type=work_load_types{i};

	for j=1:size(work_load_ops)(2)
		work_load_op=work_load_ops{j};
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		for k=1:size(threads)(1)
			thread=threads(k);
			%%%%%%%%%%%%%%%%%%%%
			if ( eq(strcmp(work_load_type, 'sq'), 1) && eq(strcmp(work_load_op, 'wr'), 1) )
				if (eq(thread, 1))
					files = [];
                                        files{1} = '1f';
                                elseif (eq(thread, 32))
					files = [];
                                        files{1} = '32f';
                                endif
			elseif ( eq(strcmp(work_load_type, 'rd'), 1) && eq(strcmp(work_load_op, 'wr'), 1) )
				files = [];
				files{1} = '1f';
			elseif ( eq(strcmp(work_load_type, 'sq'), 1) && eq(strcmp(work_load_op, 're'), 1) )
				if (eq(thread, 1))
					files = [];
					files{1} = '1f';
				elseif (eq(thread, 32))
					files = [];
					files{1} = '1f';
					files{2} = '32f';
				endif
			elseif ( eq(strcmp(work_load_type, 'rd'), 1) && eq(strcmp(work_load_op, 're'), 1) )
				files=[];
				files{1} = '1f';
			endif
			for l=1:size(files)(2)
				file=files{l};
				%%%%%%%%%%%%%%
				throughput_comp = [];
				throughput_comp_std = [];
				ops_sec_comp = [];
				ops_sec_comp_std = [];
				
				for m=1:size(io_sizes)(2)
					io_size=io_sizes{m};
					%%%%%%%%%%%%%%%%%%%
					avg_ext4_throughput = [];
					avg_fuse_ext4_throughput = [];
					avg_fuse_opts_ext4_throughput = [];

					avg_ext4_ops_sec = [];
					avg_fuse_ext4_ops_sec = [];
					avg_fuse_opts_ext4_ops_sec = [];
					for n=1:iterations
						count=n;
						%Stat-files-sq-wr-4KB-1th-1f-1
						inputDir1 = strcat(dir1, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, count));
						inputDir2 = strcat(dir2, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, count));
						inputDir3 = strcat(dir3, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, count));	
						filename1 = strcat(inputDir1, 'throughput.txt');
						filename2 = strcat(inputDir2, 'throughput.txt');
						filename3 = strcat(inputDir2, 'throughput.txt');
						
						ext4_throughput = load(filename1);
						fuse_ext4_throughput = load(filename2);
						fuse_opts_ext4_throughput = load(filename3);

						avg_ext4_throughput = [avg_ext4_throughput ; mean(ext4_throughput)];
						avg_fuse_ext4_throughput = [avg_fuse_ext4_throughput ; mean(fuse_ext4_throughput)];
						avg_fuse_opts_ext4_throughput = [avg_fuse_opts_ext4_throughput ; mean(fuse_opts_ext4_throughput)];

						filename1 = strcat(inputDir1, 'ops_sec.txt');
						filename2 = strcat(inputDir2, 'ops_sec.txt');
						filename3 = strcat(inputDir3, 'ops_sec.txt');

						ext4_ops_sec = load(filename1);
						fuse_ext4_ops_sec = load(filename2);
						fuse_opts_ext4_ops_sec = load(filename3);

						avg_ext4_ops_sec = [avg_ext4_ops_sec ; mean(ext4_ops_sec)];
						avg_fuse_ext4_ops_sec = [avg_fuse_ext4_ops_sec ; mean(fuse_ext4_ops_sec)];
						avg_fuse_opts_ext4_ops_sec = [avg_fuse_opts_ext4_ops_sec ; mean(fuse_opts_ext4_ops_sec)];
					end

					throughput_comp = [ throughput_comp; mean(avg_ext4_throughput)  mean(avg_fuse_ext4_throughput) mean(avg_fuse_opts_ext4_throughput) ];
					%throughput_comp_std = [throughput_comp_std; std(avg_ext4_throughput) std(avg_fuse_ext4_throughput)];
					A = mean(avg_ext4_ops_sec);
					B = mean(avg_fuse_ext4_ops_sec);
					C = mean(avg_fuse_opts_ext4_ops_sec);

					std_A = std(avg_ext4_ops_sec);
					std_B = std(avg_fuse_ext4_ops_sec);
					std_C = std(avg_fuse_opts_ext4_ops_sec);

					ops_sec_comp = [ops_sec_comp ; A B C ((A-B)/A)*100  ((A-C)/A)*100];
					ops_sec_comp_std = [ops_sec_comp_std ; (std_A/A)*100 (std_B/B)*100 (std_C/C)*100 ];
					%ops_sec_comp = [ops_sec_comp ; A B C];
					%ops_sec_comp_std = [ops_sec_comp_std ; std(avg_ext4_ops_sec) std(avg_fuse_ext4_ops_sec)];

				end
				work_load_type
				work_load_op
				thread
				file
%				ops_sec_comp
				ops_sec_comp_std

				%%%%%%%%%%%%
				
%{
				figure;
				clf;
				hold on;
				h = bar(throughput_comp);

				a = throughput_comp(:, 1);
				b = num2str(a);
				c = cellstr(b);
				dx=0.5;
				dy=2;
				text(X-dx, throughput_comp(:, 1)+dy, c, 'FontSize', 10);
				a = throughput_comp(:, 2);
				b = num2str(a);
				c = cellstr(b);
				dx=0.5;
				dy=2;
				text(X, throughput_comp(:, 2)+dy, c, 'FontSize', 10);
				if (max(max(throughput_comp)) == 0)
					axis([0 size(throughput_comp)(1)+1 0 2]);
				else
					axis([0 size(throughput_comp)(1)+1 0 max(max(throughput_comp))*1.5]);
				endif
				set(gca, 'XTick', 1:4, 'XTickLabel', io_sizes);
				xlabel('Different I/O sizes', 'fontsize', 15);
				h_leg = legend('Ext4', 'Fuse Ext4');
				set(h_leg, 'fontsize', 10);
				if (strcmp(work_load_op, 're'))
					ylabel('Read ThroughPut (in mb/s)', 'fontsize', 15);
				elseif(strcmp(work_load_op, 'wr'))
					ylabel('Write ThroughPut (in mb/s)', 'fontsize', 15);
				endif
				title(sprintf('%s %s %d %s', work_load_type, work_load_op, thread, file), 'fontsize', 15);
				hold off;
				outfilename = strcat(outputDir, sprintf('/ThroughPut/%s/ThroughPut-comp-%s-%s-%dth-%s.png', type, work_load_type, work_load_op, thread, file));
				print(outfilename, "-dpng");
				close();


				figure;
                                clf;
                                hold on;

                                h = bar(log(ops_sec_comp));
				set(h(1), 'facecolor', 'g');
				set(h(2), 'facecolor', 'r');
				set(h(3), 'facecolor', 'b');

                                a = ops_sec_comp(:, 1);
                                b = num2str(a);
                                c = cellstr(b);
                                dx=0.5;
                                dy=20;
                                text(X-dx, ops_sec_comp(:, 1)+dy, c, 'FontSize', 10); %for native Ext4

                                a = ops_sec_comp(:, 2);
                                b = num2str(a);
                                c = cellstr(b);
                                dx=0.5;
                                dy=20;
                                text(X, ops_sec_comp(:, 2)+dy, c, 'FontSize', 10); %for default Fuse-Ext4

                                a = ops_sec_comp(:, 3);
                                b = num2str(a);
                                c = cellstr(b);
                                dx=0.5;
                                dy=20;
                                text(X, ops_sec_comp(:, 3)+dy, c, 'FontSize', 10); %for opts Fuse-Ext4

                                axis([0 size(ops_sec_comp)(1)+1 0 max(max(log(ops_sec_comp)))*1.5]);
                                set(gca, 'XTick', 1:4, 'XTickLabel', io_sizes);
                                xlabel('Different I/O sizes', 'fontsize', 15);
                                h_leg = legend('Ext4', 'Fuse Ext4', 'Opts Fuse Ext4');
                                set(h_leg, 'fontsize', 10);
                                if (strcmp(work_load_op, 're'))
                                        ylabel('Read Operations (in absolute #)', 'fontsize', 15);
                                elseif(strcmp(work_load_op, 'wr'))
                                        ylabel('Write Operations (in absolute #)', 'fontsize', 15);
                                endif
                                title(sprintf('%s %s %d %s', work_load_type, work_load_op, thread, file), 'fontsize', 15);
                                hold off;
%                                outfilename = strcat(outputDir, sprintf('/OpsPerSec/%s/OpsPerSec-comp-%s-%s-%dth-%s.png', type, work_load_type, work_load_op, thread, file));
%                                print(outfilename, "-dpng");
%                                close();

				%%%%Please remove this SD's should be in above graph itself.%%%%
				figure;
				clf;
				hold on;
				h = bar(throughput_comp_std);

				a = throughput_comp_std(:, 1);
                                b = num2str(a);
                                c = cellstr(b);
                                dx=0.5;
                                dy=2;
                                text(X-dx, throughput_comp_std(:, 1)+dy, c, 'FontSize', 10);

				a = throughput_comp_std(:, 2);
                                b = num2str(a);
                                c = cellstr(b);
                                dx=0.5;
                                dy=2;
                                text(X, throughput_comp_std(:, 2)+dy, c, 'FontSize', 10);
				if (max(max(throughput_comp_std)) == 0)
					axis([0 size(throughput_comp_std)(1)+1 0 2]);
				else
                                	axis([0 size(throughput_comp_std)(1)+1 0 max(max(throughput_comp_std))*1.5]);
				endif
				set(gca, 'XTick', 1:4, 'XTickLabel', io_sizes);
				xlabel('Different I/O sizes', 'fontsize', 15);
				h_leg = legend('Ext4 Std', 'Fuse Ext4 Std');
				set(h_leg, 'fontsize', 10);
                                if (strcmp(work_load_op, 're'))
                                        ylabel('Read ThroughPut std deviation', 'fontsize', 15);
                                elseif(strcmp(work_load_op, 'wr'))
                                        ylabel('Write ThroughPut std deviation', 'fontsize', 15);
                                endif
				title(sprintf('%s %s %d %s std deviation', work_load_type, work_load_op, thread, file), 'fontsize', 15);
                                hold off;
                                outfilename = strcat(outputDir, sprintf('/ThroughPut-comp-%s-%s-%dth-%s-std-dev.png', work_load_type, work_load_op, thread, file));
                                print(outfilename, "-dpng");
                                close();
%}
				%%%%Please remove this SD's should be in above graph itself.%%%%
%{
                                figure;
                                clf;
                                hold on;
                                h = bar(ops_sec_comp_std);

                                a = ops_sec_comp_std(:, 1);
                                b = num2str(a);
                                c = cellstr(b);
                                dx=0.5;
                                dy=2;
                                text(X-dx, ops_sec_comp_std(:, 1)+dy, c, 'FontSize', 10);

                                a = ops_sec_comp_std(:, 2);
                                b = num2str(a);
                                c = cellstr(b);
                                dx=0.5;
                                dy=2;
                                text(X, ops_sec_comp_std(:, 2)+dy, c, 'FontSize', 10);
                                axis([0 size(ops_sec_comp_std)(1)+1 0 max(max(ops_sec_comp_std))*1.5]);
                                set(gca, 'XTick', 1:4, 'XTickLabel', io_sizes);
                                xlabel('Different I/O sizes', 'fontsize', 15);
                                h_leg = legend('Ext4 Ops Std', 'Fuse Ext4 Ops Std');
                                set(h_leg, 'fontsize', 10);
                                if (strcmp(work_load_op, 're'))
                                        ylabel('Read Ops/sec std deviation', 'fontsize', 15);
                                elseif(strcmp(work_load_op, 'wr'))
                                        ylabel('Write Ops/sec std deviation', 'fontsize', 15);
                                endif
                                title(sprintf('%s %s %d %s Ops/sec std deviation', work_load_type, work_load_op, thread, file), 'fontsize', 15);
                                hold off;
                                outfilename = strcat(outputDir, sprintf('/Ops-sec-comp-%s-%s-%dth-%s-std-dev.png', work_load_type, work_load_op, thread, file));
                                print(outfilename, "-dpng");
                                close();
%}
%				throughput_comp
			end
		end
	end
end
end
