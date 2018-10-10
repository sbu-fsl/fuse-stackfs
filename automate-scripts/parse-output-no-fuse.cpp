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

static int str_cntxt = 0;

void print_usage() {
	cout<<"./parse-output-no-fuse <Folder containing files>\n";
}

void split_by_space(string given, vector<string>& input) {
	int i = 0, len, found;
	len = given.length();
	found = given.find(" ");
	while (found != string::npos) {
		input.push_back(given.substr(0, found));
		given = given.substr(found+1, len - found - 1);
		found = given.find(" ");
	}
	input.push_back(given);
}


void print_list(vector<string>& input) {
	for (int i=0; i < input.size(); i++)
		cout<<input[i]<<"\n";
}

int main(int argc, char *argv[]) {
	if (argc != 2) {
		print_usage();
		return 0;
	}
	string outputfilename, STRING1, outputfolder;
	ifstream input;
	ofstream output;
	outputfolder = argv[1];
	string filebench_out, cpu_stats_file, mem_stats_file, disk_stats_file;
	vector<string> temp;
	double tot_cpu, cpu_0, cpu_1, cpu_2, cpu_3, cpu_4, cpu_5, cpu_6, cpu_7; /* I know there are 8 cores */
	tot_cpu = cpu_0 = cpu_1 = cpu_2 = cpu_3 = cpu_4 = cpu_5 = cpu_6 = cpu_7 = 0;

	int iterations = 0;
	int i = 1;

	/*Input File Names*/
	filebench_out = outputfolder + "/filebench.out";
	cpu_stats_file = outputfolder + "/cpustats.txt";
//        mem_stats_file = outputfolder + "/memstats.txt";
//       disk_stats_file = outputfolder + "/diskstats.txt";

	/*Parsing Filebench stats*/
	string STRING;
	vector<string> throughput_list;
	input.open(filebench_out);
	if (input) {
//		cout<<"Opened filbenehc file\n";
		getline(input, STRING);
        	while(!input.eof()) {
      			if (STRING.find("Run took") != string::npos) {
				string num;
       				outputfilename = outputfolder + "/time.txt";
// 				cout<<"outputfile name : "<< outputfilename<<"\n";
        	       		output.open(outputfilename, std::ofstream::out);
				split_by_space(STRING, temp);
				num = temp[temp.size()-2];
                       		output << num<<"\n";
                        	output.close();
				temp.clear();
            		} else if (STRING.find("IO Summary:") != string::npos) {
				/* 21.043: IO Summary:  1026 ops 341.966 ops/s 0/341 rd/wr 341.3mb/s   2.2ms/op */
//                		outputfilename = outputfolder + "/throughput.txt";
//                		output.open(outputfilename, std::ofstream::out);
                  		istringstream s2(STRING);
				string num;
                        	int j = 0;
                        	while (j<10) {
                              		s2 >> num;
                       			j++;
                      		}
				throughput_list.push_back(num.substr(0, num.length()-4));
//                        	output << num.substr(0, num.length()-4)<<"\n";
//                        	output.close();
                	}
        		getline(input, STRING);
		}
		input.close();
	} else
		cout<<"Error in opeing file : "<<filebench_out<<"\n";
//	cout<<"throughput list size = "<<throughput_list.size()<<"\n";
	/* Remove first and last */
	double sum = 0;
	for (int i = 0; i < (throughput_list.size()); i++) {
		double num;
		istringstream s2(throughput_list[i]);
		
		s2 >> num;
		sum += num; 
	}
	outputfilename = outputfolder + "/throughput.txt";
	output.open(outputfilename, std::ofstream::out);
	output << (sum/(throughput_list.size())) <<"\n";
	output.close();
	/*parsing cpu stats*/
	input.open(cpu_stats_file);
	if (input) {
		getline(input, STRING);
		while(!input.eof()) {
			if (STRING.find("total") != string::npos) {
				stringstream ss;
				ss << STRING;
				string temp;
				double val;

				iterations++;
				ss >> temp;
				ss >> temp;
				stringstream ss_ss;
				ss_ss << temp;
				ss_ss >> val;
//				cout<<"String : "<<STRING<<" val : "<<val<<"\n";
				tot_cpu += val;
				/* Now read 8 lines one after the othrr (dirty hack) */
				/*line 0*/
				getline(input, STRING);
				stringstream ss0, ss_0;
                                ss0 << STRING;
                                ss0 >> temp;
                                ss0 >> temp;
				ss_0 << temp;
				ss_0 >> val;
                                cpu_0 += val;
				/* line 1*/
				getline(input, STRING);
				stringstream ss1, ss_1;
                                ss1 << STRING;
                                ss1 >> temp;
                                ss1 >> temp;
				ss_1 << temp;
				ss_1 >> val;
                                cpu_1 += val;
				/* line 2 */
				getline(input, STRING);
				stringstream ss2, ss_2;
                                ss2 << STRING;
                                ss2 >> temp;
                                ss2 >> temp;
				ss_2 << temp;
				ss_2 >> val;
                                cpu_2 += val;
				/* line 3 */
				getline(input, STRING);
				stringstream ss3, ss_3;
                                ss3 << STRING;
                                ss3 >> temp;
                                ss3 >> temp;
				ss_3 << temp;
				ss_3 >> val;
                                cpu_3 += val;
				/* line 4 */
				getline(input, STRING);
				stringstream ss4, ss_4;
                                ss4 << STRING;
                                ss4 >> temp;
                                ss4 >> temp;
				ss_4 << temp;
				ss_4 >> val;
                                cpu_4 += val;
				/* line 5 */
				getline(input, STRING);
				stringstream ss5, ss_5;
                                ss5 << STRING;
                                ss5 >> temp;
                                ss5 >> temp;
				ss_5 << temp;
				ss_5 >> val;
                                cpu_5 += val;
				/* line 6 */
				getline(input, STRING);
				stringstream ss6, ss_6;
                                ss6 << STRING;
                                ss6 >> temp;
                                ss6 >> temp;
				ss_6 << temp;
				ss_6 >> val;
                                cpu_6 += val;
				/* line 7 */
				getline(input, STRING);
				stringstream ss7, ss_7;
                                ss7 << STRING;
                                ss7 >> temp;
                                ss7 >> temp;
				ss_7 << temp;
				ss_7 >> val;
                                cpu_7 += val;

			}
			getline(input, STRING);
		}
	} else
		cout<<"Error in opeing file : "<<cpu_stats_file<<"\n";
	cout<<"tot_cpu : "<<tot_cpu<<"\n";
	cout<<"iterations : "<<iterations<<"\n";
	outputfilename = outputfolder + "/AvgCpuStats.txt";
	output.open(outputfilename, std::ofstream::out);
	output<<(tot_cpu/iterations)<<"\n";
	output<<(cpu_0/iterations)<<"\n";
	output<<(cpu_1/iterations)<<"\n";
	output<<(cpu_2/iterations)<<"\n";
	output<<(cpu_3/iterations)<<"\n";
	output<<(cpu_4/iterations)<<"\n";
	output<<(cpu_5/iterations)<<"\n";
	output<<(cpu_6/iterations)<<"\n";
	output<<(cpu_7/iterations)<<"\n";
	output.close();

/*        float user = 0.0, system = 0.0, iowait = 0.0, idle = 0.0;
        int counter = 0;
        outputfilename = outputfolder + "/AvgCpuStats.txt";
        input.open(cpu_stats_file);
        getline(input, STRING);
        while(!input.eof()) {
                if (STRING.find("avg-cpu:") != string::npos) {
                        counter++;
                        getline(input, STRING);
                        istringstream s2(STRING);
                        int j = 0;
                        while (j < 6) {
                                s2 >> num;
                                if (j == 0)
                                        user += stof(num);
                                else if (j == 2)
                                        system += stof(num);
                                else if (j == 3)
                                        iowait += stof(num);
                                else if (j == 5)
                                        idle += stof(num);
                                j++;
                        }
                }
                getline(input, STRING);
        }
        input.close();
        output.open(outputfilename, std::ofstream::out);
        output << (user/counter) <<"\n" << (system/counter) <<"\n" << (iowait/counter) << "\n" << (idle/counter)<<"\n";
        output.close(); */
	/*parsing disk stats*/
/*        float writereqs = 0.0, KBWritten = 0.0, AvgWriteWait = 0.0, utilisation = 0.0;
        counter = 0;
        outputfilename = outputfolder + "/AvgDiskStats.txt";
        input.open(disk_stats_file);
        getline(input, STRING);
        while(!input.eof()) {
                if (STRING.find("Device:") != string::npos) {
                        counter++;
                        getline(input, STRING);
                        istringstream s2(STRING);
                        int j = 0;
                        while (j < 14) {
                                s2 >> num;
                                if (j == 4) {
                                        writereqs += stof(num);
                                } else if (j == 6) {
                                        KBWritten += stof(num);
                                } else if (j == 11) {
                                        AvgWriteWait += stof(num);
                                } else if (j == 13) {
                                        utilisation += stof(num);
                                }
                                j++;
                        }
                }
                getline(input, STRING);
        }
        input.close();
        output.open(outputfilename, std::ofstream::out);
        output << (writereqs/counter) <<"\n" << (KBWritten/counter) <<"\n" << (AvgWriteWait/counter) << "\n" << (utilisation/counter)<<"\n";
        output.close(); */
	/*parsing memory stats*/
/*        float memTotal = 0.0, memFree = 0.0, buffers = 0.0, cached = 0.0, dirty = 0.0, cntxtSwts = 0.0, memUtil = 0.0;
        counter = 0;
        outputfilename = outputfolder + "/AvgMemStats.txt";
        input.open(mem_stats_file);
        getline(input, STRING);
        while(!input.eof()) {
                if (STRING.find("MemTotal:") != string::npos) {
                        counter++;
                        istringstream s1(STRING);
                        int j = 0;
                        while (j < 2) {
                                s1 >> num;
                                j++;
                        }
                        memTotal = stof(num); */
                        /*Mem Free Line*/
/*                        getline(input, STRING);
                        istringstream s2(STRING);
                        j = 0;
                        while (j < 2) {
                                s2 >> num;
                                j++;
                        }
                        memFree = stof(num); */
                        /*Leave MemAvailable Line*/
//                        getline(input, STRING);
                        /*Buffers Line*/
/*                        getline(input, STRING);
                        istringstream s3(STRING);
                        j = 0;
                        while (j < 2) {
                                s3 >> num;
                                j++;
                        }
                        buffers = stof(num); */
                        /*Cached Line*/
/*                        getline(input, STRING);
                        istringstream s4(STRING);
                        j = 0;
                        while (j < 2) {
                                s4 >> num;
                                j++;
                        }
                        cached = stof(num); */
                        /*Leave Swapped Cache Line*/
//                        getline(input, STRING);
			/*Dirty Line*/
/*                        getline(input, STRING);
                        istringstream s5(STRING);
                        j = 0;
                        while (j < 2) {
                                s5 >> num;
                                j++;
                        }
                        dirty += stof(num); */
                        /*Context Switches*/
/*                        getline(input, STRING);
                        istringstream s6(STRING);
                        j = 0;
                        while (j < 2) {
                                s6 >> num;
                                j++;
                        }
                        cntxtSwts = stof(num);
                        if (str_cntxt == 0)
                                str_cntxt = cntxtSwts;
                        memUtil += (memTotal - memFree - buffers - cached)/memTotal;

                }
                getline(input, STRING);
        }
        input.close();
        output.open(outputfilename, std::ofstream::out);
        output << (memUtil/counter)*100 <<"\n" << (dirty/counter) <<"\n" << (cntxtSwts - str_cntxt) << "\n";
        output.close(); */
	return 0;
}
