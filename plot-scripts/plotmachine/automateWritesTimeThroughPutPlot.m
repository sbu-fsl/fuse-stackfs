function automateWritesTimeThroughPutPlot()

max_writes = [32768;65536;131072;262144;524288;1048576;2097152;4194304;8388608;16777216;33554432;67108864];
iterations = 61440;

dir1 = '/Users/Bharath/Downloads/FUSE/raw_data/Results/Stat-files-writebackcache-HotStorage/'; %Writebackcache Results
dir2 = '/Users/Bharath/Downloads/FUSE/raw_data/Results/Stat-files-bigwrites-HotStorage/'; %Big writes Results
dir3 = '/Users/Bharath/Downloads/FUSE/raw_data/Results/Stat-files-defaultfuse-HotStorage/'; %Default Fuse Results
dir4 = '/Users/Bharath/Downloads/FUSE/raw_data/Results/Stat-files-nofuse-HotStorage/'; %No Fuse Results
outputDir = '/Users/Bharath/Downloads/FUSE/plots/Plots-HotStorage/';

details{1} = 'Experiment type : Sequential Write of 60 GB (Hot Storage)';
details{2} = 'Write Back Cache : Yes';
details{3} = 'Max Write : On X-Axis (in pages)';
details{4} = 'Iterations : 61440 of 1 MB I/O (Hot Storage)';
details{5} = 'Big Writes : Yes';
details{6} = 'Max Bg Length : 12 (default)';
details{7} = 'Congestion Threshold : 9 (default)';
details{8} = 'Ram Size : 4 GB (Hot Storage)';

Total_iters = 10;

%writeback
%Time
AvgTime_wbck = [];
TotalTime_wbck = [];
MaxTime_wbck = [];
MinTime_wbck = [];
TimeSD_wbck = [];
%Throughput
AvgThroughPut_wbck = [];
TotalThroughPut_wbck = [];
MaxThroughPut_wbck = [];
MinThroughPut_wbck = [];
ThroughPutSD_wbck = [];
%FUSE write reqs
AvgWriteReqs_wbck = [];
TotalWriteReqs_wbck = [];
WriteReqsSD_wbck = [];
max_write_pages = [];
%cpuStats
AvgUsercpu_wbck = [];
AvgSystemcpu_wbck = [];
AvgIOwaitcpu_wbck = [];
AvgIdlecpu_wbck = [];
%memStats
AvgMemutil_wbck = [];
AvgDirtydata_wbck = [];
AvgCntxtSwtchs_wbck = [];
%diskstats
AvgWritereqs_wbck = [];
AvgKBWritten_wbck = [];
AvgWwait_wbck = [];
AvgDiskutil_wbck = [];

for i=1:size(max_writes)(1)
	for j=iterations:iterations
		%time
		time = [];
		timeSD = 0;
		%throughput
		throughput = [];
		throughputSD = 0;
		%writereqs
		writereqs = [];
		writereqsSD = 0;
		%cpu
		usercpu = [];
		systemcpu = [];
		iowaitcpu = [];
		idlecpu = [];
		%mem
		memutil = [];
		dirtydata = [];
		cntxtswtchs = [];
		%disk
		writereqs = [];
		kbwritten = [];
		wwait = [];
		diskutil = [];
		for count=1:Total_iters
			max_write = max_writes(i);
			iteration = iterations;
			filename = strcat(dir1, sprintf('Stat-files-%d-%d-Final-%d/time.txt', max_write, iteration, count));
			temp_time = load(filename);
			filename = strcat(dir1, sprintf('Stat-files-%d-%d-Final-%d/throughput.txt', max_write, iteration, count));
			temp_throughput = load(filename);
			filename = strcat(dir1, sprintf('Stat-files-%d-%d-Final-%d/FUSE_WRITE_user_processing_distribution.txt', max_write, iteration, count));
			temp_writereqs = load(filename);
			filename = strcat(dir1, sprintf('Stat-files-%d-%d-Final-%d/AvgCpuStats.txt', max_write, iteration, count));
			temp_cpu = load(filename);
			filename = strcat(dir1, sprintf('Stat-files-%d-%d-Final-%d/AvgMemStats.txt', max_write, iteration, count));
                        temp_mem = load(filename);
			filename = strcat(dir1, sprintf('Stat-files-%d-%d-Final-%d/AvgDiskStats.txt', max_write, iteration, count));
                        temp_disk = load(filename);
			%disk
			writereqs = [writereqs; temp_disk(1)];
			kbwritten = [kbwritten; temp_disk(2)];
			wwait = [wwait; temp_disk(3)];
			diskutil = [diskutil; temp_disk(4)];
			%mem
			memutil = [memutil; temp_mem(1)];
			dirtydata = [dirtydata; temp_mem(2)];
			cntxtswtchs = [cntxtswtchs; temp_mem(3)];
			%cpu
			usercpu = [usercpu; temp_cpu(1)];
			systemcpu = [systemcpu; temp_cpu(2)];
			iowaitcpu = [iowaitcpu; temp_cpu(3)];
			idlecpu = [idlecpu; temp_cpu(4)];
			%write reqs
			temp_writereqs = temp_writereqs(size(temp_writereqs)(1));
			writereqs = [writereqs ; temp_writereqs];
			%time
			time = [time ; temp_time];
			%throughput
			throughput = [throughput ; temp_throughput];
		end
		max_write_pages = [max_write_pages; (max_write/4096)];
		%time
		AvgTime_wbck = [AvgTime_wbck; sum(time)/size(time)(1)];
		TotalTime_wbck = [TotalTime_wbck time];
		timeSD = std(time);
		TimeSD_wbck = [TimeSD_wbck ; timeSD ];
		MaxTime_wbck = [MaxTime_wbck ; max(time)];
		MinTime_wbck = [MinTime_wbck ; min(time)];
		%throughput
		AvgThroughPut_wbck = [AvgThroughPut_wbck; sum(throughput)/size(throughput)(1)];	
		TotalThroughPut_wbck = [TotalThroughPut_wbck throughput];
		throughputSD = std(throughput);
		ThroughPutSD_wbck = [ThroughPutSD_wbck; throughputSD];
		MaxThroughPut_wbck = [MaxThroughPut_wbck ; max(throughput)];
		MinThroughPut_wbck = [MinThroughPut_wbck ; min(throughput)];
		%write reqs
		AvgWriteReqs_wbck = [AvgWriteReqs_wbck; sum(writereqs)/size(writereqs)(1)];
		TotalWriteReqs_wbck = [TotalWriteReqs_wbck writereqs];
		writereqsSD = std(writereqs);
		WriteReqsSD_wbck = [WriteReqsSD_wbck; writereqsSD];
		%cpu
		AvgUsercpu_wbck = [AvgUsercpu_wbck; sum(usercpu)/size(usercpu)(1)];
		AvgSystemcpu_wbck = [AvgSystemcpu_wbck; sum(systemcpu)/size(systemcpu)(1)];
		AvgIOwaitcpu_wbck = [AvgIOwaitcpu_wbck; sum(iowaitcpu)/size(iowaitcpu)(1)];
		AvgIdlecpu_wbck = [AvgIdlecpu_wbck; sum(idlecpu)/size(idlecpu)(1)];
		%mem
		AvgMemutil_wbck = [AvgMemutil_wbck; sum(memutil)/size(memutil)(1)];
		AvgDirtydata_wbck = [AvgDirtydata_wbck; sum(dirtydata)/size(dirtydata)(1)];
		AvgCntxtSwtchs_wbck = [AvgCntxtSwtchs_wbck; sum(cntxtswtchs)/size(cntxtswtchs)(1)];
		%disk
		AvgWritereqs_wbck = [AvgWritereqs_wbck; sum(writereqs)/size(writereqs)(1)];
		AvgKBWritten_wbck = [AvgKBWritten_wbck; sum(kbwritten)/size(kbwritten)(1)];
		AvgWwait_wbck = [AvgWwait_wbck; sum(wwait)/size(wwait)(1)];
		AvgDiskutil_wbck = [AvgDiskutil_wbck; sum(diskutil)/size(diskutil)(1)];
	end
