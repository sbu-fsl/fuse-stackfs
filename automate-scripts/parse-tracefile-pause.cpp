#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <stdlib.h>
#include <unordered_map>

using namespace std;

void print_usage() {
        cout<<"./parse-tracefile <Folder containing trace file>\n";
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

	string pause_stats_file, tracefile, temp;
	string outputfilename;

	tracefile = outputfolder + "/trace.out";
        pause_stats_file  = outputfolder + "/pause-stats.txt";
		
	vector<int> pausetimes;
	vector<int> bdi_dirty;
	vector<int> bdi_reclaimable;
	vector<int> bdi_writeback;
	vector<int> bdi_dirty_thresh;
	vector<int> bdi_bg_thresh;
	vector<int> dirty_thresh;
	vector<int> bg_thresh;
	vector<int> nr_reclaimable;
	vector<int> pending_queue;
	vector<int> pos_ratio;
	vector<int> dirty_pages_pause;

	int iteration = 0;
	int pause = 0;
	int option;

	input.open(tracefile.c_str());
	if (input) {
		getline(input, STRING);
start:
		while (!input.eof()) {
			if (STRING.find("fuse_file_write_iter_begin:") != string::npos) {
//				cout<<"==============================\n";
				iteration++;
				pause = 0;
loopagain:
				getline(input, STRING);
				while (STRING.find("balance_dirty_pages_debug:") != string::npos) { /* There might be many pauses with in single iteration of 1MB I/O */
					stringstream ss;
					ss << STRING;
					string temp;
					int val;
					/* filebench-13033 [000] ....  1888.711650: balance_dirty_pages_debug: option : 1 nr_reclaimable : 4887 nr_dirty : 4887 dirty_thresh : 194739 bg_thresh : 97369 bdi_dirty : 1255 bdi_reclaimable : 703 bdi_writeback : 552 bdi_bg_thresh : 973 bdi_thresh : 1947 bdi_dirty_ratelimit : 25600 pos_ratio : 1100 task_ratelimit : 0 min_pause : 0 max_pause : 0 pause : 0 nr_dirtied_pause : 16 */
					i = 0;
//					cout<<STRING<<"\n";
					while (i < 56) {
						ss >> temp;
						if (i == 7) { /* option value*/
							stringstream ss1;
                                                        ss1 << temp;
                                                        ss1 >> val;
							option = val;
						} else if (i == 10) { /* nr_reclaimable (NR_DIRTY + UNSTABLE_NFS)*/
							stringstream ss1;
							ss1 << temp;
							ss1 >> val;
//							cout<<"nr_reclaimable : "<<temp<<"\n";
							nr_reclaimable.push_back(val);
						} else if (i == 16) { /* Global Dirty Threshold */
							stringstream ss1;
							ss1 << temp;
                                                        ss1 >> val;
//							cout<<"dirty_threshold : "<<val<<"\n";
							dirty_thresh.push_back(val);
						} else if (i == 19) { /* Global Background Threshold */
							stringstream ss1;
                                                        ss1 << temp;
                                                        ss1 >> val;
//							cout<<"bg_thresh : "<<val<<"\n";
							bg_thresh.push_back(val);
						} else if (i == 22) { /* BDI Dirty */
							stringstream ss1;
                                                        ss1 << temp;
                                                        ss1 >> val;
							if (option == 5)
								val = bdi_dirty[bdi_dirty.size() - 1];
							bdi_dirty.push_back(val);
						} else if (i == 25) { /* BDI Reclaimable */
							stringstream ss1;
                                                        ss1 << temp;
                                                        ss1 >> val;
                                                        if (option == 5)
                                                                val = bdi_reclaimable[bdi_reclaimable.size() - 1];
                                                        bdi_reclaimable.push_back(val);
						} else if (i == 28) { /* BDI Writeback */
							stringstream ss1;
                                                        ss1 << temp;
                                                        ss1 >> val;
                                                        if (option == 5)
                                                                val = bdi_writeback[bdi_writeback.size() - 1];
                                                        bdi_writeback.push_back(val);
						} else if (i == 31) { /* BDI Global Background Threshold */
							stringstream ss1;
                                                        ss1 << temp;
                                                        ss1 >> val;
							if (option == 5)
								val = bdi_bg_thresh[bdi_bg_thresh.size() - 1];
							bdi_bg_thresh.push_back(val);
						} else if (i == 34) { /* Global BDI Dirty Threshold */
							stringstream ss1;
                                                        ss1 << temp;
                                                        ss1 >> val;
							if (option == 5)
								val = bdi_dirty_thresh[bdi_dirty_thresh.size() - 1];
							bdi_dirty_thresh.push_back(val);
						} else if (i == 40) { /* Position Ratio */
							stringstream ss1;
                                                        ss1 << temp;
                                                        ss1 >> val;
							if (option == 5)
								val = pos_ratio[pos_ratio.size() - 1];
							pos_ratio.push_back(val);
						} else if (i == 52) { /* Pause Value */
							stringstream ss1;
                                                        ss1 << temp;
                                                        ss1 >> val;
//							cout<<"val : "<<val<<"\n";
							if (option == 1 || option == 3 || option == 5)
								pause += 0;
							else
								pause += val; /* in msecs */		
						} else if (i == 55) { /* Dirty Pages Pause */
							stringstream ss1;
                                                        ss1 << temp;
                                                        ss1 >> val;
							dirty_pages_pause.push_back(val);
						}
						i++;
					}
					getline(input, STRING);
				}
				if (STRING.find("fuse_file_write_iter_end:") != string::npos) {
//					cout<<"Sum : "<<pause<<"\n";
//					cout<<"=================\n";
					pausetimes.push_back(pause);
					getline(input, STRING);
					goto start;
				} else if (STRING.find("queue_lengths:") != string::npos) { /* like getxattr */
					/* filebench-18536 [003] .... 89275.429690: queue_lengths: BG Length : 0 Pending Length : 0 Processing Length : 0 */
//					cout<<"queue lengths line : "<<STRING<<"\n";
					stringstream ss, ss1;
                                        ss << STRING;
                                        string temp;
                                        int val;

					i = 0;
					while (i < 13) {
						ss >> temp;
						i++;
					}
					ss1 << temp;
					ss1 >> val;
					pending_queue.push_back(val);
					goto loopagain;
				} else {
					goto loopagain;
				}
                        }
                        getline(input, STRING);
                }	
	} else
		cout<<"No trace file\n";

//	cout<<"iterations : "<<iteration<<"\n";
//	for (int i=1; i <= iteration; i++)
//		cout<<pausetimes[i-1]<<"\n";
	
	/*parse pause times*/
	outputfilename = outputfolder + "/pauseTimes.txt";
	system(("rm -rf " + outputfilename).c_str());
	output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
	for (int i=1; i <= iteration; i++)
		output<<pausetimes[i-1]<<"\n";
	output.close();

	/*parse reclaimable dirty pages*/
	outputfilename = outputfolder + "/nr_reclaimable.txt";
	system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
	for (int i=0; i < nr_reclaimable.size(); i++)
		output<<nr_reclaimable[i]<<"\n";
	output.close();

	/*parse dirty threshold pages*/
        outputfilename = outputfolder + "/dirty_thresh.txt";
        system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
        for (int i=0; i < dirty_thresh.size(); i++)
                output<<dirty_thresh[i]<<"\n";
        output.close();

	/*parse bg_thresh pages*/
        outputfilename = outputfolder + "/bg_thresh.txt";
        system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
        for (int i=0; i < bg_thresh.size(); i++)
                output<<bg_thresh[i]<<"\n";
        output.close();

	/*parse bdi_dirty pages*/
        outputfilename = outputfolder + "/bdi_dirty.txt";
        system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
        for (int i=0; i < bdi_dirty.size(); i++)
                output<<bdi_dirty[i]<<"\n";
        output.close();

	/*parse bdi_reclaimable pages*/
        outputfilename = outputfolder + "/bdi_reclaimable.txt";
        system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
        for (int i=0; i < bdi_reclaimable.size(); i++)
                output<<bdi_reclaimable[i]<<"\n";
        output.close();

	/*parse bdi_writeback pages*/
        outputfilename = outputfolder + "/bdi_writeback.txt";
        system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
        for (int i=0; i < bdi_writeback.size(); i++)
                output<<bdi_writeback[i]<<"\n";
        output.close();
	
	/*parse bdi_bg_thresh pages*/
        outputfilename = outputfolder + "/bdi_bg_thresh.txt";
        system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
        for (int i=0; i < bdi_bg_thresh.size(); i++)
                output<<bdi_bg_thresh[i]<<"\n";
        output.close();
		
	/*parse bdi_dirty_thresh pages*/
        outputfilename = outputfolder + "/bdi_dirty_thresh.txt";
        system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
        for (int i=0; i < bdi_dirty_thresh.size(); i++)
                output<<bdi_dirty_thresh[i]<<"\n";
        output.close();

	/* Position Ratio Values */
	outputfilename = outputfolder + "/pos_ratios.txt";
        system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
        for (int i=0; i < pos_ratio.size(); i++)
                output<<pos_ratio[i]<<"\n";
        output.close();

	/* Dirty pages Pause points (How many dirty pages after which this check is called again) */
	outputfilename = outputfolder + "/task_dirty_pages_limit.txt";
	system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
        for (int i=0; i < dirty_pages_pause.size(); i++)
                output<<dirty_pages_pause[i]<<"\n";
        output.close();

	/* pending queue lengths just before putting GETXATTR req to the pending queue */
	outputfilename = outputfolder + "/pending_queue_lengths.txt";
        system(("rm -rf " + outputfilename).c_str());
        output.open(outputfilename.c_str(), std::ofstream::out|std::ofstream::app);
	if (pending_queue.size() > 1) {
        	for (int i=0; i < pending_queue.size(); i++)
                	output<<pending_queue[i]<<"\n";
	} else {
		for (int i=0; i < iteration; i++)
			output<<0<<"\n";
	}
        output.close();

return 0;
}
