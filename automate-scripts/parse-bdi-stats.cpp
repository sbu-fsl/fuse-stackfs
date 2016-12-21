#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <stdlib.h>

using namespace std;

void print_usage() {
	cout<<"./parse-bdi-stats <Folder containing files>\n";
}

int main(int argc, char **argv) {
	if (argc != 2) {
		print_usage();
		return 0;
	}
	string STRING, outputfolder;
	ifstream input;
	ofstream output;
	outputfolder = argv[1];
	string bdi_stats_file, mem_stats_file, temp;
	string outputfilename;

	bdi_stats_file = outputfolder + "/bdi-stats.txt";
	mem_stats_file = outputfolder + "/memstats.txt";

	/*parsing bdi-stats file*/
	input.open(bdi_stats_file.c_str());
	if (input) {
		vector<string> bdi_dirty_thresh, dirty_thresh, bg_thresh;
		getline(input, STRING);
		while (!input.eof()) {
			if (STRING.find("BdiDirtyThresh:") != string::npos) {
				stringstream ss;
				ss << STRING;
				ss >> temp;
				ss >> temp;
				bdi_dirty_thresh.push_back(temp);
			} else if (STRING.find("DirtyThresh:") != string::npos) {
				stringstream ss;
                                ss << STRING;
                                ss >> temp;
                                ss >> temp;
                                dirty_thresh.push_back(temp);
			} else if (STRING.find("BackgroundThresh:") != string::npos) {
				stringstream ss;
                                ss << STRING;
                                ss >> temp;
                                ss >> temp;
				bg_thresh.push_back(temp);
			}
			getline(input, STRING);
		}
		input.close();
		/*BDI Dirty Threshold Values*/
		outputfilename = outputfolder + "/BdiDirtyThershold.txt";
		system(("rm -rf " + outputfilename).c_str());
		output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
		for (int i = 0; i < bdi_dirty_thresh.size(); i++ )
			output<<bdi_dirty_thresh[i]<<"\n";
		output.close();
		/*Global Dirty Threshold Values*/
		outputfilename = outputfolder + "/DirtyThershold.txt";
		system(("rm -rf " + outputfilename).c_str());
	        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
	        for (int i = 0; i < dirty_thresh.size(); i++ )
	                output<<dirty_thresh[i]<<"\n";
	        output.close();
		/*Global Background Threshold Values*/
		outputfilename = outputfolder + "/BackgroundThershold.txt";
		system(("rm -rf " + outputfilename).c_str());
	        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
	        for (int i = 0; i < bg_thresh.size(); i++ )
	                output<<bg_thresh[i]<<"\n";
	        output.close();
	} else
		cout<<"File "<<bdi_stats_file<<" Doesn't exists\n";

	/*Parse the memstats to get available memory*/
	input.open(mem_stats_file.c_str());
	if (input) {
		vector<string> availableMem;
		getline(input, STRING);
		while (!input.eof()) {
			if (STRING.find("MemAvailable:") != string::npos) {
				stringstream ss;
                                ss << STRING;
				ss >> temp;
				ss >> temp;
				availableMem.push_back(temp);
			}
			getline(input, STRING);
		}
		input.close();
		outputfilename = outputfolder + "/AvailableMem.txt";
		system(("rm -rf " + outputfilename).c_str());
		output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
                for (int i = 0; i < availableMem.size(); i++ )
                        output<<availableMem[i]<<"\n";
                output.close();
	} else
		cout<<"File "<<mem_stats_file<<" Doesn't exists\n";
return 0;
}
