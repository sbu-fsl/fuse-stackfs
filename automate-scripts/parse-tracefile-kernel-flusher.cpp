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
#include <cmath>
using namespace std;

void print_usage() {
        cout<<"./parse-tracefile-kernel-flusher <Folder containing trace file>\n";
}

int main(int argc, char **argv) {

        if (argc != 2) {
                print_usage();
                return 0;
        }

	string STRING, outputfolder;
        int i;
	int max_size = -1;
	int iteration = 0;
        ifstream input;
        ofstream output;

        outputfolder = argv[1];

	string pause_stats_file, tracefile, temp;
        string outputfilename;

        tracefile = outputfolder + "/trace.out";

	vector<int> kernel_flush_pages;
	vector<vector<int> > write_pages;
	vector<int> write_page;
	
	input.open(tracefile.c_str());
	if (input) {
		getline(input, STRING);
start:
		while (!input.eof()) {
			if (STRING.find("writeback_pages_before_written:") != string::npos) { /* Flusher Start*/
				iteration++; /* Flusher Iteration */
//				cout<<"Iteration count : "<<iteration<<"\n";
				getline(input, STRING);
				while (true) {	
					/* kworker/u64:3-379   [001] ....  3050.958450: writeback_single_inode: bdi 0:40: ino=11 state=I_DIRTY_SYNC|I_DIRTY_PAGES|I_SYNC dirtied_when=4297716349 age=0 index=0 to_write=13312 wrote=860 */					
					if (STRING.find("writeback_single_inode:") != string::npos) {
						stringstream ss;
                                        	ss << STRING;
                                        	string temp;
                                        	int val;
						i = 0;

						while (i < 14) {
							ss >> temp;
							i++;
						}
						/* Now temp has wrote=860 */
						temp = temp.substr(temp.find("=") + 1, temp.length());
						stringstream ss1;
						ss1 << temp;
						ss1 >> val;
						write_page.push_back(val);
						getline(input, STRING);
					} else 	if (STRING.find("writeback_pages_written:") != string::npos) {
						/* kworker/u64:3-379   [001] ....  3050.958467: writeback_pages_written: 0 */
						stringstream ss;
                                                ss << STRING;
                                                string temp;
                                                int val;
						i = 0;

						while (i < 6) {
							ss >> temp;
							i++;
						}
						stringstream ss1;
                                                ss1 << temp;
                                                ss1 >> val;
						kernel_flush_pages.push_back(val);
						write_pages.push_back(write_page);
						max_size = max(max_size, (int)write_page.size());
						write_page.clear();
						getline(input, STRING);
						goto start;
					} else
						getline(input, STRING);
				}
			}
			getline(input, STRING);
		}
	} else
                cout<<"No trace file\n";

//	cout<<"Iteration count : "<<iteration<<"\n";
//	cout<<"Max size obtained : "<<max_size<<"\n";

	outputfilename = outputfolder + "/wbc_writepages_kernel.txt";
        system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
	int temp_size;
	for (int i = 0; i < iteration; i++) {
		write_page = write_pages[i];
		temp_size = write_page.size();
		for (int j = 0; j < temp_size; j++)
			output<<write_page[j]<<"\n";
		/* Fill the remaining places with 0's for plotting */
		for (int j = 0; j < (max_size - temp_size); j++)
			(write_pages[i]).push_back(0);
	}
	output.close();

	outputfilename = outputfolder + "/kernel_flusher_thread_data.txt";
        system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
	for (int i = 0; i < iteration; i++) {
		output<<kernel_flush_pages[i]<<" ";
		write_page = write_pages[i];
		for (int j = 0; j < write_page.size(); j++)
			output<<write_page[j]<<" ";
		output<<"\n";
	}
	output.close();
return 0;
}
