/*
Copyright 2007 Patrick McGurk
This file is part of ChromatVis.

ChromatVis is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ChromatVis is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with ChromatVis.  If not, see <http://www.gnu.org/licenses/>.
*/

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