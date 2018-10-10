/*
 * Copyright (c) 2018      Manu Mathew
 * Copyright (c) 2016-2017 Bharath Kumar Reddy Vangoor
 * Copyright (c) 2017      Swaminathan Sivaraman
 * Copyright (c) 2016-2018 Vasily Tarasov
 * Copyright (c) 2016-2018 Erez Zadok
 * Copyright (c) 2016-2018 Stony Brook University
 * Copyright (c) 2016-2018 The Research Foundation of SUNY
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <stdlib.h>
#include <unordered_map>

using namespace std;


void print_usage() {
	cout<<"./parse-profile-points <Folder containing trace files>\n";
}

void get_inode_time(string bigger_string, int max_words, int time_stmp_loc, int inode_loc, unsigned long long *inode, unsigned long long *time_stmp) {
	stringstream ss;
	string temp;
	unsigned long long inode1, timestmp1;
	double time_stmp1;
	int i = 0;

	ss << bigger_string;
	while (i < max_words) {
		ss >> temp;
		if (i == time_stmp_loc) {
			temp = temp.substr(0, temp.length() - 1);
			stringstream ss1;

			ss1 << temp;
			ss1 >> time_stmp1;
			timestmp1 = time_stmp1 * 1000000;
		} else if (i == inode_loc) {
			stringstream ss1;

			ss1 << temp;
			ss1 >> inode1;						
		}
		i++;
	}
	*inode = inode1;
	*time_stmp = timestmp1;
}

void print_map(unordered_map<unsigned long long, vector<vector<unsigned long long> > >& Map1) {
	unordered_map<unsigned long long, vector<vector<unsigned long long> > >::iterator iter;
	unsigned long long inode;
	vector<vector<unsigned long long> > values;
	vector<unsigned long long> times;

	for (iter = Map1.begin(); iter != Map1.end(); iter++) {
		inode = iter->first;
		values = iter->second;
		cout<<"Inode : "<<inode<<":\n";
		for (int i = 0; i < values.size(); i++) {
			cout<< " list " << (i + 1)<< " : ";
			times = values[i];
			for (int j = 0; j < times.size(); j++)
				cout<< times[j] << ", ";
			cout<<"\n";
		}
	}
}

int main(int argc, char **argv) {

	if (argc != 2) {
		print_usage();
		return 0;
	}

	string STRING, outputfolder;
	int i;
	ifstream input;
	ofstream output;
	outputfolder = argv[1];
	string kernel_tracefile, stackFS_tracefile;

	kernel_tracefile = outputfolder + "/trace.out";
	stackFS_tracefile = outputfolder + "/trace_stackfs.log";

/*
 * Map1 : key is inode
 * value : list of vectors, 
 * Map[inode][0] V1 : list of vfs_read_start
 * Map[inode][1] V2 : list of fuse_read_iter_start
 * Map[inode][2] V3 : list of fuse_read_request_create
 * Map[inode][3] V6 : list of fuse_read_iter_end
 * Map[inode][4] V7 : list of vfs_read_end
 * */
	unordered_map<unsigned long long, vector<vector<unsigned long long> > > Map1; /* used for parsing trace.out */

