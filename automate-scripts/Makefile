all: parse-output parse-ouput-no-fuse parse-bdi-stats parse-tracefile-pause parse-tracefile-kernel-flusher parse-tracefile-StackFS parse-cpu-stats parse-disk-stats parse-filebench parse-fio parse-fuse-stats parse-tracefile-default-fuse parse-tracefile-no-fuse parse-profile-points

parse-output:
	g++ -std=c++11 parse-output.cpp -o parse-output
	
parse-ouput-no-fuse:
	g++ -std=c++11 parse-output-no-fuse.cpp -o parse-output-no-fuse

parse-bdi-stats:
	g++ -std=c++11 parse-bdi-stats.cpp -o parse-bdi-stats

parse-tracefile-pause:
	g++ -std=c++11 parse-tracefile-pause.cpp -o parse-tracefile-pause

parse-tracefile-kernel-flusher:
	g++ -std=c++11 parse-tracefile-kernel-flusher.cpp -o parse-tracefile-kernel-flusher

parse-tracefile-StackFS:
	g++ -std=c++11 parse-tracefile-StackFS.cpp -o parse-tracefile-StackFS

parse-cpu-stats:
	g++ -std=c++11 parse-cpu-stats.cpp -o parse-cpu-stats

parse-disk-stats:
	g++ -std=c++11 parse-disk-stats.cpp -o parse-disk-stats

parse-filebench:
	g++ -std=c++11 parse-filebench.cpp -o parse-filebench

parse-fio:
	g++ -std=c++11 parse-fio.cpp -o parse-fio

parse-fuse-stats:
	g++ -std=c++11 parse-fuse-stats.cpp -o parse-fuse-stats

parse-tracefile-default-fuse:
	g++ -std=c++11 parse-tracefile-default-fuse.cpp -o parse-tracefile-default-fuse

parse-tracefile-no-fuse:
	g++ -std=c++11 parse-tracefile-no-fuse.cpp -o parse-tracefile-no-fuse

parse-profile-points:
	g++ -std=c++11 parse-profile-points.cpp -o parse-profile-points

clean:
	rm -rf parse-output
	rm -rf parse-output-no-fuse
	rm -rf parse-bdi-stats
	rm -rf parse-tracefile-pause
	rm -rf parse-tracefile-kernel-flusher
	rm -rf parse-tracefile-StackFS
	rm -rf parse-cpu-stats
	rm -rf parse-disk-stats
	rm -rf parse-filebench
	rm -rf parse-fio
	rm -rf parse-fuse-stats
	rm -rf parse-tracefile-no-fuse
	rm -rf parse-tracefile-default-fuse
	rm -rf parse-profile-points
