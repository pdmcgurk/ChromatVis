/*
Copyright 2017 Patrick McGurk
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

public class RLEArray {
  IntList values, lengths;
  
  public RLEArray(IntList list) {
    values = new IntList();
    lengths = new IntList();
    int idx = 0;
    while (idx < list.size()){
      values.append(list.get(idx));
      int len = 0;
      for (int i = idx; i < list.size(); i++) {
        if (list.get(idx) == list.get(i)) {
          len += 1;
        } else {
          break;
        }
      }
      lengths.append(len);
      idx += len;
    }
  }
  
  public IntList getValues(){
    return values;
  }
  
  public IntList getLengths(){
    return lengths;
  }
}