end

%AvgTime_wbck
%TotalTime_wbck
%MinTime_wbck
%MaxTime_wbck
%TimeSD_wbck
%AvgThroughPut_wbck
%TotalThroughPut_wbck
%MinThroughPut_wbck
%MaxThroughPut_wbck
%ThroughPutSD_wbck
%AvgWriteReqs_wbck
%TotalWriteReqs_wbck
%WriteReqsSD_wbck
%AvgUsercpu_wbck
%AvgSystemcpu_wbck
%AvgIOwaitcpu_wbck
%AvgIdlecpu_wbck
%AvgMemutil_wbck
%AvgDirtydata_wbck
%AvgCntxtSwtchs_wbck
%AvgWritereqs_wbck
%AvgKBWritten_wbck
%AvgWwait_wbck
%AvgDiskutil_wbck

Total_iters = 5; %small tweak, not required for future cases

%Big writes
%time
AvgTime_bwrt = [];
TotalTime_bwrt = [];
MaxTime_bwrt = [];
MinTime_bwrt = [];
TimeSD_bwrt = [];
%throughput
AvgThroughPut_bwrt = [];
TotalThroughPut_bwrt = [];
MaxThroughPut_bwrt = [];
MinThroughPut_bwrt = [];
ThroughPutSD_bwrt = [];
%write reqs
AvgWriteReqs_bwrt = [];
TotalWriteReqs_bwrt = [];
WriteReqsSD_bwrt = [];
max_write_pages = [];
%cpuStats
AvgUsercpu_bwrt = [];
AvgSystemcpu_bwrt = [];
AvgIOwaitcpu_bwrt = [];
AvgIdlecpu_bwrt = [];
%memStats
AvgMemutil_bwrt = [];
AvgDirtydata_bwrt = [];
AvgCntxtSwtchs_bwrt = [];
%diskstats
AvgWritereqs_bwrt = [];
AvgKBWritten_bwrt = [];
AvgWwait_bwrt = [];
AvgDiskutil_bwrt = [];

for i=1:size(max_writes)(1)
	for j=iterations:iterations
		%time
		time = [];
		timeSD = 0;
		%throughput
		throughput = [];
		throughputSD = 0;
		%write reqs
		writereqs = [];
		writereqsSD = 0;
		%cpu
                usercpu = [];
                systemcpu = [];
                iowaitcpu = [];
                idlecpu = [];
                %mem
                memutil = [];
                dirtydata = [];
                cntxtswtchs = [];
                %disk
                writereqs = [];
                kbwritten = [];
                wwait = [];
                diskutil = [];
		for count=1:Total_iters
			max_write = max_writes(i);
			iteration = iterations;
			filename = strcat(dir2, sprintf('Stat-files-%d-%d-Final-%d/time.txt', max_write, iteration, count));
			temp_time = load(filename);
			filename = strcat(dir2, sprintf('Stat-files-%d-%d-Final-%d/throughput.txt', max_write, iteration, count));
			temp_throughput = load(filename);
			filename = strcat(dir2, sprintf('Stat-files-%d-%d-Final-%d/FUSE_WRITE_user_processing_distribution.txt', max_write, iteration, count));
			temp_writereqs = load(filename);
			filename = strcat(dir2, sprintf('Stat-files-%d-%d-Final-%d/AvgCpuStats.txt', max_write, iteration, count));
                        temp_cpu = load(filename);
                        filename = strcat(dir2, sprintf('Stat-files-%d-%d-Final-%d/AvgMemStats.txt', max_write, iteration, count));
                        temp_mem = load(filename);
                        filename = strcat(dir2, sprintf('Stat-files-%d-%d-Final-%d/AvgDiskStats.txt', max_write, iteration, count));
                        temp_disk = load(filename);
                        %disk
                        writereqs = [writereqs; temp_disk(1)];
                        kbwritten = [kbwritten; temp_disk(2)];
                        wwait = [wwait; temp_disk(3)];
                        diskutil = [diskutil; temp_disk(4)];
                        %mem
                        memutil = [memutil; temp_mem(1)];
                        dirtydata = [dirtydata; temp_mem(2)];
                        cntxtswtchs = [cntxtswtchs; temp_mem(3)];
                        %cpu
                        usercpu = [usercpu; temp_cpu(1)];
                        systemcpu = [systemcpu; temp_cpu(2)];
                        iowaitcpu = [iowaitcpu; temp_cpu(3)];
                        idlecpu = [idlecpu; temp_cpu(4)];
			%write reqs	
			temp_writereqs = temp_writereqs(size(temp_writereqs)(1));
			writereqs = [writereqs ; temp_writereqs];
			%time
			time = [time ; temp_time];
			%throughput
			throughput = [throughput ; temp_throughput];
		end
		max_write_pages = [max_write_pages; (max_write/4096)];
		%time
		AvgTime_bwrt = [AvgTime_bwrt; sum(time)/size(time)(1)];
		TotalTime_bwrt = [TotalTime_bwrt time];
		timeSD = std(time);
		TimeSD_bwrt = [TimeSD_bwrt ; timeSD ];
		MaxTime_bwrt = [MaxTime_bwrt ; max(time)];
		MinTime_bwrt = [MinTime_bwrt ; min(time)];
		%throughput
		AvgThroughPut_bwrt = [AvgThroughPut_bwrt; sum(throughput)/size(throughput)(1)];	
		TotalThroughPut_bwrt = [TotalThroughPut_bwrt throughput];
		throughputSD = std(throughput);
		ThroughPutSD_bwrt = [ThroughPutSD_bwrt; throughputSD];
		MaxThroughPut_bwrt = [MaxThroughPut_bwrt ; max(throughput)];
		MinThroughPut_bwrt = [MinThroughPut_bwrt ; min(throughput)];
		%write reqs
		AvgWriteReqs_bwrt = [AvgWriteReqs_bwrt; sum(writereqs)/size(writereqs)(1)];
		TotalWriteReqs_bwrt = [TotalWriteReqs_bwrt writereqs];
		writereqsSD = std(writereqs);
		WriteReqsSD_bwrt = [WriteReqsSD_bwrt; writereqsSD];
		%cpu
                AvgUsercpu_bwrt = [AvgUsercpu_bwrt; sum(usercpu)/size(usercpu)(1)];
                AvgSystemcpu_bwrt = [AvgSystemcpu_bwrt; sum(systemcpu)/size(systemcpu)(1)];
                AvgIOwaitcpu_bwrt = [AvgIOwaitcpu_bwrt; sum(iowaitcpu)/size(iowaitcpu)(1)];
                AvgIdlecpu_bwrt = [AvgIdlecpu_bwrt; sum(idlecpu)/size(idlecpu)(1)];
                %mem
                AvgMemutil_bwrt = [AvgMemutil_bwrt; sum(memutil)/size(memutil)(1)];
                AvgDirtydata_bwrt = [AvgDirtydata_bwrt; sum(dirtydata)/size(dirtydata)(1)];
                AvgCntxtSwtchs_bwrt = [AvgCntxtSwtchs_bwrt; sum(cntxtswtchs)/size(cntxtswtchs)(1)];
                %disk
                AvgWritereqs_bwrt = [AvgWritereqs_bwrt; sum(writereqs)/size(writereqs)(1)];
                AvgKBWritten_bwrt = [AvgKBWritten_bwrt; sum(kbwritten)/size(kbwritten)(1)];
                AvgWwait_bwrt = [AvgWwait_bwrt; sum(wwait)/size(wwait)(1)];
                AvgDiskutil_bwrt = [AvgDiskutil_bwrt; sum(diskutil)/size(diskutil)(1)];
	end
