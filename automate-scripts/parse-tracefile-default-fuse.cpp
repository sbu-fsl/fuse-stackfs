#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <stdlib.h>
#include <unordered_map>

using namespace std;

void print_usage() {
        cout<<"./parse-tracefile-default-fuse <Folder containing trace file>\n";
}

/*
 * StackFS_ll-18865 [002] .... 25281.345892: bg_queue_difference: Bg Queue on inode : 12095568 time diff : 95
 * StackFS_ll-18865 [002] .... 25281.345900: pending_queue_difference: Pending Queue on inode : 12095568 time diff : 49308
 * StackFS_ll-18865 [002] .... 25281.345900: processing_queue_difference: Processing Queue on inode : 12095568 time diff : 6746632
 * <...>-18873 [000] .... 25281.345940: fuse_read_difference: Fuse Read on inode : 12095568 time diff : 6851970
 * StackFS_ll-31362 [005] .... 216739.246437: queue_lengths: BG Length : 0 Pending Length : 0 Processing Length : 13  
 * */

void print_list(vector<double> &list) {
	int len;

	len = list.size();
	for (int i = 0; i < len; i++)
		cout<< list[i]<<" ";
	cout<<"\n";
}

int main(int argc, char **argv) {

        if (argc != 2) {
                print_usage();
                return 0;
        }

        string STRING, outputfolder;
        int i;

        ifstream input;

        outputfolder = argv[1];

	string read_stats_file, tracefile, temp;

        tracefile = outputfolder + "/trace.out";
        read_stats_file  = outputfolder + "/read-stats.txt";

	unordered_map<unsigned long, vector<vector<double> > > Map; /* inode -> list of read/bg/pending/processing diffs for every iteration */
	/*
 	 * Map[inode][0] --> bg diffs
	 * Map[inode][1] --> pending diffs
	 * Map[inode][2] --> processing diffs
	 * Map[inode][3] --> read diffs
 	 * */
	unordered_map<unsigned long, vector<vector<double> > >::iterator iter;

	vector<int> bg_lengths;
	vector<int> pending_lengths;
	vector<int> processing_lengths;	

	input.open(tracefile.c_str());
        if (input) {
                getline(input, STRING);
		while (!input.eof()) {
			if (STRING.find("bg_queue_difference:") != string::npos) {
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
					//cout<<"bg map if yes\n";
					(Map[inode][0]).push_back(milli_secs);
					//print_list((Map[inode][0]));
				} else {
					//cout<<"bg map if no\n";
					vector<vector<double> > times;
					vector<double> bg_times;

					bg_times.push_back(0);
					times.push_back(bg_times);
					times.push_back(bg_times);
					times.push_back(bg_times);
					times.push_back(bg_times);

					times[0].push_back(milli_secs);
					Map[inode] = times;
				}
			}  else if (STRING.find("pending_queue_difference:") != string::npos) {
				i = 0;
				stringstream ss;
                                ss << STRING;
				string temp;
				unsigned long inode;
				unsigned long nano_secs;
				double milli_secs;
				//cout<<"pending queue difference : "<< STRING <<"\n";
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
				cout<<"pending nanosecs : " <<nano_secs<< " msecs : "<<milli_secs<<"\n";
				if (Map.count(inode)) {
					//cout<<"pending map if yes\n";
					(Map[inode][1]).push_back(milli_secs);
					//print_list((Map[inode][1]));
				} else {
					//cout<<"pending map if no\n";
					vector<vector<double> > times;
					vector<double> bg_times;

					bg_times.push_back(0);
					times.push_back(bg_times);
					times.push_back(bg_times);
					times.push_back(bg_times);
					times.push_back(bg_times);

					times[1].push_back(milli_secs);
					Map[inode] = times;
				}
				
			} else if (STRING.find("processing_queue_difference:") != string::npos) {
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
					//cout<<"processing map if yes\n";
					(Map[inode][2]).push_back(milli_secs);
					//print_list((Map[inode][2]));
				} else {
					//cout<<"processing map if no\n";
					vector<vector<double> > times;
					vector<double> bg_times;

					bg_times.push_back(0);
					times.push_back(bg_times);
					times.push_back(bg_times);
					times.push_back(bg_times);
					times.push_back(bg_times);

					times[2].push_back(milli_secs);
					Map[inode] = times;
				}
			} else if (STRING.find("fuse_read_difference:") != string::npos) {
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
				//cout<<"Read difference inode : "<<inode<<" milli secs : "<<milli_secs<<"\n";
				if (Map.count(inode)) {
					//cout<<"read map if yes\n";
					(Map[inode][3]).push_back(milli_secs);
					//print_list((Map[inode][3]));
				} else {
					//cout<<"read map if no\n";
					vector<vector<double> > times;
					vector<double> bg_times;

					bg_times.push_back(0);
					times.push_back(bg_times);
					times.push_back(bg_times);
					times.push_back(bg_times);
					times.push_back(bg_times);

					times[3].push_back(milli_secs);
					Map[inode] = times;
				}
			} else if (STRING.find("queue_lengths:") != string::npos) {
				i = 0;
				stringstream ss;
                                ss << STRING;
				string temp;
				int bg_length, pending_length, processing_length;

				while (i < 17) {
					ss >> temp;
					if (i == 8) {
						stringstream ss1;
                                                ss1 << temp;
						ss1 >> bg_length;
					} else if (i == 12) {
						stringstream ss1;
                                                ss1 << temp;
						ss1 >> pending_length;
					} else if (i == 16) {
						stringstream ss1;
                                                ss1 << temp;
						ss1 >> processing_length;
					}
					i++;
				}
				bg_lengths.push_back(bg_length);
				pending_lengths.push_back(pending_length);
				processing_lengths.push_back(processing_length);
			}
			getline(input, STRING);
		}
	} else
                cout<<"No trace file\n";

	input.close();
	vector<vector<double> > temp1;
	vector<double> temp2;
	double sum;
	int len;
	
        string outputfilename1;
        string outputfilename2;
        string outputfilename3;
        string outputfilename4;
        string outputfilename5;
        string outputfilename6;
        string outputfilename7;

        ofstream output1;
        ofstream output2;
        ofstream output3;
        ofstream output4;
        ofstream output5;
        ofstream output6;
        ofstream output7;

	outputfilename1 = outputfolder + "/bg-stats.txt";
	outputfilename2 = outputfolder + "/pending-stats.txt";
	outputfilename3 = outputfolder + "/processing-stats.txt";
	outputfilename4 = outputfolder + "/read-stats.txt";
	outputfilename5 = outputfolder + "/bg_lengths.txt";
	outputfilename6 = outputfolder + "/pending_lengths.txt";
	outputfilename7 = outputfolder + "/processing_lengths.txt";

	system(("rm -rf " + outputfilename1).c_str());
	system(("rm -rf " + outputfilename2).c_str());
	system(("rm -rf " + outputfilename3).c_str());
	system(("rm -rf " + outputfilename4).c_str());
	system(("rm -rf " + outputfilename5).c_str());
	system(("rm -rf " + outputfilename6).c_str());
	system(("rm -rf " + outputfilename7).c_str());

	output1.open(outputfilename1.c_str(), std::ofstream::out|std::ofstream::app);
	output2.open(outputfilename2.c_str(), std::ofstream::out|std::ofstream::app);
	output3.open(outputfilename3.c_str(), std::ofstream::out|std::ofstream::app);
	output4.open(outputfilename4.c_str(), std::ofstream::out|std::ofstream::app);
	output5.open(outputfilename5.c_str(), std::ofstream::out|std::ofstream::app);
	output6.open(outputfilename6.c_str(), std::ofstream::out|std::ofstream::app);
	output7.open(outputfilename7.c_str(), std::ofstream::out|std::ofstream::app);

	for (iter = Map.begin(); iter != Map.end(); iter++) {
		temp1 = iter->second;
		//cout<<"Inode : "<<iter->first<<" ";
		for (int i = 0; i < 4; i++) {
			//if (i == 1)
			//	print_list(temp1[i]);

			temp2 = temp1[i];
			len = temp2.size();
			sum = 0;
			for (int j = 0; j < len; j++)
				sum += temp2[j];
			if (len > 1) {
				//cout<<" sum : "<<sum/(len-1)<<"\n";
				if (i == 0)
					output1 << sum/(len-1) << "\n";
				else if (i == 1)
					output2 << sum/(len-1) << "\n";
				else if (i == 2)
					output3 << sum/(len-1) << "\n";
				else if (i == 3)
					output4 << iter->first << " : " << sum/(len-1) << "\n";
			} else {
				//cout<<" sum : "<<sum/len<<"\n";
				if (i == 0)
					output1 << sum/(len) << "\n";
				else if (i == 1)
					output2 << sum/(len) << "\n";
				else if (i == 2)
					output3 << sum/(len) << "\n";
				else if (i == 3)
					output4 << sum/(len) << "\n";
			}
		}
	}

	for (int i = 0; i < bg_lengths.size(); i++)
		output5 << bg_lengths[i] <<"\n";

	for (int i = 0; i < pending_lengths.size(); i++)
		output6 << pending_lengths[i] <<"\n";

	for (int i = 0; i < processing_lengths.size(); i++)
		output7 << processing_lengths[i] <<"\n";

	output1.close();
	output2.close();
	output3.close();
	output4.close();
	output5.close();
	output6.close();
	output7.close();

	return 0;
}
