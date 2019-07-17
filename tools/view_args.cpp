  #include <locale>
  #include <cstdlib>
  #include <iostream>
  #include <sstream>
  int wmain(int argc, wchar_t *argv[]){
    if(argc < 2) return 0;
    setlocale( LC_ALL, "en_US.UTF-8" );
    std::wstringstream ss;
    std::wstringstream ss2;
    std::string str_arg;
    for(int i = 1; i < argc; i++)
      if (wcsstr(argv[i], L" ") != NULL) {
         ss << L"\"" << argv[i] << L"\"" << L" ";
      } else if (wcsstr(argv[i], L"&") != NULL) {
         ss << L"\"" << argv[i] << L"\"" << L" ";
      } else if (wcsstr(argv[i], L"^") != NULL) {
         ss << L"\"" << argv[i] << L"\"" << L" ";
      } else {
      	 ss << argv[i] << L" ";
      }
    std::wcerr << ss.str().c_str() << L"\n" << std::endl;
    ss2 << L"\"" << ss.str().c_str() << L"\"";
    _wsystem(ss2.str().c_str());
    return 0;
  }
  