end

%AvgTime_bwrt
%TotalTime_bwrt
%MinTime_bwrt
%MaxTime_bwrt
%TimeSD_bwrt
%AvgThroughPut_bwrt
%TotalThroughPut_bwrt
%MinThroughPut_bwrt
%MaxThroughPut_bwrt
%ThroughPutSD_bwrt
%AvgWriteReqs_bwrt
%TotalWriteReqs_bwrt
%WriteReqsSD_bwrt
%AvgUsercpu_bwrt
%AvgSystemcpu_bwrt
%AvgIOwaitcpu_bwrt
%AvgIdlecpu_bwrt
%AvgMemutil_bwrt
%AvgDirtydata_bwrt
%AvgCntxtSwtchs_bwrt
%AvgWritereqs_bwrt
%AvgKBWritten_bwrt
%AvgWwait_bwrt
%AvgDiskutil_bwrt

Total_iters = 10; %small tweak, not required for future cases

%Default Case
%time
defaultTotalTime = [];
%throughput
defaultTotalThroughPut = [];
%write reqs
defaultTotalWriteReqs = [];
%cpuStats
AvgUsercpu_dflt = [];
AvgSystemcpu_dflt = [];
AvgIOwaitcpu_dflt = [];
AvgIdlecpu_dflt = [];
%memStats
AvgMemutil_dflt = [];
AvgDirtydata_dflt = [];
AvgCntxtSwtchs_dflt = [];
%diskstats
AvgWritereqs_dflt = [];
AvgKBWritten_dflt = [];
AvgWwait_dflt = [];
AvgDiskutil_dflt = [];

max_write = 4096;
for j=iterations:iterations
	%time
	time = [];
	%throughput
        throughput = [];
	%write reqs
        writereqs = [];
	%cpu
       	usercpu = [];
        systemcpu = [];
        iowaitcpu = [];
        idlecpu = [];
        %mem
        memutil = [];
        dirtydata = [];
        cntxtswtchs = [];
        %disk
        writereqs = [];
        kbwritten = [];
        wwait = [];
        diskutil = [];
        for count=1:Total_iters
                iteration = iterations;
                filename = strcat(dir3, sprintf('Stat-files-%d-%d-Final-%d/time.txt', max_write, iteration, count));
               	temp_time = load(filename);
                filename = strcat(dir3, sprintf('Stat-files-%d-%d-Final-%d/throughput.txt', max_write, iteration, count));
                temp_throughput = load(filename);
                filename = strcat(dir3, sprintf('Stat-files-%d-%d-Final-%d/FUSE_WRITE_user_processing_distribution.txt', max_write, iteration, count));
                temp_writereqs = load(filename);
		filename = strcat(dir3, sprintf('Stat-files-%d-%d-Final-%d/AvgCpuStats.txt', max_write, iteration, count));
                temp_cpu = load(filename);
                filename = strcat(dir3, sprintf('Stat-files-%d-%d-Final-%d/AvgMemStats.txt', max_write, iteration, count));
                temp_mem = load(filename);
                filename = strcat(dir3, sprintf('Stat-files-%d-%d-Final-%d/AvgDiskStats.txt', max_write, iteration, count));
                temp_disk = load(filename);
                %disk
                writereqs = [writereqs; temp_disk(1)];
                kbwritten = [kbwritten; temp_disk(2)];
                wwait = [wwait; temp_disk(3)];
                diskutil = [diskutil; temp_disk(4)];
                %mem
                memutil = [memutil; temp_mem(1)];
                dirtydata = [dirtydata; temp_mem(2)];
                cntxtswtchs = [cntxtswtchs; temp_mem(3)];
                %cpu
                usercpu = [usercpu; temp_cpu(1)];
                systemcpu = [systemcpu; temp_cpu(2)];
                iowaitcpu = [iowaitcpu; temp_cpu(3)];
                idlecpu = [idlecpu; temp_cpu(4)];
		%write reqs
                temp_writereqs = temp_writereqs(size(temp_writereqs)(1));
                writereqs = [writereqs ; temp_writereqs];
		%time
                time = [time ; temp_time];
		%through put
                throughput = [throughput ; temp_throughput];
        end
	%time
        defaultAvgTime = sum(time)/size(time)(1);
	defaultTotalTime = [defaultTotalTime; time];
	defaultTimeSD = std(time);
	defaultMaxTime = max(time);
	defaultMinTime = min(time);
	%throughput
        defaultAvgThroughPut = sum(throughput)/size(throughput)(1);
	defaultTotalThroughPut = [defaultTotalThroughPut; throughput];
	defaultMinThroughPut = min(throughput);
	defaultMaxThroughPut = max(throughput);
	defaultThroughPutSD = std(throughput);
	%write reqs
        defaultAvgWriteReqs = sum(writereqs)/size(writereqs)(1);
	defaultTotalWriteReqs = [defaultTotalWriteReqs; writereqs];
	defaultWriteReqsSD = std(writereqs);
	%cpu
        AvgUsercpu_dflt = [AvgUsercpu_dflt; sum(usercpu)/size(usercpu)(1)];
        AvgSystemcpu_dflt = [AvgSystemcpu_dflt; sum(systemcpu)/size(systemcpu)(1)];
        AvgIOwaitcpu_dflt = [AvgIOwaitcpu_dflt; sum(iowaitcpu)/size(iowaitcpu)(1)];
        AvgIdlecpu_dflt = [AvgIdlecpu_dflt; sum(idlecpu)/size(idlecpu)(1)];
        %mem
        AvgMemutil_dflt = [AvgMemutil_dflt; sum(memutil)/size(memutil)(1)];
        AvgDirtydata_dflt = [AvgDirtydata_dflt; sum(dirtydata)/size(dirtydata)(1)];
        AvgCntxtSwtchs_dflt = [AvgCntxtSwtchs_dflt; sum(cntxtswtchs)/size(cntxtswtchs)(1)];
        %disk
        AvgWritereqs_dflt = [AvgWritereqs_dflt; sum(writereqs)/size(writereqs)(1)];
        AvgKBWritten_dflt = [AvgKBWritten_dflt; sum(kbwritten)/size(kbwritten)(1)];
        AvgWwait_dflt = [AvgWwait_dflt; sum(wwait)/size(wwait)(1)];
        AvgDiskutil_dflt = [AvgDiskutil_dflt; sum(diskutil)/size(diskutil)(1)];
