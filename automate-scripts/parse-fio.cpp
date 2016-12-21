#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

using namespace std;

/* Parses the fio.out and parses the ops/sec and 
 * throughput, time took numbers and places them in 
 * the same folder.
 * */

void print_usage() {
        cout<<"./parse-fio <Folder containing files>\n";
}


int main(int argc, char **argv) {
	if (argc != 2) {
		print_usage();
		return 0;
	}

	string outputfilename, STRING1, outputfolder;
	string fio_out;
	ifstream input;
	ofstream output;
	outputfolder = argv[1];

	fio_out =  outputfolder + "/fio.out";

	string STRING;

	input.open(fio_out);
	if (input) {
		getline(input, STRING);
		while (!input.eof()) {
			/* read : io=206464KB, bw=20634KB/s, iops=161, runt= 10006msec */
			if (STRING.find("read : io") != string::npos) {
				
				string io_read, band_width, iops, temp;
				stringstream ss;
				int j = 0;
				ss << STRING;
				//cout<<"STRING : " << STRING <<"\n";		
				while (j < 5) {
					ss >> temp;
					if (j == 2)
						io_read = temp;
					if (j == 3)
						band_width = temp;
					if (j == 4)
						iops = temp;
					j++;
				}
				//cout<<"io_read : "<<io_read<<" , bandwidth : "<<band_width<<" , iops : "<<iops<<"\n"; 
				long int io_read1, band_width1, iops1;
				io_read1 = stoi(io_read.substr(3, io_read.length() - 5));
				band_width1 = stoi(band_width.substr(3, band_width.length() - 7));
				iops1 = stoi(iops.substr(5, iops.length() - 5));
				//cout<<"io_read : "<<io_read1<<" , bandwidth : "<<band_width1<<" , iops : "<<iops1<<"\n";

				outputfilename = outputfolder + "/io_read.txt";
				output.open(outputfilename, std::ofstream::out);
                                output << io_read1 <<"\n";
                                output.close();

				outputfilename = outputfolder + "/bandwidth.txt";
				output.open(outputfilename, std::ofstream::out);
                                output << band_width1 <<"\n";
                                output.close();

				outputfilename = outputfolder + "/iops.txt";
				output.open(outputfilename, std::ofstream::out);
                                output << iops1 <<"\n";
                                output.close();

			}
			getline(input, STRING);
		}
		input.close();
	} else
		cout<< "Error in opening file : "<< fio_out <<"\n";
} 
