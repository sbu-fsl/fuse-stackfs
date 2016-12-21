function plot_cpu_utilisation_comparision2()

commdir1 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/';
commdir2 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/';
outputDir = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/plots/';

Types{1} = 'HDD';
Types{2} = 'SSD';

work_load_types{1}='Web-server-100th';
work_load_types{2}='Mail-server-16th';
work_load_types{3}='File-server-50th';

iterations = 3;


for t=1:size(Types)(2)
        type=Types{t};
        dir1=strcat(commdir1, sprintf('%s-EXT4-Results', type));
        dir2=strcat(commdir2, sprintf('%s-FUSE-EXT4-Results', type));
	dir3=strcat(commdir2, sprintf('%s-FUSE-OPTS-EXT4-Results', type));

	cpu_util_comp = [];
        cpu_idle_comp = [];
        cpu_usr_sys_secs = [];

        for i=1:size(work_load_types)(2)
                work_load_type=work_load_types{i};
		avg_ext4_cpu_util = [];
                avg_fuse_ext4_cpu_util = [];
                avg_ext4_cpu_idle = [];
                avg_fuse_ext4_cpu_idle = [];
                avg_ext4_usr_sys_secs = [];
                avg_fuse_ext4_usr_sys_secs = [];
		avg_fuse_opts_ext4_usr_sys_secs = [];
		
                for n=1:iterations
			%Stat-files-sq-wr-4KB-1th-1f-1
			count = n;
                        inputDir1 = strcat(dir1, sprintf('/Stat-files-%s-%d/', work_load_type, count));
                        inputDir2 = strcat(dir2, sprintf('/Stat-files-%s-%d/', work_load_type, count));
                        inputDir3 = strcat(dir3, sprintf('/Stat-files-%s-%d/', work_load_type, count));

                        filename1 = strcat(inputDir1, 'cpu_utilisation.txt');
                        filename2 = strcat(inputDir2, 'cpu_utilisation.txt');
                        ext4_cpu_util = load(filename1);
                                                fuse_ext4_cpu_util = load(filename2);
                                                %% user : system
                                                avg_ext4_cpu_util = [avg_ext4_cpu_util ; mean(ext4_cpu_util(:, 2)) mean(ext4_cpu_util(:, 4)) ];
                                                avg_fuse_ext4_cpu_util = [avg_fuse_ext4_cpu_util ; mean(fuse_ext4_cpu_util(:, 2)) mean(fuse_ext4_cpu_util(:, 4))];

                                                filename1 = strcat(inputDir1, 'cpu_idle.txt');
                                                filename2 = strcat(inputDir2, 'cpu_idle.txt');
                                                ext4_idle = load(filename1);
                                                fuse_ext4_idle = load(filename2);
                                                %% idle : iowait
                                                avg_ext4_cpu_idle = [avg_ext4_cpu_idle ; mean(ext4_idle(:, 2)) mean(ext4_idle(:, 3)) ];
                                                avg_fuse_ext4_cpu_idle = [avg_fuse_ext4_cpu_idle ; mean(fuse_ext4_idle(:, 2)) mean(fuse_ext4_idle(:, 3)) ];

                                                filename1 = strcat(inputDir1, 'cpu_user_system_secs.txt');
                                                filename2 = strcat(inputDir2, 'cpu_user_system_secs.txt');
                                                filename3 = strcat(inputDir3, 'cpu_user_system_secs.txt');
						
                                                ext4_usr_sys_secs = load(filename1);
                                                fuse_ext4_usr_sys_secs = load(filename2);
                                                fuse_opts_ext4_usr_sys_secs = load(filename3);

                                                avg_ext4_usr_sys_secs = [avg_ext4_usr_sys_secs ; sum(ext4_usr_sys_secs(:, 1)) sum(ext4_usr_sys_secs(:, 2))];
                                                avg_fuse_ext4_usr_sys_secs = [avg_fuse_ext4_usr_sys_secs ; sum(fuse_ext4_usr_sys_secs(:, 1)) sum(fuse_ext4_usr_sys_secs(:, 2))];
						avg_fuse_opts_ext4_usr_sys_secs = [avg_fuse_opts_ext4_usr_sys_secs ; sum(fuse_opts_ext4_usr_sys_secs(:, 1)) sum(fuse_opts_ext4_usr_sys_secs(:, 2)) ];
                end
		cpu_util_comp = [ cpu_util_comp; mean(avg_ext4_cpu_util(:, 1)) mean(avg_ext4_cpu_util(:, 2)) mean(avg_fuse_ext4_cpu_util(:, 1))  mean(avg_fuse_ext4_cpu_util(:, 2)) ];
                cpu_idle_comp = [cpu_idle_comp ; mean(avg_ext4_cpu_idle(:,1)) mean(avg_ext4_cpu_idle(:,2))  mean(avg_fuse_ext4_cpu_idle(:, 1)) mean(avg_fuse_ext4_cpu_idle(:, 2)) ];
                        A = mean(avg_ext4_usr_sys_secs(:, 1)); %ext4_usr
                        B = mean(avg_ext4_usr_sys_secs(:, 2)); %ext4_sys
                        C = mean(avg_fuse_ext4_usr_sys_secs(:, 1)); %fuse_ext4_usr
                        D = mean(avg_fuse_ext4_usr_sys_secs(:, 2)); %fuse_ext4_sys
			E = mean(avg_fuse_opts_ext4_usr_sys_secs(:, 1)); %fuse_opts_ext4_usr
			F = mean(avg_fuse_opts_ext4_usr_sys_secs(:, 2)); %fuse_opts_ext4_sys

                        cpu_usr_sys_secs = [cpu_usr_sys_secs; A B C D E F C/A D/B E/A F/B];

        end
%       throughput_comp
	work_load_type
	cpu_usr_sys_secs
end
