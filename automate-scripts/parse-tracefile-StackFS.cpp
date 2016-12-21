#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <stdlib.h>
#include <unordered_map>

using namespace std;

void print_usage() {
        cout<<"./parse-tracefile-StackFS <Folder containing trace file>\n";
}

/**
 * Parse the User Space StackFS tarce log file
 * To captute PID, Thread Id's (in case of Multi threaded)
 * and their completeion of jobs (function calls)
 * */

int main(int argc, char *argv[]) {
	if (argc != 2) {
                print_usage();
                return 0;
        }

        string STRING, outputfolder;
        int i;
        int iteration = 0;
        ifstream input;
        ofstream output;
	unordered_map<int, unordered_map<int, int> > Map;
	unordered_map<int, unordered_map<int, int> >::iterator Map_iter;
	unordered_map<int, int>::iterator tid_map_iter;
	int pid;
	int tid;
	int count;
/*
 * Key will be PID
 * Value will be map with key as TID, and its value as func processed count
 * */

	unordered_map<unsigned long, vector<double> > Map1;
	unordered_map<unsigned long, vector<double> >::iterator Map1_iter;
/* 
 * key is the inode, and value is the list of time taken for underlying Ext4
 * */

        outputfolder = argv[1];

        string pause_stats_file, tracefile, temp;
        string outputfilename;

        tracefile = outputfolder + "/trace_stackfs.log";
	
	input.open(tracefile.c_str());
	if (input) {
		getline(input, STRING);
		while (!input.eof()) {
			if (STRING.find("Function Trace :") != string::npos) {
				stringstream ss;
				ss << STRING;
				string temp;
				int val;
				i = 0;
				/* Time : 1469765080178357 Pid : 15029 Tid : 15038 Function Trace : Setattr */
				while (i < 13) {
					ss >> temp;
					if (i == 5) { /* Pid */
						stringstream ss1;
						ss1 << temp;
						ss1 >> val;

						pid = val;					 
					} else if (i == 8) { /* TID */
						stringstream ss1;
                                                ss1 << temp;
						ss1 >> val;

						tid = val;
						if (Map.count(pid)) {
							if (Map[pid].count(tid)) {
								(Map[pid])[tid] += 1;
							} else {
								(Map[pid])[tid] = 1;
							}
						} else {
							unordered_map<int, int> tid_map;

							tid_map[tid] = 1;
							Map[pid] = tid_map;
						}
					}
					i++;
				}
			} else if (STRING.find("Read inode :") != string::npos) {
				/* Time : 1479359116150960 Pid : 1134 Tid : 1191 Read inode : 139934933593136 off : 0 size : 16384 diff : 7306689 */
				stringstream ss;
				ss << STRING;
				string temp;
				int val;
				i = 0;
				unsigned long inode;
				unsigned long nano_secs;
				double milli_secs;

				while (i < 22) {
					ss >> temp;
					if (i == 12) { /* inode number */
						stringstream ss1;
						ss1 << temp;

						ss1 >> inode;
					} else if (i == 21) { /* time diff (ns) */
						stringstream ss1;
						ss1 << temp;
						ss1 >> nano_secs;

						milli_secs = nano_secs/(1000000);
					}
					i++;
				}
				if (Map1.count(inode))
					(Map1[inode]).push_back(milli_secs);
				else {
					vector<double> pread_times;

					pread_times.push_back(milli_secs);
					Map1[inode] = pread_times;
				}
			}
			getline(input, STRING);
		}
	} else
		cout<<"No trace file\n";

	outputfilename = outputfolder + "/stackfs_thread_details.txt";
        system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);	
	for (Map_iter=Map.begin(); Map_iter!=Map.end(); Map_iter++) {
		tid_map_iter = (Map_iter->second).begin();
//		cout<<"PID : "<<(Map_iter->first)<<"\n";
		while (tid_map_iter != (Map_iter->second).end()) {
			output<<(tid_map_iter->first)<<" "<<(tid_map_iter->second)<<"\n";
			tid_map_iter++;
		}
//		cout<<"=============================\n";
	}
	output.close();

	outputfilename = outputfolder + "/stackfs_pread_details.txt";
        system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
	vector<double> pread_temp;
	double sum;
	int pread_len;
	for (Map1_iter = Map1.begin(); Map1_iter != Map1.end(); Map1_iter++) {
		pread_temp = Map1_iter->second;
		pread_len = pread_temp.size();
		sum = 0;
		//cout<<" Inode : " << Map1_iter->first << " : ";
		for (int i = 0; i < pread_len; i++) {
			//cout<< pread_temp[i] << ", ";
			sum += pread_temp[i];
		}
		//cout<<"\n";
		if (pread_len > 1)
			output << Map1_iter->first << " : " << sum/(pread_len) << "\n";
	}
	output.close();

return 0;
}
