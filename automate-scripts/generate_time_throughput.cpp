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

#include<iostream>
#include<vector>
#include<fstream>
#include<sstream>
#include<string>
using namespace std;



int main() {
	string dir = "/Users/Bharath/Downloads/FUSE/raw_data/Stat-files-WRITEBACK/", STRING;
	ifstream input;
	ofstream output;
	for (int max_write = 32768; max_write <= 32768; max_write*=2) {
		for (int iteration=32768; iteration <= 32768; iteration*=2) {
			string filename = dir + "Stat-files-"+to_string(max_write)+"-"+to_string(iteration)+"-Final/filebench.out", outputfilename, num;
			input.open(filename);
			getline(input, STRING);
			while(!input.eof()) {
				if (STRING.find("Run took") != string::npos) {
					outputfilename = dir + "Stat-files-"+to_string(max_write)+"-"+to_string(iteration)+"-Final/time.txt";
					output.open(outputfilename, std::ofstream::out);
					istringstream s2(STRING);
					int j = 0;
					while (j<4) {
						s2 >> num;
						j++;
					}
					output << num<<"\n";
					output.close();
				} else if (STRING.find("write-file") != string::npos) {
					outputfilename = dir + "Stat-files-"+to_string(max_write)+"-"+to_string(iteration)+"-Final/throughput.txt";
					output.open(outputfilename, std::ofstream::out);
                                        istringstream s2(STRING);
                                        int j = 0;
                                        while (j<4) {
                                                s2 >> num;
                                                j++;
                                        }
                                        output << num.substr(0, num.length()-4)<<"\n";
                                        output.close();
				}
				getline(input, STRING);
			}
			input.close();
		}
	}
}