end

%defaultAvgTime
%defaultTotalTime
%defaultMaxTime
%defaultMinTime
%defaultTimeSD
%defaultAvgThroughPut
%defaultTotalThroughPut
%defaultMinThroughPut
%defaultMaxThroughPut
%defaultThroughPutSD
%defaultAvgWriteReqs
%defaultTotalWriteReqs
%defaultWriteReqsSD
%AvgUsercpu_dflt
%AvgSystemcpu_dflt
%AvgIOwaitcpu_dflt
%AvgIdlecpu_dflt
%AvgMemutil_dflt
%AvgDirtydata_dflt
%AvgCntxtSwtchs_dflt
%AvgWritereqs_dflt
%AvgKBWritten_dflt
%AvgWwait_dflt
%AvgDiskutil_dflt


%No FUSE Case
max_write = 1048576;
%time
noFuseTotalTime = [];
%write reqs
noFuseTotalThroughPut = [];
%cpuStats
AvgUsercpu_nofuse = [];
AvgSystemcpu_nofuse = [];
AvgIOwaitcpu_nofuse = [];
AvgIdlecpu_nofuse = [];
%memStats
AvgMemutil_nofuse = [];
AvgDirtydata_nofuse = [];
AvgCntxtSwtchs_nofuse = [];
%diskstats
AvgWritereqs_nofuse = [];
AvgKBWritten_nofuse = [];
AvgWwait_nofuse = [];
AvgDiskutil_nofuse = [];

for j=iterations:iterations
	%time
        time = [];
	%through put
        throughput = [];
	%cpu
        usercpu = [];
        systemcpu = [];
        iowaitcpu = [];
        idlecpu = [];
        %mem
        memutil = [];
        dirtydata = [];
        cntxtswtchs = [];
        %disk
        writereqs = [];
        kbwritten = [];
        wwait = [];
        diskutil = [];
        for count=1:Total_iters
                iteration = iterations;
                filename = strcat(dir4, sprintf('Stat-files-%d-Final-%d/time.txt', max_write, count));
                temp_time = load(filename);
                filename = strcat(dir4, sprintf('Stat-files-%d-Final-%d/throughput.txt', max_write, count));
                temp_throughput = load(filename);
		filename = strcat(dir4, sprintf('Stat-files-%d-Final-%d/AvgCpuStats.txt', max_write, count));
                temp_cpu = load(filename);
                filename = strcat(dir4, sprintf('Stat-files-%d-Final-%d/AvgMemStats.txt', max_write, count));
                temp_mem = load(filename);
                filename = strcat(dir4, sprintf('Stat-files-%d-Final-%d/AvgDiskStats.txt', max_write, count));
                temp_disk = load(filename);
                %disk
                writereqs = [writereqs; temp_disk(1)];
                kbwritten = [kbwritten; temp_disk(2)];
                wwait = [wwait; temp_disk(3)];
                diskutil = [diskutil; temp_disk(4)];
                %mem
                memutil = [memutil; temp_mem(1)];
                dirtydata = [dirtydata; temp_mem(2)];
                cntxtswtchs = [cntxtswtchs; temp_mem(3)];
                %cpu
                usercpu = [usercpu; temp_cpu(1)];
                systemcpu = [systemcpu; temp_cpu(2)];
                iowaitcpu = [iowaitcpu; temp_cpu(3)];
                idlecpu = [idlecpu; temp_cpu(4)];
		%time
                time = [time ; temp_time];
		%through put
                throughput = [throughput ; temp_throughput];
        end
	%time
        noFuseAvgTime = sum(time)/size(time)(1);
	noFuseTotalTime = [noFuseTotalTime; time];
        noFuseTimeSD = std(time);
        noFuseMaxTime = max(time);
        noFuseMinTime = min(time);
	%through put
        noFuseAvgThroughPut = sum(throughput)/size(throughput)(1);
	noFuseTotalThroughPut = [noFuseTotalThroughPut; throughput];
        noFuseMinThroughPut = min(throughput);
        noFuseMaxThroughPut = max(throughput);
        noFuseThroughPutSD = std(throughput);
	%cpu
        AvgUsercpu_nofuse = [AvgUsercpu_nofuse; sum(usercpu)/size(usercpu)(1)];
        AvgSystemcpu_nofuse = [AvgSystemcpu_nofuse; sum(systemcpu)/size(systemcpu)(1)];
        AvgIOwaitcpu_nofuse = [AvgIOwaitcpu_nofuse; sum(iowaitcpu)/size(iowaitcpu)(1)];
        AvgIdlecpu_nofuse = [AvgIdlecpu_nofuse; sum(idlecpu)/size(idlecpu)(1)];
        %mem
        AvgMemutil_nofuse = [AvgMemutil_nofuse; sum(memutil)/size(memutil)(1)];
        AvgDirtydata_nofuse = [AvgDirtydata_nofuse; sum(dirtydata)/size(dirtydata)(1)];
        AvgCntxtSwtchs_nofuse = [AvgCntxtSwtchs_nofuse; sum(cntxtswtchs)/size(cntxtswtchs)(1)];
        %disk
        AvgWritereqs_nofuse = [AvgWritereqs_nofuse; sum(writereqs)/size(writereqs)(1)];
        AvgKBWritten_nofuse = [AvgKBWritten_nofuse; sum(kbwritten)/size(kbwritten)(1)];
        AvgWwait_nofuse = [AvgWwait_nofuse; sum(wwait)/size(wwait)(1)];
        AvgDiskutil_nofuse = [AvgDiskutil_nofuse; sum(diskutil)/size(diskutil)(1)];
