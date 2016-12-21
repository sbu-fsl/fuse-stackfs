function plot_requests_sq_re_32th_1f()

commdir1 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/';
outputDir = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/plots/';

Types{1} = 'HDD';
Types{2} = 'SSD';

work_load_types{1} = 'sq';
work_load_ops{1} = 're';

io_sizes{1} = '4KB';
io_sizes{2} = '32KB';
io_sizes{3} = '128KB';
io_sizes{4} = '1MB';

threads = [32];
iterations = 3;
files{1} = '1f';

req_iterations_hdd = [491520; 61440; 15360; 1920];
req_iterations_ssd = [491520; 61440; 15360; 1920];

req_iterations = [ req_iterations_hdd*32  req_iterations_ssd*32 ];

req_count = [];
X = [1; 2; 3; 4];
dir1=strcat(commdir1, sprintf('%s-FUSE-EXT4-Results', Types{1}));
dir2=strcat(commdir1, sprintf('%s-FUSE-EXT4-Results', Types{2}));

for i=1:size(work_load_types)(2)
        work_load_type=work_load_types{i};

        for j=1:size(work_load_ops)(2)
                work_load_op=work_load_ops{j};
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for k=1:size(threads)(1)
                        thread=threads(k);
                        %%%%%%%%%%%%%%%%%%%%
			for l=1:size(files)(2)
                                file=files{l};
                                %%%%%%%%%%%%%%
                                read_reqs = [];
                                for m=1:size(io_sizes)(2)
                                        io_size=io_sizes{m};
                                        %%%%%%%%%%%%%%%%%%%
					avg_hdd_read_reqs = [];
					avg_ssd_read_reqs = [];
                                        for n=1:iterations
                                                count=n;
                                                %Stat-files-sq-wr-4KB-1th-1f-1
						inputDir1 = strcat(dir1, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, count));
                                                inputDir2 = strcat(dir2, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, count));

						filename1 = strcat(inputDir1, 'FUSE_READ_processing_distribution.txt');
                                                filename2 = strcat(inputDir2, 'FUSE_READ_processing_distribution.txt');

						hdd_read_reqs = load(filename1);
						ssd_read_reqs = load(filename2);
						
						avg_hdd_read_reqs = [avg_hdd_read_reqs; hdd_read_reqs(size(hdd_read_reqs)(1)) ];
						avg_ssd_read_reqs = [avg_ssd_read_reqs; ssd_read_reqs(size(ssd_read_reqs)(1)) ];
						
					end
					read_reqs = [read_reqs; round(mean(avg_hdd_read_reqs)) round(mean(avg_ssd_read_reqs)) ];
				end
				work_load_type
				work_load_op
				file
				thread
				read_reqs

				% The no. of requests that will cross kernel->user boundary when 4KB of requests are transferred
				max_val = [15728640; 15728640; 15728640; 15728640; 15728640; 15728640];
				%%%%Absolute number of requests%%%%%

				figure;
                                clf;
                                hold on;
				
%				h = bar(log(read_reqs));
				h = bar(read_reqs);

				a = round(read_reqs(:, 1)/1000);
                                b = num2str(a);
                                c = strcat(cellstr(b), 'K');
                                dx=0.5;
                                dy=0.5;
%                                text(X-dx, log(read_reqs(:, 1))+dy, c, 'FontSize', 20);
                                text(X-dx, read_reqs(:, 1)+14000, c, 'FontSize', 20);

				a = round(read_reqs(:, 2)/1000);
                                b = num2str(a);
                                c = strcat(cellstr(b), 'K');
%                                text(X-dx, log(read_reqs(:, 1))+dy, c, 'FontSize', 20);
                                text(X, read_reqs(:, 2)+14000, c, 'FontSize', 20);

                                set(h(1), 'facecolor', 'b');
                                set(h(2), 'facecolor', 'g');
				axis([0 size(read_reqs)(1)+1 0 (max(max(read_reqs)))*1.2]);
				set(gca, 'XTick', 1:4, 'XTickLabel', io_sizes);
				xlabel('Different I/O sizes', 'fontsize', 20);
				ylabel('Fuse Read Requests (in absolute nos)', 'fontsize', 20);
                                h_leg = legend('HDD', 'SSD');
                                set(h_leg, 'fontsize', 20);

%				plot(0:5, log(max_val), 'r--', "linewidth", 10);
%				b = num2str(max_val(1));
%                                c = cellstr(b);
%				text(1, log(max_val(1)) + 0.5, '15,728,640', 'FontSize', 20);

				title(sprintf('%s %s %dth %s Read operations', work_load_type, work_load_op, thread, file), 'fontsize', 15);
                                hold off;
				outfilename = strcat(outputDir, sprintf('/Requests/Read-reqs-comp-%s-%s-%dth-%s.png',  work_load_type, work_load_op, thread, file));
                                print(outfilename, "-dpng");
                                close();
%{
				figure;
                                clf;
                                hold on;
                                normalise_vals = round((read_reqs./req_iterations)*100)
                                h = bar(normalise_vals);

                                text_norm_vals = ['3%'; '25%'; '100%'; '800%'];

                                a = text_norm_vals;
                                b = num2str(a);
                                c = cellstr(b);
                                text(X-0.4, normalise_vals(:, 1)+30, c, 'FontSize', 20); 	%% for HDD
                                text(X+0.1, normalise_vals(:, 2)+30, c, 'FontSize', 20);        %% for SSD

                                set(h(1), 'facecolor', 'b');
                                set(h(2), 'facecolor', 'g');
                                axis([0 size(normalise_vals)(1)+1 0 max(max(normalise_vals))*1.2]);
                                set(gca, 'XTick', 1:4, 'XTickLabel', io_sizes);
                                xlabel('Different I/O sizes', 'fontsize', 20);
                                ylabel('Fuse requests exchanged (%)', 'fontsize', 20);
                                title(sprintf('%s %s %d %s Read operations', work_load_type, work_load_op, thread, file), 'fontsize', 15);
                                h_leg = legend('HDD', 'SSD');
                                set(h_leg, 'fontsize', 20);
                                hold off;
				outfilename = strcat(outputDir, sprintf('/Requests/Read-reqs-comp-%s-%s-%dth-%s-perc.png',  work_load_type, work_load_op, thread, file));
                                print(outfilename, "-dpng");
                                close();
%}
			end

		end
	end
end
