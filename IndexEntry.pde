class IndexEntry {
  String name = "";
  int data_format, fmt_size, data_count, data_len, offset;
  
  void setName(String s) {
    name = s;
  }
  
  void setFields(IntList ints) {
    data_format = ints.get(0);
    fmt_size = ints.get(1);
    data_count = ints.get(2);
    data_len = ints.get(3);
    offset = ints.get(4);
  }
  
  String toString(){
    return name + " " + data_format + " " + fmt_size + " " + data_count + " " + data_len + " " + offset + "\n";
  }
}