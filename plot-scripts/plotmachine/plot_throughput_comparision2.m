function plot_throughput_comparision2()

commdir1 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/';
commdir2 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/';
outputDir = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/plots/';

%Types{1} = 'HDD';
Types{1} = 'SSD';

work_load_types{1}='Web-server-100th';
work_load_types{2}='Mail-server-16th';
work_load_types{3}='File-server-50th';

iterations = 3;

for t=1:size(Types)(2)
	type=Types{t};
	dir1=strcat(commdir1, sprintf('%s-EXT4-Results', type));
	dir2=strcat(commdir2, sprintf('%s-FUSE-EXT4-Results', type));
	dir3=strcat(commdir1, sprintf('%s-FUSE-OPTS-EXT4-Results', type));

	throughput_comp = [];
	ops_sec_comp = [];
	ops_sec_comp_std = [];

	for i=1:size(work_load_types)(2)
		work_load_type=work_load_types{i};
		avg_ext4_throughput = [];
		avg_fuse_ext4_throughput = [];
		avg_fuse_opts_ext4_throughput = [];

		avg_ext4_ops_sec = [];
		avg_fuse_ext4_ops_sec = [];
		avg_fuse_opts_ext4_ops_sec = [];
		for n=1:iterations
			count=n;
			inputDir1 = strcat(dir1, sprintf('/Stat-files-%s-%d/', work_load_type, count));
			inputDir2 = strcat(dir2, sprintf('/Stat-files-%s-%d/', work_load_type, count));
			inputDir3 = strcat(dir3, sprintf('/Stat-files-%s-%d/', work_load_type, count));	

			filename1 = strcat(inputDir1, 'throughput.txt');
			filename2 = strcat(inputDir2, 'throughput.txt');
			filename3 = strcat(inputDir3, 'throughput.txt');

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
		throughput_comp = [throughput_comp; mean(avg_ext4_throughput) mean(avg_fuse_ext4_throughput) ];

		A = mean(avg_ext4_ops_sec);
		B = mean(avg_fuse_ext4_ops_sec);
		C = mean(avg_fuse_opts_ext4_ops_sec);

		std_A = std(avg_ext4_ops_sec);
		std_B = std(avg_fuse_ext4_ops_sec);
		std_C = std(avg_fuse_opts_ext4_ops_sec);

		ops_sec_comp = [ops_sec_comp ; A  B C ((A - B)/A)*100 ((A - C)/A)*100];
		ops_sec_comp_std = [ops_sec_comp_std; (std_A/A)*100 (std_B/B)*100 (std_C/C)*100];
	end
%	throughput_comp
	ops_sec_comp_std
end
