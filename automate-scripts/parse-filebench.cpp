#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <stdlib.h>
#include <unordered_map>

using namespace std;

/* Parses the filebench.out and parses the ops/sec and 
 * throughput, time took  numbers and places them in 
 * the same folder.
 * */

void print_usage() {
	cout<<"./parse-filebench <Folder containing files>\n";
}

int main(int argc, char *argv[]) {

	if (argc != 2) {
		print_usage();
		return 0;
	}

	string outputfilename, STRING1, outputfolder;
	string filebench_out;
	ifstream input;
	ofstream output;
	outputfolder = argv[1];

	filebench_out =  outputfolder + "/filebench.out";

	string STRING;
	vector<string> throughput_list;
	vector<string> ops_sec_list;

	input.open(filebench_out);
	if (input) {
		getline(input, STRING);
		while(!input.eof()) {
			if (STRING.find("Run took") != string::npos) {
				/* parse how much time took for the workload*/
				/* 822.449: Run took 410 seconds... */
				string num;
				outputfilename = outputfolder + "/time.txt";
				stringstream ss;
	
				ss << STRING;
				int j = 0;
				while (j < 4) {
					ss >> num;
					j++;
				}
				output.open(outputfilename, std::ofstream::out);
				output << num<<"\n";
				output.close();
			} else if (STRING.find("IO Summary:") != string::npos) {
				/* parse the ops/sec and throughput numbers for the workload*/
				/* 752.437: IO Summary: 375616 ops 37553.237 ops/s 37553/0 rd/wr 146.7mb/s   0.0ms/op */
				string temp;
				stringstream ss;

				ss << STRING;
				int j = 0;
				while (j < 10) {
					ss >> temp;
					if (j == 5)
						ops_sec_list.push_back(temp);
					else if (j == 9) {
						/* remove mb/s from the throughput string */
						throughput_list.push_back(temp.substr(0, temp.size()-4));
					}
					j++;
				}
			}
			getline(input, STRING);
		}
		input.close();
	} else
		cout<<"Error in opeing file : "<<filebench_out<<"\n";

	outputfilename = outputfolder + "/ops_sec.txt";
	output.open(outputfilename, std::ofstream::out);
	for (int i = 0; i < ops_sec_list.size(); i++)
		output << ops_sec_list[i] << "\n";
	output.close();
	
	outputfilename = outputfolder + "/throughput.txt";
	output.open(outputfilename, std::ofstream::out);
	for (int i = 0; i < throughput_list.size(); i++)
		output << throughput_list[i] << "\n";
	output.close();
}