/*
 * Map2 : key is inode
 * value : list of vectors,
 * Map[inode][0] V4 : list of StackFS_read_start
 * Map[inode][1] V5 : list of StackFS_read_end
 * */	
	unordered_map<unsigned long long, vector<vector<unsigned long long> > > Map2; /* used for parsing trace_stackfs.log */

	/* start reading the trace.out */
	input.open(kernel_tracefile.c_str());
	if (input) {
		getline(input, STRING);
		while (!input.eof()) {
			i = 0;
			if (STRING.find("vfs_read_start:") != string::npos) {
				/* filebench-14516 [002] ....  4848.804447: vfs_read_start: VFS read start on inode : 39723088 */
				unsigned long long inode, timestmp;

				get_inode_time(STRING, 12, 3, 11, &inode, &timestmp);
				//cout<<"inode : "<<inode<<" time stmp : "<< timestmp <<"\n";
				if (Map1.count(inode))
					(Map1[inode][0]).push_back(timestmp);
				else {
					vector<vector<unsigned long long> > values;
					vector<unsigned long long> times;

					times.push_back(0);
					values.push_back(times); /* V1 */
					values.push_back(times); /* V2 */
					values.push_back(times); /* V3 */
					values.push_back(times); /* V6 */
					values.push_back(times); /* V7 */

					values[0].push_back(timestmp);
					Map1[inode] = values;	
				}
			} else if (STRING.find("fuse_read_iter_start:") != string::npos) {
				/* filebench-14516 [002] ....  4848.804459: fuse_read_iter_start: Fuse Read Iter start on inode : 39723088 */
				unsigned long long inode, timestmp;
			
				get_inode_time(STRING, 13, 3, 12, &inode, &timestmp);
				(Map1[inode][1]).push_back(timestmp);
			} else if (STRING.find("fuse_read_request_create:") != string::npos) {
				/* filebench-11372 [003] ....   561.870696: fuse_read_request_create: Fuse Read Request created on inode : 31419152 */
				unsigned long long inode, timestmp;

				get_inode_time(STRING, 13, 3, 12, &inode, &timestmp);
				(Map1[inode][2]).push_back(timestmp);
			} else if (STRING.find("fuse_read_iter_end:") != string::npos) {
				/* filebench-14516 [003] ....  4848.813384: fuse_read_iter_end: Fuse Read Iter end on inode : 39723088 */
				unsigned long long inode, timestmp;

				get_inode_time(STRING, 13, 3, 12, &inode, &timestmp);
				(Map1[inode][3]).push_back(timestmp);
			} else if (STRING.find("vfs_read_end:") != string::npos) {
				/* filebench-14516 [003] ....  4848.813386: vfs_read_end: VFS read end on inode : 39723088 */
				unsigned long long inode, timestmp;

				get_inode_time(STRING, 12, 3, 11, &inode, &timestmp);
				if ( Map1[inode][1].size() != Map1[inode][2].size() ) {
					Map1[inode][0].pop_back();
					Map1[inode][1].pop_back();
					Map1[inode][3].pop_back();
				} else
					(Map1[inode][4]).push_back(timestmp);
			}
			getline(input, STRING);
		}
	} else {
		cout << "Error opening the file : "<< kernel_tracefile <<"\n";
		return -1;
	}
	input.close();
	//print_map(Map1);
	
	input.open(stackFS_tracefile.c_str());
	if (input) {
		getline(input, STRING);
		while (!input.eof()) {
			if (STRING.find("StackFS Read start") != string::npos) {
 				/* Time : 1479518043328373 Pid : 14506 Tid : 14506 StackFS Read start on inode : 39723088 */
				stringstream ss;
				string temp;
				unsigned long long int inode, timestmp;
				i = 0;
		
				ss << STRING;
				while (i < 16) {
					ss >> temp;	
					if (i == 2) {
						stringstream ss1;
						ss1 << temp;
						ss1 >> timestmp;
					} else if (i == 15) {
						stringstream ss1;
						ss1 << temp;
						ss1 >> inode;	
					}
					i++;
				}
				if (Map2.count(inode)) {
					(Map2[inode][0]).push_back(timestmp);
				} else {
					vector<vector<unsigned long long int> > values;
					vector<unsigned long long int> times;
				
					times.push_back(0);
					values.push_back(times);
					values.push_back(times);
					Map2[inode] = values;
					(Map2[inode][0]).push_back(timestmp);	
				}
			} else if (STRING.find("StackFS Read end") != string::npos) {
 				/* Time : 1479518043337181 Pid : 14506 Tid : 14506 StackFS Read end on inode : 39723088 */
				stringstream ss;
				string temp;
				unsigned long long int inode, timestmp;
				i = 0;
		
				ss << STRING;
				while (i < 16) {
					ss >> temp;	
					if (i == 2) {
						stringstream ss1;
						ss1 << temp;
						ss1 >> timestmp;
					} else if (i == 15) {
						stringstream ss1;
						ss1 << temp;
						ss1 >> inode;	
					}
					i++;
				}
				(Map2[inode][1]).push_back(timestmp);
			}
			getline(input, STRING);
		}
	} else {
		cout<<"Error opening the file : "<< stackFS_tracefile <<"\n";
		return -1;
	}
	input.close();
	//print_map(Map2);
	
	unordered_map<unsigned long long, vector<vector<unsigned long long> > >::iterator iter1;
	unordered_map<unsigned long long, vector<vector<unsigned long long> > > Map3;
	unsigned long long int inode;

	for (iter1 = Map1.begin(); iter1 != Map1.end(); iter1++) {
		vector<unsigned long long int> V1, V2, V3, V4, V5, V6, V7;
		vector<unsigned long long int> B1, B2, B3, B4, B5, B6;
		vector<vector<unsigned long long int> > values;
		unsigned long long int diff1, diff2, diff3, diff4, diff5, diff6, diff7;
		long long int tempdiff1;

		inode = iter1->first;
		V1 = (iter1->second)[0];
		V2 = (iter1->second)[1];
		V3 = (iter1->second)[2];
		V4 = Map2[inode][0];
		V5 = Map2[inode][1];
		V6 = (iter1->second)[3];
		V7 = (iter1->second)[4];

		for (int i = 1; i < V1.size(); i++) {
			diff1 = (V2[i] - V1[i]); /* fuse_read_iter_strt - vfs_read_strt (msecs) */
			diff2 = (V3[i] - V2[i]); /* fuse_read_request_create - fuse_read_iter_strt (msecs) */
			diff4 = (V5[i] - V4[i]); /* stackFS_read_end - stackFS_read_strt (msecs) */
			tempdiff1 = (V6[i] - V3[i]); 
			//cout<<"tempdiff 1 : "<<tempdiff1<<" diff 4 : "<<diff4<<"\n";
			tempdiff1 = tempdiff1 - diff4;
			if ( tempdiff1 > 0) {
				diff3 = 0.95 * tempdiff1; /* my assunmption */
				diff5 = 0.05 * tempdiff1;
				diff6 = (V7[i] - V6[i]); /* vfs_read_end - fuse_read_iter_end (msecs) */
				//cout<<"diff 2 : "<<diff2<<"\n";
				B1.push_back(diff1);
				B2.push_back(diff2);
				B3.push_back(diff3);
				B4.push_back(diff4);
				B5.push_back(diff5);
				B6.push_back(diff6);
			}
		}
		values.push_back(B1);
		values.push_back(B2);
		values.push_back(B3);
		values.push_back(B4);
		values.push_back(B5);
		values.push_back(B6);
		Map3[inode] = values;
	}
	//print_map(Map3);

	string outputfilename;
	vector<unsigned long long int> B1, B2, B3, B4, B5, B6;
	unsigned long long int diff1, diff2, diff3, diff4, diff5, diff6;
	double bar1, bar2, bar3, bar4, bar5, bar6;

	outputfilename = outputfolder + "/profile-points-stats.txt";
	system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
	for (iter1 = Map3.begin(); iter1 != Map3.end(); iter1++) {
		B1 = (iter1->second)[0];
		B2 = (iter1->second)[1];
		B3 = (iter1->second)[2];
		B4 = (iter1->second)[3];
		B5 = (iter1->second)[4];
		B6 = (iter1->second)[5];

		diff1 = diff2 = diff3 = diff4 = diff5 = diff6 = 0;

		for (int i = 0; i < B1.size(); i++)
			diff1 += B1[i];
		bar1 = diff1/(B1.size());

		for (int i = 0; i < B2.size(); i++)
			diff2 += B2[i];
		bar2 = diff2/(B2.size());

		for (int i = 0; i < B3.size(); i++)
			diff3 += B3[i];
		bar3 = diff3/(B3.size());

		for (int i = 0; i < B4.size(); i++)
			diff4 += B4[i];
		bar4 = diff4/(B4.size());

		for (int i = 0; i < B5.size(); i++)
			diff5 += B5[i];
		bar5 = diff5/(B5.size());

		for (int i = 0; i < B6.size(); i++)
			diff6 += B6[i];
		bar6 = diff6/(B6.size());

		output << bar1 << " " << bar2 << " " << bar3 << " " << bar4 << " " << bar5 << " " << bar6 << "\n";
	}
	output.close();
return 0;
}
