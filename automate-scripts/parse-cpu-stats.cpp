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
#include <unistd.h>
#include <stdlib.h>
#include <unordered_map>

using namespace std;

/* parse the cpu stats which were collected during the 
 * filebench workload and calculate the cpu utilisation
 * using the below formula.
 * */

/* Following will be contents of the /proc/stat 
 *
 *  	   user    nice   system   idle      iowait    irq   softirq  steal  guest  guest_nice
 *  cpu   74608    2520   24433   1117073      6176   4054     0        0      0      0
 *
 * PrevIdle = previdle + previowait
 * Idle = idle + iowait
 *
 * PrevNonIdle = prevuser + prevnice + prevsystem + previrq + prevsoftirq + prevsteal
 * NonIdle = user + nice + system + irq + softirq + steal
 *
 * PrevTotal = PrevIdle + PrevNonIdle
 * Total = Idle + NonIdle
 *
 * # differentiate: actual value minus the previous one
 * totald = Total - PrevTotal
 * idled = Idle - PrevIdle
 *
 * CPU_Percentage = (totald - idled)/totald
 *
 * */

void print_usage() {
	cout<<"./parse-cpu-stats <Folder containing files>\n";
}

int main(int argc, char *argv[]) {
	if (argc != 2) {
		print_usage();
		return 0;
	}

	string outputfilename, STRING, outputfolder;
	long userHZ;
	vector<double> cpu_util, cpu_user, cpu_nice, cpu_system;
	vector<double> cpu_tot_idle, cpu_idle, cpu_iowait;
	vector<double> user_jiffies, system_jiffies;
	string cpu_stats_file;
	ifstream input;
	ofstream output;
	outputfolder = argv[1];

	userHZ = sysconf(_SC_CLK_TCK);
	cpu_stats_file =  outputfolder + "/cpustats.txt";

	input.open(cpu_stats_file);
	if (input) {
		bool started = false;
		bool first = false;
		string junk;
		unsigned long prev_idle, prev_iowait, prev_user, prev_nice, prev_system, prev_irq, prev_softirq, prev_steal;
		unsigned long curr_idle, curr_iowait, curr_user, curr_nice, curr_system, curr_irq, curr_softirq, curr_steal;
		double prev_tot_idle /* (prev_idle + prev_iowait) */, prev_tot_nonidle /* (prev_user + prev_nice + prev_system + prev_irq + prev_softirq + prev_steal ) */ , prev_tot /* (prev_tot_idle + prev_tot_nonidle) */;
		double curr_tot_idle /* (curr_idle + curr_iowait) */, curr_tot_nonidle /* (curr_user + curr_nice + curr_system + curr_irq + curr_softirq + curr_steal ) */ , curr_tot /* (curr_tot_idle + curr_tot_nonidle) */;
		double tot_diff /* (curr_tot - prev_tot ) */, tot_idle_diff /* (curr_tot_idle - prev_tot_idle) */ ;
		double cpu_per /* (tot_diff - tot_idle_diff) / tot_diff */ ;
		double user_per /* (curr_user - prev_user) / tot_diff */  ;
		double nice_per /* (curr_nice - prev_nice) / tot_diff */  ;
		double sys_per  /* (curr_system - prev_system) / tot_diff */;

		double tot_idle_per /* (tot_idle_diff) / tot_diff */ ;
		double idle_per /* (curr_idle - prev_idle) / tot_diff */ ;
		double iowait_per /* (curr_iowait - prev_iowait) / tot_diff */;


		getline(input, STRING);
		while (!input.eof()) {
			/* This is when actual workload starts (after the prealloc, if any) */
			if (!started && STRING.find("started") != string::npos)
				started = true;
			/* Only considering the cpu and not any cpuN*/
			if (started && STRING.find("cpu ") != string::npos) {
				
				/*       usr  nce   sys    idle    iow   irq  sirq  stl  gst  gst_nce */
				/* cpu  2622   0   13579 18649055 69663   0    74    0    0     0     */
				if (!first) {
					/* fill the prev stats*/
					stringstream ss;

					ss << STRING;

					ss >> junk; /* ``cpu '' word*/
					ss >> prev_user;
					ss >> prev_nice;
					ss >> prev_system;
					ss >> prev_idle;
					ss >> prev_iowait;
					ss >> prev_irq;
					ss >> prev_softirq;
					ss >> prev_steal;
					
					first = true;
				} else {
					/* fill the curr stats */
					stringstream ss;

					ss << STRING;

					ss >> junk; /* ``cpu '' word */
					ss >> curr_user;
					ss >> curr_nice;
					ss >> curr_system;
					ss >> curr_idle;
					ss >> curr_iowait;
					ss >> curr_irq;
					ss >> curr_softirq;
					ss >> curr_steal;

					prev_tot_idle = prev_idle + prev_iowait;
					curr_tot_idle = curr_idle + curr_iowait;

					prev_tot_nonidle = prev_user + prev_nice + prev_system + prev_irq + prev_softirq + prev_steal;
					curr_tot_nonidle = curr_user + curr_nice + curr_system + curr_irq + curr_softirq + curr_steal;

					prev_tot = prev_tot_idle + prev_tot_nonidle;
					curr_tot = curr_tot_idle + curr_tot_nonidle;

					tot_diff = curr_tot - prev_tot;
					tot_idle_diff = curr_tot_idle - prev_tot_idle;

					cpu_per = ((tot_diff - tot_idle_diff) / tot_diff) * 100;
					user_per = ((curr_user - prev_user) / tot_diff) * 100;
					nice_per = ((curr_nice - prev_nice) / tot_diff) * 100;
					sys_per = ((curr_system - prev_system) / tot_diff) * 100;

					tot_idle_per = (tot_idle_diff / tot_diff) * 100;
					idle_per = ((curr_idle - prev_idle) / tot_diff) * 100;
					iowait_per = ((curr_iowait - prev_iowait) / tot_diff) * 100;
				
					cpu_util.push_back(cpu_per);
					cpu_user.push_back(user_per);
					cpu_nice.push_back(nice_per);
					cpu_system.push_back(sys_per);

					cpu_tot_idle.push_back(tot_idle_per);
					cpu_idle.push_back(idle_per);
					cpu_iowait.push_back(iowait_per);
					/* add up the jiffies */
					user_jiffies.push_back( (curr_user - prev_user) + (curr_nice - prev_nice));
					system_jiffies.push_back(curr_system - prev_system);
					/* Assign curr stats as the prev stats for next iteration */
					prev_user = curr_user;
					prev_nice = curr_nice;
					prev_system = curr_system;
					prev_idle = curr_idle;
					prev_iowait = curr_iowait;
					prev_irq = curr_irq;
					prev_softirq = curr_softirq;
					prev_steal = curr_steal;
				}
			}
			getline(input, STRING);
		}
		input.close();
	} else
		cout<<"Error in opeing file : "<<cpu_stats_file<<"\n";

	/* cpu_utilisation.txt : tot_cpu_util : user : nice : system */
	outputfilename = outputfolder + "/cpu_utilisation.txt";
	output.open(outputfilename, std::ofstream::out);
	for (int i = 0; i < cpu_util.size(); i++)
		output << cpu_util[i] <<"	"<<cpu_user[i]<<"	"<<cpu_nice[i]<<"	"<<cpu_system[i]<<"\n";
//	for (int i = 0; i < cpu_util.size(); i++) {
//		cout<<"CPU util : "<<cpu_util[i] <<" user : "<<cpu_user[i]<<" nice : "<<cpu_nice[i]<<" system : "<<cpu_system[i]<<"\n";	
//		cout<<"CPU idle : "<<cpu_tot_idle[i]<<" idle : "<<cpu_idle[i]<<" iowait : "<<cpu_iowait[i]<<"\n";
//	}
	output.close();

	/* cpu_user_system_secs.txt : user secs : system secs  */
	outputfilename = outputfolder + "/cpu_user_system_secs.txt";
	output.open(outputfilename, std::ofstream::out);
	for (int i = 0; i < user_jiffies.size(); i++)
		output << (user_jiffies[i]/userHZ) <<"	"<< (system_jiffies[i]/userHZ)<<"\n";
	output.close();
	/* cpu_idle.txt : tot_idle : idle : iowait */
	outputfilename = outputfolder + "/cpu_idle.txt";
	output.open(outputfilename, std::ofstream::out);
	for (int i = 0; i < cpu_tot_idle.size(); i++)
		output << cpu_tot_idle[i]<<"	"<<cpu_idle[i]<<"	"<<cpu_iowait[i]<<"\n";
	output.close();

return 0;
}

