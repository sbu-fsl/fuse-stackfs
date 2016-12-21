function plot_cpu_utilisation_comparision1()
%{
What does this plot do ?
1. Read cpu numbers that were obtained from filebench results,
2. Compare them with Ext4, Fuse-Ext4 results,
3. Standard deviation numbers but just to check (will remove)
%}


commdir1 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/';
commdir2 = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/';
outputDir = '/Users/Bharath/Downloads/FUSE/fuse-playground/kernel-statistics/plots/';

Types{1} = 'HDD';
Types{2} = 'SSD';

work_load_types{1} = 'cr';
work_load_types{2} = 'preall';

work_load_ops{1} = 'wr';
work_load_ops{2} = 're';
work_load_ops{3} = 'de';

io_sizes{1} = '4KB';
io_sizes{2} = '32KB';
io_sizes{3} = '128KB';
io_sizes{4} = '1MB';

threads{1} = 1;
threads{2} = 32;
%threads = [1];
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
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if (eq(strcmp(work_load_type, 'cr'), 1))
		work_load_ops = [];
		work_load_ops{1} = 'wr';
		io_sizes = [];
		io_sizes{1} = '4KB';
		files{1} = '4M';
	elseif (eq(strcmp(work_load_type, 'preall'), 1))
		work_load_ops = [];
		work_load_ops{1} = 're';
		work_load_ops{2} = 'de';
		io_sizes = [];
		io_sizes{1} = '4KB';
	endif

	for j=1:size(work_load_ops)(2)
		work_load_op=work_load_ops{j};
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%
		cpu_util_comp = [];
		cpu_util_comp_std = [];
		cpu_idle_comp = [];
		cpu_idle_comp_std = [];
		cpu_usr_sys_secs = [];
		
		for k=1:size(threads)(2)
			thread=threads{k};
			%%%%%%%%%%%%%%%%%%%%
			if ( eq(strcmp(work_load_type, 'cr'), 1) )
				files{1} = '4Mf';
				io_sizes{1} = '4KB';
			elseif ( eq(strcmp(work_load_type, 'preall'), 1) && eq(strcmp(work_load_op, 're'), 1) )
				files{1} = '1Mf';
			elseif ( eq(strcmp(work_load_type, 'preall'), 1) && eq(strcmp(work_load_op, 'de'), 1) )
				if (eq(strcmp(type, 'HDD'), 1))
					files{1} = '2Mf';
				else
					files{1} = '4Mf';	
				endif
			endif
			for l=1:size(files)(2)
				file=files{l};
				
				for m=1:size(io_sizes)(2)
					io_size=io_sizes{m};
					%%%%%%%%%%%%%%%%%%%
					avg_ext4_cpu_util = [];
					avg_fuse_ext4_cpu_util = [];
					avg_ext4_cpu_idle = [];
					avg_fuse_ext4_cpu_idle = [];
					avg_ext4_usr_sys_secs = [];
                                        avg_fuse_ext4_usr_sys_secs = [];
					avg_fuse_opts_ext4_usr_sys_secs = [];
					for n=1:iterations
						count=n;
						%Stat-files-sq-wr-4KB-1th-1f-1
						inputDir1 = strcat(dir1, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, count));
						inputDir2 = strcat(dir2, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, count));
						inputDir3 = strcat(dir3, sprintf('/Stat-files-%s-%s-%s-%dth-%s-%d/', work_load_type, work_load_op, io_size, thread, file, count));	
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
				end
			end
			cpu_util_comp = [ cpu_util_comp; mean(avg_ext4_cpu_util(:, 1)) mean(avg_ext4_cpu_util(:, 2)) mean(avg_fuse_ext4_cpu_util(:, 1))  mean(avg_fuse_ext4_cpu_util(:, 2)) ];
			cpu_util_comp_std = [ cpu_util_comp_std; std(avg_ext4_cpu_util(:, 1)) std(avg_ext4_cpu_util(:, 2))  std(avg_fuse_ext4_cpu_util(:, 1)) std(avg_fuse_ext4_cpu_util(:, 2)) ];
			cpu_idle_comp = [cpu_idle_comp ; mean(avg_ext4_cpu_idle(:,1)) mean(avg_ext4_cpu_idle(:,2))  mean(avg_fuse_ext4_cpu_idle(:, 1)) mean(avg_fuse_ext4_cpu_idle(:, 2)) ];
			cpu_idle_comp_std = [cpu_idle_comp_std ; std(avg_ext4_cpu_idle(:,1)) std(avg_ext4_cpu_idle(:,2)) std(avg_fuse_ext4_cpu_idle(:, 1)) std(avg_fuse_ext4_cpu_idle(:, 2))];
			A = mean(avg_ext4_usr_sys_secs(:, 1)); %ext4_usr
                        B = mean(avg_ext4_usr_sys_secs(:, 2)); %ext4_sys
                        C = mean(avg_fuse_ext4_usr_sys_secs(:, 1)); %fuse_ext4_usr
                        D = mean(avg_fuse_ext4_usr_sys_secs(:, 2)); %fuse_ext4_sys
                        E = mean(avg_fuse_opts_ext4_usr_sys_secs(:, 1)); %fuse_opts_ext4_usr
                        F = mean(avg_fuse_opts_ext4_usr_sys_secs(:, 2)); %fuse_opts_ext4_sys

                        cpu_usr_sys_secs = [cpu_usr_sys_secs; A B C D E F C/A D/B E/A F/B];
		end
		%%%%%%%%%Figures com here%%%%%%%%%%
		work_load_type
                work_load_op
                thread
                file
                cpu_usr_sys_secs

		%cpu_util_comp
		%cpu_util_comp_std
		%cpu_idle_comp
		%cpu_idle_comp_std
		%create a 3-D matrix (  1 : user, user of Ext4 and Fuse-Ext4; 
		%			2 : system, system of Ext4 and Fuse-Ext4 )
