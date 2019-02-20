  #include <chrono>
  #include <cstdlib>
  #include <iostream>
  #include <sstream>
  int main(int argc, char *argv[]){
    if(argc < 2) return 0;
    std::stringstream ss;
    ss << "\"";
    for(int i = 1; i < argc; ++i)
      ss << "\"" << argv[i] << "\"" << " ";
    ss << "\"";
    auto startTime = std::chrono::system_clock::now();
    system(ss.str().c_str());
    auto endTime = std::chrono::system_clock::now();
    auto timeSpan = endTime - startTime;
    std::cout << std::chrono::duration_cast<std::chrono::seconds>(timeSpan).count() << std::endl;
    return 0;
  }
  