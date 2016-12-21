function plot_opts_requests_sq_wr_1th_1f()

commdir1 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/';
outputDir = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/plots/';

Types{1} = 'HDD';
Types{2} = 'SSD';

work_load_types{1} = 'sq';

work_load_ops{1} = 'wr';

io_sizes{1} = '4KB';
io_sizes{2} = '32KB';
io_sizes{3} = '128KB';
io_sizes{4} = '1MB';

threads = [1];
iterations = 3;
files{1} = '1f';

req_iterations = [15728640; 1966080; 491520; 61440];
req_iterations = [ req_iterations  req_iterations ];

req_count = [];
X = [1; 2; 3; 4];
dir1=strcat(commdir1, sprintf('%s-FUSE-OPTS-EXT4-Results', Types{1}));
dir2=strcat(commdir1, sprintf('%s-FUSE-OPTS-EXT4-Results', Types{2}));

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
                                write_reqs = [];
                                for m=1:size(io_sizes)(2)
                                        io_size=io_sizes{m};
                                        %%%%%%%%%%%%%%%%%%%
					avg_hdd_write_reqs = [];
					avg_ssd_write_reqs = [];
                                        for n=1:iterations
                                                count=n;
                                                %Stat-files-sq-wr-4KB-1th-1f-1
						inputDir1 = strcat(dir1, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, count));
                                                inputDir2 = strcat(dir2, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, count));

						filename1 = strcat(inputDir1, 'FUSE_WRITE_processing_distribution.txt');
                                                filename2 = strcat(inputDir2, 'FUSE_WRITE_processing_distribution.txt');

						hdd_write_reqs = load(filename1);
						ssd_write_reqs = load(filename2);
						
						avg_hdd_write_reqs = [avg_hdd_write_reqs; hdd_write_reqs(size(hdd_write_reqs)(1)) ];
						avg_ssd_write_reqs = [avg_ssd_write_reqs; ssd_write_reqs(size(ssd_write_reqs)(1)) ];
						
					end
					write_reqs = [write_reqs; round(mean(avg_hdd_write_reqs)) round(mean(avg_ssd_write_reqs)) ];
				end
				work_load_type
				work_load_op
				file
				thread
				write_reqs
				
				max_val = [15728640; 15728640; 15728640; 15728640; 15728640; 15728640];
				%%%%Absolute number of requests%%%%%

				figure;
                                clf;
                                hold on;
				h = bar(write_reqs);

				a = fix((write_reqs(:, 1))/1000);
                                b = num2str(a);
                                c = strcat(cellstr(b), 'K');
                                dx=0.5;
                                text(X-dx, write_reqs(:, 1)+15000, c, 'FontSize', 15);


				a = fix((write_reqs(:, 2))/1000);
                                b = num2str(a);
                                c = strcat(cellstr(b), 'K');
                                text(X, write_reqs(:, 2)+15000, c, 'FontSize', 15);

                                set(h(1), 'facecolor', 'b');
                                set(h(2), 'facecolor', 'g');
				axis([0 size(write_reqs)(1)+1 0 (max(max(write_reqs)))*1.2]);

				set(gca, 'XTick', 1:4, 'XTickLabel', io_sizes);
				xlabel('Different I/O sizes', 'fontsize', 20);
				ylabel('Opts Fuse Write Requests', 'fontsize', 20);

                                h_leg = legend('HDD', 'SSD');
                                set(h_leg, 'fontsize', 20);

				title(sprintf('%s %s %d %s Write operations', work_load_type, work_load_op, thread, file), 'fontsize', 15);
                                hold off;
				outfilename = strcat(outputDir, sprintf('/Requests/Write-opts-reqs-comp-%s-%s-%dth-%s.png',  work_load_type, work_load_op, thread, file));
                                print(outfilename, "-dpng");
                                close();
%{
				%%%%%%Normalise the requests%%%%%%%%%%%
				figure;
				clf;
				hold on;
				normalise_vals = round((read_reqs./req_iterations)*100);
				h = bar(normalise_vals);
				
				text_norm_vals = ['3%'; '25%'; '100%'; '800%'];
				a = text_norm_vals;
                                b = num2str(a);
                                c = cellstr(b)
%                                dx=0.05;
%                                dy=0.1;
%                                text(X, normalise_vals(:, 1)+dy, c, 'FontSize', 20);
				text(X-0.4, normalise_vals(:, 1)+30, c, 'FontSize', 20); %% for HDD
				text(X+0.1, normalise_vals(:, 2)+30, c, 'FontSize', 20);	%% for SSD
%				a = normalise_vals(:, 2);
%                               b = num2str(a);
%                               c = cellstr(b);
%                               dx=0.05;
%                               dy=0.1;
%                               text(X+dx, normalise_vals(:, 1)+dy, c, 'FontSize', 20);
				
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
				outfilename = strcat(outputDir, sprintf('/Requests/Read-reqs-comp-%s-%s-%dth-%s-in-perc.png',  work_load_type, work_load_op, thread, file));
				print(outfilename, "-dpng");
                                close();
%}
			end

		end
	end
end
