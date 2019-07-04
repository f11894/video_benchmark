  #include <chrono>
  #include <cstdlib>
  #include <iostream>
  #include <sstream>
  int main(int argc, char *argv[]){
    if(argc < 2) return 0;
    std::stringstream ss;
    std::stringstream ss2;
    std::string str_arg;
    for(int i = 1; i < argc; i++)
      if (strstr(argv[i], " ") != NULL) {
         ss << "\"" << argv[i] << "\"" << " ";
      } else if (strstr(argv[i], "&") != NULL) {
         ss << "\"" << argv[i] << "\"" << " ";
      } else if (strstr(argv[i], "^") != NULL) {
         ss << "\"" << argv[i] << "\"" << " ";
      } else {
      	 ss << argv[i] << " ";
      }
    std::cout << ss.str().c_str() << "\n" << std::endl;
    auto startTime = std::chrono::system_clock::now();
    ss2 << "\"" << ss.str().c_str() << "\"";
    system(ss2.str().c_str());
    auto endTime = std::chrono::system_clock::now();
    auto timeSpan = endTime - startTime;
    std::cout << "TotalMilliseconds : " << std::chrono::duration_cast<std::chrono::milliseconds>(timeSpan).count() << std::endl;
    return 0;
  }
  