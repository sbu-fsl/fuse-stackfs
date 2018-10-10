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
	cout<<"./parse-output <Folder containing files>\n";
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

unordered_map<int, string> Req_Map;

void initialise_Req_Map() {
	Req_Map[1] = "FUSE_LOOKUP";
	Req_Map[2] = "FUSE_FORGET";
	Req_Map[3] = "FUSE_GETATTR";
	Req_Map[4] = "FUSE_SETATTR";
	Req_Map[5] = "FUSE_READLINK";
	Req_Map[6] = "FUSE_SYMLINK";
	/*7 missing*/
	Req_Map[8] = "FUSE_MKNOD";
	Req_Map[9] = "FUSE_MKDIR";
	Req_Map[10] = "FUSE_UNLINK";
	Req_Map[11] = "FUSE_RMDIR";
	Req_Map[12] = "FUSE_RENAME";
	Req_Map[13] = "FUSE_LINK";
	Req_Map[14] = "FUSE_OPEN";
	Req_Map[15] = "FUSE_READ";
	Req_Map[16] = "FUSE_WRITE";
	Req_Map[17] = "FUSE_STATFS";
	Req_Map[18] = "FUSE_RELEASE";
	/*19 missing*/
	Req_Map[20] = "FUSE_FSYNC";
	Req_Map[21] = "FUSE_SETXATTR";
	Req_Map[22] = "FUSE_GETXATTR";
	Req_Map[23] = "FUSE_LISTXATTR";
	Req_Map[24] = "FUSE_REMOVEXATTR";
	Req_Map[25] = "FUSE_FLUSH";
	Req_Map[26] = "FUSE_INIT";
	Req_Map[27] = "FUSE_OPENDIR";
	Req_Map[28] = "FUSE_READDIR";
	Req_Map[29] = "FUSE_RELEASEDIR";
	Req_Map[30] = "FUSE_FSYNCDIR";
	Req_Map[31] = "FUSE_GETLK";
	Req_Map[32] = "FUSE_SETLK";
	Req_Map[33] = "FUSE_SETLKW";
	Req_Map[34] = "FUSE_ACCESS";
	Req_Map[35] = "FUSE_CREATE";
	Req_Map[36] = "FUSE_INTERRUPT";
	Req_Map[37] = "FUSE_BMAP";
	Req_Map[38] = "FUSE_DESTROY";
	Req_Map[39] = "FUSE_IOCTL";
	Req_Map[40] = "FUSE_POLL";
	Req_Map[41] = "FUSE_NOTIFY_REPLY";
	Req_Map[42] = "FUSE_BATCH_FORGET";
	Req_Map[43] = "FUSE_FALLOCATE";
	Req_Map[44] = "FUSE_READDIRPLUS";
	Req_Map[45] = "FUSE_RENAME2";
}

string get_req_type(int type) {
	return Req_Map[type];
}