end

plotdefaultAvgTime = [];
plotdefaultAvgThroughPut = [];
plotnofuseAvgTime = [];
plotnofuseAvgThroughPut = [];
for i=1:size(max_writes)(1)
	plotdefaultAvgTime = [plotdefaultAvgTime ; defaultAvgTime];
	plotdefaultAvgThroughPut = [plotdefaultAvgThroughPut ; defaultAvgThroughPut];
	plotnofuseAvgTime = [plotnofuseAvgTime ; noFuseAvgTime];
	plotnofuseAvgThroughPut = [plotnofuseAvgThroughPut ; noFuseAvgThroughPut];
end

%noFuseAvgTime
%noFuseTotalTime
%noFuseMaxTime
%noFuseMinTime
%noFuseTimeSD
%noFuseAvgThroughPut
%noFuseTotalThroughPut
%noFuseMinThroughPut
%noFuseMaxThroughPut
%noFuseThroughPutSD
%AvgUsercpu_nofuse
%AvgSystemcpu_nofuse
%AvgIOwaitcpu_nofuse
%AvgIdlecpu_nofuse
%AvgMemutil_nofuse
%AvgDirtydata_nofuse
%AvgCntxtSwtchs_nofuse
%AvgWritereqs_nofuse
%AvgKBWritten_nofuse
%AvgWwait_nofuse
%AvgDiskutil_nofuse

