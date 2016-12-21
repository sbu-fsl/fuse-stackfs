#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <stdlib.h>
#include <unordered_map>

using namespace std;

void print_usage() {
        cout<<"./parse-tracefile-no-fuse <Folder containing trace file>\n";
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

	string read_stats_file, tracefile, temp;
        string outputfilename;

        tracefile = outputfolder + "/trace.out";
        read_stats_file  = outputfolder + "/read-stats.txt";

	unordered_map<unsigned long, vector<double> > Map; /* inode -> list of read diffs for every iteration */
	unordered_map<unsigned long, vector<double> >::iterator iter;
	
	input.open(tracefile.c_str());
        if (input) {
                getline(input, STRING);
		while (!input.eof()) {
			if (STRING.find("filemap_generic_read_iter_difference:") != string::npos) {
				i = 0;
				stringstream ss;
                                ss << STRING;
				string temp;
				unsigned long inode;
				unsigned long nano_secs;
				double milli_secs;

				while (i < 15) {
					ss >> temp;
					if (i == 10) { /* inode */
						stringstream ss1;
                                                ss1 << temp;
						ss1 >> inode;
					} else if (i == 14) { /* time diff (ns) */
						stringstream ss1;
                                                ss1 << temp;
						ss1 >> nano_secs;
						milli_secs = nano_secs/(1000000);
					}
					i++;
				}
				if (Map.count(inode)) {
					(Map[inode]).push_back(milli_secs);
				} else {
					vector<double> times;
					times.push_back(milli_secs);
					Map[inode] = times;
				}
			}
			getline(input, STRING);
		}
	} else
                cout<<"No trace file\n";

	input.close();
	vector<double> temp1;
	double sum;
	int len;

	system(("rm -rf " + read_stats_file).c_str());
	output.open(read_stats_file.c_str(), std::ofstream::out|std::ofstream::app);

	for (iter = Map.begin(); iter != Map.end(); iter++) {
		temp1 = iter->second;
		//cout<< "Inode : "<<iter->first<<" ";
		len = temp1.size();
		sum = 0;
		for (int i = 0; i < len; i++) {
			//cout<<temp1[i]<<" ";
			sum += temp1[i];
		}
		//cout<<" Avg(ms) : "<<sum/len<<"\n";
		output<<sum/len<<"\n";
	}
	output.close();
	return 0;
}
/* filebench-11808 [002] ....  1935.487393: filemap_generic_read_iter_difference: Generic Read on inode : 5767184 time diff : 682 */