int main(int argc, char *argv[]) {
	if (argc != 2) {
		print_usage();
		return 0;
	}
	string outputfilename, STRING1, outputfolder;
	ifstream input;
	/*33 buckets but 34th is for total count in that request type*/
	unsigned long long int background[46][34], pending[46][34], processing[46][34], user_processing[46][34]; 
	outputfolder = argv[1];
//	std::string::size_type sz;
	string kernel_bg, kernel_pending, kernel_processing, user_proc_file, filebench_out, cpu_stats_file, mem_stats_file, disk_stats_file;
	vector<string> temp;
	int i = 1;

	/*Input File Names*/
	kernel_bg = outputfolder + "/background_queue_requests_timings";
	kernel_pending = outputfolder + "/pending_queue_requests_timings";
	kernel_processing = outputfolder + "/processing_queue_requests_timings";
	user_proc_file = outputfolder + "/user_stats.txt";
	filebench_out = outputfolder + "/filebench.out";
	cpu_stats_file = outputfolder + "/cpustats.txt";
	mem_stats_file = outputfolder + "/memstats.txt";
	disk_stats_file = outputfolder + "/diskstats.txt";

	initialise_Req_Map();

	/*parsing kernel background queue statastics*/
	input.open(kernel_bg.c_str());
	if (input) {
    		getline(input,STRING1);
	    	while(!input.eof()) {
			unsigned long long count = 0, var;
			split_by_space(STRING1, temp);
			for (int j = 0;j < temp.size();j++) {
				var = atoi(temp[j].c_str());
				count += var;
				background[i][j] = var;
			}
			background[i][33] = count;
			temp.clear();
			getline(input,STRING1);
			i++;
   	 	}
    		input.close();
	}
	/*parsing kernel pending queue statastics*/
	i = 1;
	temp.clear();
        input.open(kernel_pending.c_str());
	if (input) {
        	getline(input,STRING1);
        	while(!input.eof()) {
			unsigned long long count = 0, var;
        	        split_by_space(STRING1, temp);
        	        for (int j = 0;j < temp.size();j++) {
				var = atoi(temp[j].c_str());
				count += var;
        	                pending[i][j] = var;
			}
			pending[i][33] = count;
        	        temp.clear();
               	 	getline(input,STRING1);
                	i++;
        	}
        	input.close();
	}
	/*parsing kernel processing queue statistics*/
	i = 1;
        temp.clear();
        input.open(kernel_processing.c_str());
	if (input) {
        	getline(input,STRING1);
        	while(!input.eof()) {
			unsigned long long count = 0, var;
                	split_by_space(STRING1, temp);
                	for (int j = 0;j < temp.size();j++) {
				var = atoi(temp[j].c_str());
				count += var;
                        	processing[i][j] = var;
			}
			processing[i][33] = count;
                	temp.clear();
                	getline(input,STRING1);
                	i++;
        	}
        	input.close();
	}
	/*parsing user processing queue statistics*/
	i = 1;
        temp.clear();
        input.open(user_proc_file.c_str());
	if (input) {
		getline(input,STRING1);
        	while(!input.eof()) {
			unsigned long long count = 0, var;
                	split_by_space(STRING1, temp);
                	for (int j = 0;j < temp.size();j++) {
				var = atoi(temp[j].c_str());
				count += var;
                        	user_processing[i][j] = var;
			}
			user_processing[i][33] = count;
               		temp.clear();
                	getline(input,STRING1);
                	i++;
        	}
        	input.close();
	}
	/*generate output file containg only request types and their count in each queue*/
	outputfilename = outputfolder+"/request_type_count.txt";
	string dist_outputfilename, Req_types;
	ofstream output, output1, output2;
	Req_types = outputfolder+"/different_request_types.txt";
	system(("rm -rf "+Req_types).c_str());
	system(("rm -rf "+outputfilename).c_str());
	output.open(outputfilename, std::ofstream::out|std::ofstream::app);
	output2.open(Req_types, std::ofstream::out|std::ofstream::app);
	for (int i = 1; i <= 45; i++) {
		if (background[i][33] > 0 || pending[i][33] > 0 || processing[i][33] > 0 || user_processing[i][33] > 0) {
			output<<"Request Type			: "<<get_req_type(i)<<"\n";
			output<<"Background queue count		: "<<background[i][33]<<"\n";
			output<<"Pending queue count		: "<<pending[i][33]<<"\n";
			output<<"Processing queue count		: "<<processing[i][33]<<"\n";
			output<<"User Processing queue count	: "<<user_processing[i][33]<<"\n";
			output<<"========================================================\n";

			/*Generate the request type*/
			output2<<get_req_type(i)<<"\n";
			/*Generate Individual Request type background queue distribution*/
			dist_outputfilename = outputfolder + "/" + get_req_type(i) + "_background_distribution.txt";
			system(("rm -rf "+ dist_outputfilename).c_str());
			output1.open(dist_outputfilename, std::ofstream::out|std::ofstream::app);
			for (int j = 0; j < 34; j++)
				output1<<background[i][j]<<"\n";
			output1.close();
			/*Generate Individual Request type pending queue distribution*/
			dist_outputfilename = outputfolder + "/" + get_req_type(i) + "_pending_distribution.txt";
                        system(("rm -rf "+ dist_outputfilename).c_str());
                        output1.open(dist_outputfilename, std::ofstream::out|std::ofstream::app);
                        for (int j = 0; j < 34; j++)
                                output1<<pending[i][j]<<"\n";
                        output1.close();
			/*Generate Individual Request type processing queue distribution*/
			dist_outputfilename = outputfolder + "/" + get_req_type(i) + "_processing_distribution.txt";
                        system(("rm -rf "+ dist_outputfilename).c_str());
                        output1.open(dist_outputfilename, std::ofstream::out|std::ofstream::app);
                        for (int j = 0; j < 34; j++)
                                output1<<processing[i][j]<<"\n";
                        output1.close();
			/*Generate Individual Request type user processing queue distribution*/
                        dist_outputfilename = outputfolder + "/" + get_req_type(i) + "_user_processing_distribution.txt";
                        system(("rm -rf "+ dist_outputfilename).c_str());
                        output1.open(dist_outputfilename, std::ofstream::out|std::ofstream::app);
                        for (int j = 0; j < 34; j++)
                                output1<<user_processing[i][j]<<"\n";
                        output1.close();
		}
	}
	output2.close();
	output.close();
	/*Parsing Filebench stats*/
	string STRING, num;
//	cout<<"File bench file : "<<filebench_out<<"\n";
	input.open(filebench_out);
	if (input) {
		getline(input, STRING);
        	while(!input.eof()) {
      			if (STRING.find("Run took") != string::npos) {
       				outputfilename = outputfolder + "/time.txt";
                		output.open(outputfilename, std::ofstream::out);
				split_by_space(STRING, temp);
//				print_list(temp);
				num = temp[temp.size()-2];
                       		output << num<<"\n";
                        	output.close();
				temp.clear();
            		} else if (STRING.find("write-file") != string::npos) {
                		outputfilename = outputfolder + "/throughput.txt";
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
	/*parsing cpu stats*/
	double tot_cpu, cpu_0, cpu_1, cpu_2, cpu_3, cpu_4, cpu_5, cpu_6, cpu_7; /* I know there are 8 cores */
        tot_cpu = cpu_0 = cpu_1 = cpu_2 = cpu_3 = cpu_4 = cpu_5 = cpu_6 = cpu_7 = 0;
	int iterations = 0;
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
//                              cout<<"String : "<<STRING<<" val : "<<val<<"\n";
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

/*	float user = 0.0, system = 0.0, iowait = 0.0, idle = 0.0;
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
        output.close();	
*/	/*parsing disk stats*/
/*	float writereqs = 0.0, KBWritten = 0.0, AvgWriteWait = 0.0, utilisation = 0.0;
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
        output.close();
*/	/*parsing memory stats*/
/*	float memTotal = 0.0, memFree = 0.0, buffers = 0.0, cached = 0.0, dirty = 0.0, cntxtSwts = 0.0, memUtil = 0.0;
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
                        memTotal = stof(num);
*/                        /*Mem Free Line*/
/*                        getline(input, STRING);
                        istringstream s2(STRING);
                        j = 0;
                        while (j < 2) {
                                s2 >> num;
                                j++;
                        }
                        memFree = stof(num);
*/                        /*Leave MemAvailable Line*/
//                        getline(input, STRING);
                        /*Buffers Line*/
/*                        getline(input, STRING);
                        istringstream s3(STRING);
                        j = 0;
                        while (j < 2) {
                                s3 >> num;
                                j++;
                        }
                        buffers = stof(num);
*/                        /*Cached Line*/
/*                        getline(input, STRING);
                        istringstream s4(STRING);
                        j = 0;
                        while (j < 2) {
                                s4 >> num;
                                j++;
                        }
                        cached = stof(num);
*/                        /*Leave Swapped Cache Line*/
//                        getline(input, STRING);
                        /*Dirty Line*/
/*                        getline(input, STRING);
                        istringstream s5(STRING);
                        j = 0;
                        while (j < 2) {
                                s5 >> num;
                                j++;
                        }
                        dirty += stof(num);
*/                        /*Context Switches*/
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