X = [1;2;3;4;5;6;7;8;9;10;11;12];
%CPU Utilisation
%{
AvgCpuutilisation_wbck = AvgUsercpu_wbck + AvgSystemcpu_wbck + AvgIOwaitcpu_wbck;
AvgCpuutilisation_bwrt = AvgUsercpu_bwrt + AvgSystemcpu_bwrt + AvgIOwaitcpu_bwrt;
AvgCpuutilisation_dflt = AvgUsercpu_dflt + AvgSystemcpu_dflt + AvgIOwaitcpu_dflt;
Avgcpuutilisation_nofuse = AvgUsercpu_nofuse + AvgSystemcpu_nofuse + AvgIOwaitcpu_nofuse;
plotAvgCpuutilisation_dflt = [];
plotAvgcpuutilisation_nofuse = [];

for i=1:size(max_writes)(1)
	plotAvgCpuutilisation_dflt = [plotAvgCpuutilisation_dflt; AvgCpuutilisation_dflt];
	plotAvgcpuutilisation_nofuse = [plotAvgcpuutilisation_nofuse; Avgcpuutilisation_nofuse];
end
figure;
clf;
hold on;
fig1 = plot(AvgCpuutilisation_wbck, 'b--*');
fig2 = plot(AvgCpuutilisation_bwrt, 'g--*');
fig3 = plot(plotAvgCpuutilisation_dflt, 'k');
fig4 = plot(plotAvgcpuutilisation_nofuse, 'r');

set(fig1(1), "linewidth", 6);
set(fig2(1), "linewidth", 6);
set(fig3(1), "linewidth", 6);
set(fig4(1), "linewidth", 6);
grid minor;
a = AvgCpuutilisation_wbck;
b = num2str(a);
c = cellstr(b);
dx=0;
dy=1.5;
text(X+dx, AvgCpuutilisation_wbck+dy, c, 'FontSize', 10);
a = AvgCpuutilisation_bwrt;
b = num2str(a);
c = cellstr(b);
text(X+dx, AvgCpuutilisation_bwrt-dy, c, 'FontSize', 10);
text(1, AvgCpuutilisation_dflt+dy, num2str(AvgCpuutilisation_dflt), 'FontSize', 10);
text(1, Avgcpuutilisation_nofuse-dy, num2str(Avgcpuutilisation_nofuse), 'FontSize', 10);
h_leg = legend('Averge CPU Utilisation (writeback\_cache)', 'Average CPU Utilisation (big\_writes)', 'Average CPU Utilisation (default parameters)', 'Average CPU Utilisation (No FUSE)');
set(h_leg, 'fontsize', 10);
axis([0 size(AvgCpuutilisation_wbck)(1)+1 0 max(AvgCpuutilisation_wbck)*1.8]);
text(1, max(AvgCpuutilisation_wbck) * 1.4, details, 'Color', 'blue', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_write_pages)(1), 'XTickLabel', max_write_pages);
xlabel('Different max writes (in pages of 4KB each)', 'fontsize', 15);
ylabel('CPU Utilisation (user + system + iowait)', 'fontsize', 15);
title ('CPU Utilisation comparision varying max\_writes', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/cpu_utilisation_comparision.png');
print(outfilename, "-dpng");
close();
%}
%individual cpu utilisations
%{
figure;
clf;
hold on;
fig1 = plot(AvgUsercpu_wbck, 'b--*');
fig2 = plot(AvgSystemcpu_wbck, 'g--*');
fig3 = plot(AvgIOwaitcpu_wbck, 'r--*');

set(fig1(1), "linewidth", 6);
set(fig2(1), "linewidth", 6);
set(fig3(1), "linewidth", 6);

grid minor;
a = AvgUsercpu_wbck;
b = num2str(a);
c = cellstr(b);
dx=0;
dy=1;
text(X+dx, AvgUsercpu_wbck+dy, c, 'FontSize', 10);
a = AvgSystemcpu_wbck;
b = num2str(a);
c = cellstr(b);
text(X+dx, AvgSystemcpu_wbck+dy, c, 'FontSize', 10);
a = AvgIOwaitcpu_wbck;
b = num2str(a);
c = cellstr(b);
text(X+dx, AvgIOwaitcpu_wbck+dy, c, 'FontSize', 10);
h_leg = legend('Avg cpu in user', 'Avg cpu in system', 'Avg cpu in IO Wait');
set(h_leg, 'fontsize', 10);
axis([0 size(AvgIOwaitcpu_wbck)(1)+1 0 max(AvgIOwaitcpu_wbck)*1.8]);
details{5} = 'Big Writes : No';
text(1, max(AvgIOwaitcpu_wbck) * 1.4, details, 'Color', 'blue', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_write_pages)(1), 'XTickLabel', max_write_pages);
xlabel('Different max writes (in pages of 4KB each)', 'fontsize', 15);
ylabel('Different CPU metrics (User, System and IO Wait)', 'fontsize', 15);
title ('CPU metrics varying max\_writes (writeback cache)', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/CPU_utilisation_writeback_cache.png');
print(outfilename, "-dpng");
close();

figure;
clf;
hold on;
fig1 = plot(AvgUsercpu_bwrt, 'b--*');
fig2 = plot(AvgSystemcpu_bwrt, 'g--*');
fig3 = plot(AvgIOwaitcpu_bwrt, 'r--*');

set(fig1(1), "linewidth", 6);
set(fig2(1), "linewidth", 6);
set(fig3(1), "linewidth", 6);

grid minor;
a = AvgUsercpu_bwrt;
b = num2str(a);
c = cellstr(b);
dx=0;
dy=1;
text(X+dx, AvgUsercpu_bwrt+dy, c, 'FontSize', 10);
a = AvgSystemcpu_bwrt;
b = num2str(a);
c = cellstr(b);
text(X+dx, AvgSystemcpu_bwrt+dy, c, 'FontSize', 10);
a = AvgIOwaitcpu_bwrt;
b = num2str(a);
c = cellstr(b);
text(X+dx, AvgIOwaitcpu_bwrt+dy, c, 'FontSize', 10);
h_leg = legend('Avg cpu in user', 'Avg cpu in system', 'Avg cpu in IO Wait');
set(h_leg, 'fontsize', 10);
axis([0 size(AvgIOwaitcpu_bwrt)(1)+1 0 max(AvgIOwaitcpu_bwrt)*1.8]);
details{2} = 'Write Back Cache : No';
text(1, max(AvgIOwaitcpu_bwrt) * 1.4, details, 'Color', 'blue', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_write_pages)(1), 'XTickLabel', max_write_pages);
xlabel('Different max writes (in pages of 4KB each)', 'fontsize', 15);
ylabel('Different CPU metrics (User, System and IO Wait)', 'fontsize', 15);
title ('CPU metrics varying max\_writes (big writes)', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/CPU_utilisation_big_writes.png');
print(outfilename, "-dpng");
close();
%}
%Memory Utilisation
%{
plotAvgMemutil_dflt = [];
plotAvgMemutil_nofuse = [];

for i=1:size(max_writes)(1)
	plotAvgMemutil_dflt = [plotAvgMemutil_dflt; AvgMemutil_dflt];
        plotAvgMemutil_nofuse = [plotAvgMemutil_nofuse; AvgMemutil_nofuse];
end
figure;
clf;
hold on;
fig1 = plot(AvgMemutil_wbck, 'b--*');
fig2 = plot(AvgMemutil_bwrt, 'g--*');
fig3 = plot(plotAvgMemutil_dflt, 'k');
fig4 = plot(plotAvgMemutil_nofuse, 'r');

set(fig1(1), "linewidth", 6);
set(fig2(1), "linewidth", 6);
set(fig3(1), "linewidth", 6);
set(fig4(1), "linewidth", 6);
grid minor;
a = AvgMemutil_wbck;
b = num2str(a);
c = cellstr(b);
dx=0;
dy=0.3;
text(X+dx, AvgMemutil_wbck-dy, c, 'FontSize', 10);
a = AvgMemutil_bwrt;
b = num2str(a);
c = cellstr(b);
text(X+dx, AvgMemutil_bwrt+dy, c, 'FontSize', 10);
%text(1, AvgMemutil_dflt+dy, num2str(AvgMemutil_dflt), 'FontSize', 10);
defaultdetails{1} = sprintf('Default Case Memory Utilisation : %2f', AvgMemutil_dflt);
text(3, AvgMemutil_dflt-4, defaultdetails, 'Color', 'black', 'FontSize', 14);
text(1, AvgMemutil_nofuse+dy, num2str(AvgMemutil_nofuse), 'FontSize', 10);
h_leg = legend('Averge Memory Utilisation (writeback\_cache)', 'Average Memory Utilisation (big\_writes)', 'Average Memory Utilisation (default parameters)', 'Average Memory Utilisation (No FUSE)');
set(h_leg, 'fontsize', 10);
axis([0 size(AvgMemutil_wbck)(1)+1 0 max(AvgMemutil_wbck)*2.1]);
text(1, max(AvgMemutil_wbck) * 1.6, details, 'Color', 'blue', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_write_pages)(1), 'XTickLabel', max_write_pages);
xlabel('Different max writes (in pages of 4KB each)', 'fontsize', 15);
ylabel('Memory Utilisation (%)', 'fontsize', 15);
title ('Memory Utilisation comparision varying max\_writes', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/memory_utilisation_comparision.png');
print(outfilename, "-dpng");
close();
%}
%context switches
%{
plotAvgCntxtSwtchs_dflt = [];
plotAvgCntxtSwtchs_nofuse = [];

for i=1:size(max_writes)(1)
        plotAvgCntxtSwtchs_dflt = [plotAvgCntxtSwtchs_dflt; AvgCntxtSwtchs_dflt];
        plotAvgCntxtSwtchs_nofuse = [plotAvgCntxtSwtchs_nofuse; AvgCntxtSwtchs_nofuse];
end

figure;
clf;
hold on;
fig1 = plot(log(AvgCntxtSwtchs_wbck), 'b--*');
fig2 = plot(log(AvgCntxtSwtchs_bwrt), 'g--*');
fig3 = plot(log(plotAvgCntxtSwtchs_dflt), 'k');
fig4 = plot(log(plotAvgCntxtSwtchs_nofuse), 'r');

set(fig1(1), "linewidth", 6);
set(fig2(1), "linewidth", 6);
set(fig3(1), "linewidth", 6);
set(fig4(1), "linewidth", 6);

grid minor;
a = AvgCntxtSwtchs_wbck;
b = num2str(a);
c = cellstr(b);
dx=0;
dy=0.9;
text(X+dx, log(AvgCntxtSwtchs_wbck)-dy, c, 'FontSize', 10);
a = AvgCntxtSwtchs_bwrt;
b = num2str(a);
c = cellstr(b);
text(X+dx, log(AvgCntxtSwtchs_bwrt)+dy, c, 'FontSize', 10);
text(1, log(AvgCntxtSwtchs_dflt)+dy, num2str(AvgCntxtSwtchs_dflt), 'FontSize', 10);
text(1, log(AvgCntxtSwtchs_nofuse)-dy, num2str(AvgCntxtSwtchs_nofuse), 'FontSize', 10);
h_leg = legend('Averge Context Switches (writeback\_cache)', 'Average Context Switches (big\_writes)', 'Average Context Switches (default parameters)', 'Average Context Switches (No FUSE)');
set(h_leg, 'fontsize', 10);
axis([0 size(log(AvgCntxtSwtchs_wbck))(1)+1 0 max(log(AvgCntxtSwtchs_wbck))*3]);
text(1, max(log(AvgCntxtSwtchs_wbck)) * 2, details, 'Color', 'blue', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_write_pages)(1), 'XTickLabel', max_write_pages);
xlabel('Different max writes (in pages of 4KB each)', 'fontsize', 15);
ylabel('Total No. of context switches (log)', 'fontsize', 15);
title ('Context Switches comparision varying max\_writes', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/context_switches_comparision.png');
print(outfilename, "-dpng");
close();
%}