%{
		plot_cpu_util(:, :, 1) = [ cpu_util_comp(:, 1) cpu_util_comp(:, 3) ];
		plot_cpu_util(:, :, 2) = [ cpu_util_comp(:, 2) cpu_util_comp(:, 4) ];

		plot_cpu_idle(:, :, 1) = [ cpu_idle_comp(:, 1) cpu_idle_comp(:, 3) ];
		plot_cpu_idle(:, :, 2) = [ cpu_idle_comp(:, 2) cpu_idle_comp(:, 4) ];
		
		%plot_cpu_util
		%plot_cpu_idle

		%Cpu utilisation graphs
		NumGroupsPerAxis = size(plot_cpu_util, 1); %1th, 32th
		NumStacksPerGroup =  2; %user cpu, system cpu or cpu idle, cpu iowait
		groupBins = 1:NumGroupsPerAxis;
		MaxGroupWidth = 0.65; % Fraction of 1. If 1, then we have all bars in groups touching
		groupOffset = MaxGroupWidth/NumStacksPerGroup;
		figure;
		hold on;
		for i=1:NumStacksPerGroup
			Y = squeeze(plot_cpu_util(:,i,:));
			% Center the bars:
			internalPosCount = i - ((NumStacksPerGroup+1) / 2);
			% Offset the group draw positions:
			groupDrawPos = (internalPosCount)* groupOffset + groupBins;
			h(i,:) = bar(Y, 'stacked');
			set(h(i,1),'facecolor','g','edgecolor','k');
			set(h(i,2),'facecolor','r','edgecolor','k');
			set(h(i,:),'BarWidth',groupOffset);
			set(h(i,:),'XData',groupDrawPos);
		end
		axis([0 size(plot_cpu_util)(1)+1 0 (max(max(plot_cpu_util))(1) + max(max(plot_cpu_util))(2))*1.5]);
		h_leg = legend('User CPU Utilization', 'System CPU Utilization');
		set(h_leg, 'fontsize', 10);
		set(gca,'XTickMode', 'manual');
		set(gca,'XTick', 1:NumGroupsPerAxis);
		set(gca,'XTickLabelMode', 'manual');
		plot_threads{1} = '1th';
		plot_threads{2} = '32th';
		set(gca,'XTickLabel', plot_threads);
		xlabel('Different Threads invoked', 'fontsize', 15);
		ylabel('CPU Utilization(User + System) (in %)', 'fontsize', 15);
		title(sprintf('%s %s %d %s %s', work_load_type, work_load_op, thread, file, io_sizes{1}), 'fontsize', 15);
                hold off;
		outfilename = strcat(outputDir, sprintf('/Cpu-util/%s/Cpu-util-comp-%s-%s-%s.png', type, work_load_type, work_load_op, file));
		print(outfilename, "-dpng");
		close();
		
		%Cpu idle comparisions graphs
		NumGroupsPerAxis = size(plot_cpu_idle, 1); %1th, 32th
		NumStacksPerGroup =  2; %user cpu, system cpu or cpu idle, cpu iowait
		groupBins = 1:NumGroupsPerAxis;
		MaxGroupWidth = 0.65; % Fraction of 1. If 1, then we have all bars in groups touching
		groupOffset = MaxGroupWidth/NumStacksPerGroup;
		figure;
		hold on;
		for i=1:NumStacksPerGroup
			Y = squeeze(plot_cpu_idle(:,i,:));
			% Center the bars:
			internalPosCount = i - ((NumStacksPerGroup+1) / 2);
			% Offset the group draw positions:
			groupDrawPos = (internalPosCount)* groupOffset + groupBins;
			h(i,:) = bar(Y, 'stacked');
			set(h(i,1),'facecolor','g','edgecolor','k');
			set(h(i,2),'facecolor','r','edgecolor','k');
			set(h(i,:),'BarWidth',groupOffset);
			set(h(i,:),'XData',groupDrawPos);
		end
		axis([0 size(plot_cpu_idle)(1)+1 0 (max(max(plot_cpu_idle))(1) + max(max(plot_cpu_idle))(2))*1.5]);
		h_leg = legend('CPU Idle', 'CPU I/O Wait');
		set(h_leg, 'fontsize', 10);
		set(gca,'XTickMode', 'manual');
		set(gca,'XTick', 1:NumGroupsPerAxis);
		set(gca,'XTickLabelMode', 'manual');
		plot_threads{1} = '1th';
		plot_threads{2} = '32th';
		set(gca,'XTickLabel', plot_threads);
		xlabel('Different Threads invoked', 'fontsize', 15);
		ylabel('CPU (Idle + I/O Wait) (in %)', 'fontsize', 15);
		title(sprintf('%s %s %d %s %s', work_load_type, work_load_op, thread, file, io_sizes{1}), 'fontsize', 15);
                hold off;
		outfilename = strcat(outputDir, sprintf('/Cpu-idle/%s/Cpu-idle-comp-%s-%s-%s.png', type, work_load_type, work_load_op, file));
		print(outfilename, "-dpng");
		close();
%}
	end
end
end
