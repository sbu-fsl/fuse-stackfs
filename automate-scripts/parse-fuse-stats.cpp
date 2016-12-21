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
        cout<<"./parse-fuse-stats <Folder containing files>\n";
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

	string kernel_bg, kernel_pending, kernel_processing, user_proc_file, filebench_out, cpu_stats_file, mem_stats_file, disk_stats_file;
        vector<string> temp;
        int i = 1;

	kernel_bg = outputfolder + "/background_queue_requests_timings";
        kernel_pending = outputfolder + "/pending_queue_requests_timings";
        kernel_processing = outputfolder + "/processing_queue_requests_timings";
        user_proc_file = outputfolder + "/user_stats.txt";

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
        } else
		cout<<"Error in opeing file : "<<kernel_bg<<"\n";

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
        } else
		cout<<"Error in opeing file : "<<kernel_pending<<"\n";

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
        } else
		cout<<"Error in opeing file : "<<kernel_processing<<"\n";

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
        } else
		cout<<"Error in opeing file : "<<user_proc_file<<"\n";
	
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
                        output<<"Request Type                   : "<<get_req_type(i)<<"\n";
                        output<<"Background queue count         : "<<background[i][33]<<"\n";
                        output<<"Pending queue count            : "<<pending[i][33]<<"\n";
                        output<<"Processing queue count         : "<<processing[i][33]<<"\n";
                        output<<"User Processing queue count    : "<<user_processing[i][33]<<"\n";
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
	
return 0;
}			