%Time
%{
figure;
clf;
hold on;
fig1 = plot(AvgTime_wbck, 'b--*');
fig2 = plot(AvgTime_bwrt, 'g--*');
fig4 = plot(plotdefaultAvgTime, 'k');
fig5 = plot(plotnofuseAvgTime, 'r');

set(fig1(1), "linewidth", 6);
set(fig2(1), "linewidth", 6);
set(fig4(1), "linewidth", 6);
set(fig5(1), "linewidth", 6);
grid minor;
a = AvgTime_wbck;
b = num2str(a);
c = cellstr(b);
dx=0;
dy=20;
text(X+dx, AvgTime_wbck+dy,c, 'FontSize', 10);
a = AvgTime_bwrt;
b = num2str(a);
c = cellstr(b);
text(X+dx, AvgTime_bwrt-dy,c, 'FontSize', 10);
%text(1, defaultAvgTime-dy, num2str(defaultAvgTime), 'FontSize', 10);
text(1, noFuseAvgTime-dy, num2str(noFuseAvgTime), 'FontSize', 10);
defaultDetails{1} = sprintf('FUSE Default Avg Time : %2f', defaultAvgTime);
defaultDetails{2} = sprintf('FUSE Default Min Time : %2f', defaultMinTime);
defaultDetails{3} = sprintf('FUSE Default Max Time : %2f', defaultMaxTime);
defaultDetails{4} = sprintf('FUSE Default Standard Deviation : %2f', defaultTimeSD);

text(3, noFuseAvgTime-75, defaultDetails, 'Color', 'black', 'FontSize', 14);
noFuseDetails{1} = sprintf('No FUSE Min Time : %2f', noFuseMinTime);
noFuseDetails{2} = sprintf('No FUSE Max Time : %2f', noFuseMaxTime);
noFuseDetails{3} = sprintf('No FUSE Standard Deviation : %2f', noFuseTimeSD);
text(3, noFuseAvgTime-250, noFuseDetails, 'Color', 'red', 'FontSize', 14);
h_leg = legend('Averge Time (writeback\_cache)', 'Average Time (big\_writes)', 'Average Time (default parameters)', 'Average Time (No FUSE)');
set(h_leg, 'fontsize', 10);
axis([0 size(AvgTime_wbck)(1)+1 0 max(AvgTime_wbck)*1.8]);
text(1, max(AvgTime_wbck) * 1.4, details, 'Color', 'blue', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_write_pages)(1), 'XTickLabel', max_write_pages);
xlabel('Different max writes (in pages of 4KB each)', 'fontsize', 15);
ylabel('Time Taken to complete Experiment (in secs)', 'fontsize', 15);
title ('Time Taken varying different max\_writes', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/TimeTaken_from_filebench_comparison.png');
print(outfilename, "-dpng");
close();

%Standard Deviation of Time Taken
figure;
clf;
hold on;
fig1 = plot(AvgTime, 'b--*');
fig2 = plot(MinTime, 'k--*');
fig3 = plot(MaxTime, 'r--*');
set(fig1(1), "linewidth", 6);
set(fig2(1), "linewidth", 6);
set(fig3(1), "linewidth", 6);
grid minor;
a = AvgTime;
b = num2str(a);
c = cellstr(b);
dx=0.001;
dy=8;
text(X+dx, AvgTime-dy,c, 'FontSize', 10);
a = MinTime;
b = num2str(a);
c = cellstr(b);
dx=0.001;
dy=30;
text(X+dx, MinTime-dy,c, 'FontSize', 10);
a = MaxTime;
b = num2str(a);
c = cellstr(b);
dx=0.001;
dy=30;
text(X+dx, MaxTime+dy,c, 'FontSize', 10);
h_leg = legend('Averge Time (big\_writes)', 'Minimum Time (big\_writes)', 'Maximum Time (big\_writes)');
set(h_leg, 'fontsize', 10);
axis([0 size(AvgTime)(1)+1 0 max(AvgTime)*1.9]);
text(2, max(AvgTime) * 1.5, details, 'Color', 'blue', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_write_pages)(1), 'XTickLabel', max_write_pages);
xlabel('Different max writes (in pages of 4KB each)', 'fontsize', 15);
ylabel('Time Taken to complete Experiment (in secs)', 'fontsize', 15);
title ('Standard deviation of Time Taken varying different max\_writes', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/StandardDeviation_Time_big_writes_plot.png');
print(outfilename, "-dpng");
close();


%Standard Deviation of Time Taken but in bar
figure;
clf;
hold on;
h = bar(TimeSD);
a = TimeSD;
b = num2str(a);
c = cellstr(b);
dx=0.5;
dy=0.5;
text(X-dx, TimeSD+dy, c, 'FontSize', 10);
axis([0 size(TimeSD)(1)+1 0 max(TimeSD)*1.7]);
text(2, max(TimeSD) * 1.4, details, 'Color', 'blue', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_write_pages)(1), 'XTickLabel', max_write_pages);
xlabel('Different max writes (in pages of 4KB each)', 'fontsize', 15);
ylabel('Standard deviation in Time (in secs)', 'fontsize', 15);
title ('Standard deviation of Time Taken varying different max\_writes', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/StandardDeviation_Time_big_writes_bargraph.png');
print(outfilename, "-dpng");
close();
%}

