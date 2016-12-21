#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <stdlib.h>
#include <unordered_map>

using namespace std;

/* parse the disk stats which were collected during the 
 * filebench workload and calculate the read/write utilisation
 * using the below formula.
 **/

/* Following will be the contents of the /proc/diskstats
 * major  minor  name  Reads        Reads    Sectors  Time Spent     Writes	Writes	   Sectors     Time Spent       I/O's      Time Spent	     weighted time spent	
 * 			completed    merged   Read     Reading(ms)   Completed	 merged	    Written 	Writing(ms)   Currently   doing I/O's(ms)	I/O's (ms)
 *  8      16     sdb    1048          0      8372      164349        216518     1173861   136268152    52716395 	145 	   464559 	      52899933
 *
 *  reads_diff = curr_reads_completed - prev_reads_completed
 *  reads_time_diff = curr_reads_time - prev_reads_time
 *  read_throughput = reads_diff / reads_time_diff
 *  Reads_merged = curr_reads_merged - prev_reads_merged (usefull incase of sequential writes/reads)
 *
 *  writes_diff = curr_writes_completed - prev_writes_completed
 *  writes_time_diff = curr_writes_time - prev_writes_time
 *  write_throughput = writes_diff / writes_time_diff
 *  writes_merged = curr_writes_merged - prev_writes_merged (usefull incase of sequential writes/reads)
 *
 * */

void print_usage() {
	cout<<"./parse-disk-stats <Folder containing files>\n";
}

int main(int argc, char *argv[]) {
	if (argc != 2) {
		print_usage();
		return 0;
        }
	
	string outputfilename, STRING, outputfolder;
	vector<double> reads_throughput, writes_throughput;
	vector<unsigned long> Reads_merged, Writes_merged;
	string disk_stats_file;
	ifstream input;
	ofstream output;
	outputfolder = argv[1];

	disk_stats_file =  outputfolder + "/diskstats.txt";

	input.open(disk_stats_file);

	if (input) {
		bool started = false;
		bool first = false;
		string junk;
		unsigned long prev_rds_comp, prev_rds_time, prev_rds_merged, prev_wrs_comp, prev_wrs_time, prev_wrs_merged;
		unsigned long curr_rds_comp, curr_rds_time, curr_rds_merged, curr_wrs_comp, curr_wrs_time, curr_wrs_merged;
		unsigned long reads_merged, writes_merged;
		double reads_diff, reads_time_diff, read_throughput, writes_diff, writes_time_diff, write_throughput;

		getline(input, STRING);
		while (!input.eof()) {
			/* This is when actual workload starts (after the prealloc, if any) */
			if (!started && STRING.find("started") != string::npos)
				started = true;

			/* ``sdb'' is the disk that we are using */
			if (started && STRING.find("sdb") != string::npos) {
				if (!first) {
					/* fill the prev stats*/
					stringstream ss;

					ss << STRING;

					ss >> junk; /* major */
					ss >> junk; /* minor */
					ss >> junk; /* name */
					ss >> prev_rds_comp;
					ss >> prev_rds_merged;
					ss >> junk; /* sectors read */
					ss >> prev_rds_time; /* in ms */

					ss >> prev_wrs_comp;
					ss >> prev_wrs_merged;
					ss >> junk; /* sectors written */
					ss >> prev_wrs_time; /* in ms */

					first = true;
				} else {
					/* fill the curr stats */
					stringstream ss;
		
					ss << STRING;

					ss >> junk; /* major */
                                        ss >> junk; /* minor */
                                        ss >> junk; /* name */
                                        ss >> curr_rds_comp;
                                        ss >> curr_rds_merged;
                                        ss >> junk; /* sectors read */
                                        ss >> curr_rds_time; /* in ms */

                                        ss >> curr_wrs_comp;
                                        ss >> curr_wrs_merged;
                                        ss >> junk; /* sectors written */
                                        ss >> curr_wrs_time; /* in ms */

					reads_diff = curr_rds_comp - prev_rds_comp;
					reads_time_diff = curr_rds_time - prev_rds_time;
					read_throughput = (reads_diff / reads_time_diff) * 1000;
					reads_merged = curr_rds_merged - prev_rds_merged;
					reads_throughput.push_back(read_throughput);
					Reads_merged.push_back(reads_merged);

					writes_diff = curr_wrs_comp - prev_wrs_comp;
					writes_time_diff = curr_wrs_time - prev_wrs_time;
					write_throughput = (writes_diff / writes_time_diff) * 1000;
					writes_merged = curr_wrs_merged - prev_wrs_merged;
					writes_throughput.push_back(write_throughput);
					Writes_merged.push_back(writes_merged);

					/* Assign curr stats as prev stats for next iteration */
					prev_rds_comp = curr_rds_comp;
					prev_rds_merged = curr_rds_merged;
					prev_rds_time = curr_rds_time;

					prev_wrs_comp = curr_wrs_comp;	
					prev_wrs_merged = curr_wrs_merged;
					prev_wrs_time = curr_wrs_time;
				}
			}

			getline(input, STRING);
		}
		input.close();
	} else
		cout<<"Error in opeing file : "<<disk_stats_file<<"\n";

	/* writes_per_sec.txt : writes completed/sec   :  writes merged */
	outputfilename = outputfolder + "/writes_per_sec.txt";
	output.open(outputfilename, std::ofstream::out);
	for (int i = 0; i < writes_throughput.size(); i++)
		output<<writes_throughput[i]<<"		"<<Writes_merged[i]<<"\n";
	output.close();

	/* reads_per_sec.txt : reads completed/sec   :  reads merged */
	outputfilename = outputfolder + "/reads_per_sec.txt";
	output.open(outputfilename, std::ofstream::out);
	for (int i = 0; i < reads_throughput.size(); i++)
		output<<reads_throughput[i]<<"		"<<Reads_merged[i]<<"\n";
	output.close();

return 0;
}