%ThroughPut
%{
figure;
clf;
hold on;
fig1 = plot(AvgThroughPut, 'b--*');
fig2 = plot(plotdefaultAvgThroughPut, 'k');
fig3 = plot(plotnofuseAvgThroughPut, 'r');

set(fig1(1), "linewidth", 6);
set(fig2(1), "linewidth", 6);
set(fig3(1), "linewidth", 6);
grid minor;
a = AvgThroughPut;
b = num2str(a);
c = cellstr(b);
dx=0;
dy=6;
text(X+dx, AvgThroughPut-dy,c, 'FontSize', 10);
text(1, defaultAvgThroughPut+dy, num2str(defaultAvgThroughPut), 'FontSize', 10);
text(1, noFuseAvgThroughPut+dy, num2str(noFuseAvgThroughPut), 'FontSize', 10);

defaultDetails{1} = sprintf('FUSE Default Min ThroughPut : %0.2f', defaultMinThroughPut);
defaultDetails{2} = sprintf('FUSE Default Max ThroughPut : %0.2f', defaultMaxThroughPut);
defaultDetails{3} = sprintf('FUSE Default Standard Deviation : %0.2f', defaultThroughPutSD);

text(1, noFuseAvgThroughPut-90, defaultDetails, 'Color', 'black', 'FontSize', 14);

noFuseDetails{1} = sprintf('No FUSE Min ThroughPut : %0.2f', noFuseMinThroughPut);
noFuseDetails{2} = sprintf('No FUSE Max ThroughPut : %0.2f', noFuseMaxThroughPut);
noFuseDetails{3} = sprintf('No FUSE Standard Deviation : %0.2f', noFuseThroughPutSD);

text(1, noFuseAvgThroughPut-120, noFuseDetails, 'Color', 'red', 'FontSize', 14);
h_leg = legend('Averge ThroughPut (writeback\_cache)', 'Average ThroughPut (default parameters)', 'Average ThroughPut (No FUSE)');
set(h_leg, 'fontsize', 10);
axis([0 size(AvgThroughPut)(1)+1 0 max(AvgThroughPut)*1.95]);
text(2, max(AvgThroughPut) * 1.5, details, 'Color', 'blue', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_write_pages)(1), 'XTickLabel', max_write_pages);
xlabel('Different max writes (in pages of 4KB each)', 'fontsize', 15);
ylabel('ThroughPut to complete Experiment (in mb/s)', 'fontsize', 15);
title ('ThroughPut varying different max\_writes', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/ThroughPut_writeback_cache_change_comparison.png');
print(outfilename, "-dpng");
close();
%}
%{
%Standard Deviation of ThroughPut
figure;
clf;
hold on;
fig1 = plot(AvgThroughPut, 'b--*');
fig2 = plot(MinThroughPut, 'k--*');
fig3 = plot(MaxThroughPut, 'r--*');
set(fig1(1), "linewidth", 6);
set(fig2(1), "linewidth", 6);
set(fig3(1), "linewidth", 6);
grid minor;

a = AvgThroughPut;
b = num2str(a);
c = cellstr(b);
dx=0.001;
dy=5;
text(X+dx, AvgThroughPut-dy,c, 'FontSize', 10);

a = MinThroughPut;
b = num2str(a);
c = cellstr(b);
dx=0.001;
dy=5;
text(X+dx, MinThroughPut-dy,c, 'FontSize', 10);

a = MaxThroughPut;
b = num2str(a);
c = cellstr(b);
dx=0.001;
dy=5;
text(X+dx, MaxThroughPut+dy,c, 'FontSize', 10);

h_leg = legend('Averge ThroughPut (big\_writes)', 'Minimum ThroughPut (big\_writes)', 'Maximum ThroughPut (big\_writes)');
set(h_leg, 'fontsize', 10);
axis([0 size(AvgThroughPut)(1)+1 0 max(AvgThroughPut)*1.9]);
text(2, max(AvgThroughPut) * 1.5, details, 'Color', 'blue', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_write_pages)(1), 'XTickLabel', max_write_pages);
xlabel('Different max writes (in pages of 4KB each)', 'fontsize', 15);
ylabel('ThroughPut to complete Experiment (in mb/s)', 'fontsize', 15);
title ('Standard deviation of ThroughPut varying different max\_writes', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/StandardDeviation_ThroughPut_big_writes_plot.png');
print(outfilename, "-dpng");
close();

%Standard Deviation of ThroughPut but in bar
figure;
clf;
hold on;
h = bar(ThroughPutSD);
a = ThroughPutSD;
b = num2str(a);
c = cellstr(b);
dx=0.5;
dy=0.5;
text(X-dx, ThroughPutSD+dy, c, 'FontSize', 10);
axis([0 size(ThroughPutSD)(1)+1 0 max(ThroughPutSD)*1.7]);
text(2, max(ThroughPutSD) * 1.4, details, 'Color', 'blue', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_write_pages)(1), 'XTickLabel', max_write_pages);
xlabel('Different max writes (in pages of 4KB each)', 'fontsize', 15);
ylabel('Standard deviation in ThroughPut (in mb/s)', 'fontsize', 15);
title ('Standard deviation of ThroughPut varying different max\_writes', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/StandardDeviation_ThroughPut_big_writes_bargraph.png');
print(outfilename, "-dpng");
close();

%WriteReqs;
temp_WriteReqs = log(AvgWriteReqs);
plotdefaultAvgWriteReqs = [];
plotnoFuseAvgWriteReqs = [];
for i=1:size(max_writes)(1)
	plotdefaultAvgWriteReqs = [plotdefaultAvgWriteReqs; defaultAvgWriteReqs];
	plotnoFuseAvgWriteReqs = [plotnoFuseAvgWriteReqs; iterations];
end
temp_plotdefaultAvgWriteReqs = log(plotdefaultAvgWriteReqs);
temp_plotnoFuseAvgWriteReqs = log(plotnoFuseAvgWriteReqs);


figure;
clf;
hold on;
fig3 = plot(temp_WriteReqs, 'b--*');
fig4 = plot(temp_plotdefaultAvgWriteReqs, 'k');
fig5 = plot(temp_plotnoFuseAvgWriteReqs, 'r');

set(fig3(1), "linewidth", 6);
set(fig4(1), "linewidth", 6);
set(fig5(1), "linewidth", 6);

grid minor;
a = AvgWriteReqs;
b = num2str(a);
c = cellstr(b);
dx=0.5;
dy=0.5;
text(X-dx, (temp_WriteReqs)+dy,c, 'FontSize', 10);
text(1, (temp_plotdefaultAvgWriteReqs(1))+dy, num2str(defaultAvgWriteReqs), 'FontSize', 10);
text(1, (temp_plotnoFuseAvgWriteReqs(1))+dy, num2str(iterations), 'FontSize', 10);
h_leg = legend('Averge Write Reqs (big\_writes)', 'Average Write Reqs (default parameters)', 'Average Write Reqs (No FUSE)');
set(h_leg, 'fontsize', 10);
defaultDetails{1} = sprintf('FUSE Default Standard Deviation : %0.2f', defaultWriteReqsSD);
text(3, (temp_plotnoFuseAvgWriteReqs(1))-3, defaultDetails, 'Color', 'black', 'FontSize', 14);
axis([0 size(max_write_pages)(1)+1 0 max(temp_plotdefaultAvgWriteReqs)*1.8]);
text(2, max(temp_WriteReqs) * 1.6, details, 'Color', 'red', 'FontSize', 14);
set(gca, 'XTick', 1:size(max_write_pages)(1), 'XTickLabel', max_write_pages);
xlabel('Different max writes (in pages of 4KB each)', 'fontsize', 15);
ylabel('FUSE Write Requests generated (in log)', 'fontsize', 15);
title ('FUSE WRITE Requests varying different max\_writes', 'fontsize', 15);
hold off;
outfilename = strcat(outputDir, '/Write_reqs_big_writes.png');
print(outfilename, "-dpng");
close();
%}
