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

public class PeakPoint {
  int position, value;
  String base;
  PeakPoint opposite = null;

  public PeakPoint (int pos, int val) {
    position = pos;
    value = val;
  }
  
  public void setPosition(int pos) {
    position = pos;
  }
  
  public void setValue(int val) {
    value = val;
  }
  
  public void setBase(String n) {
    base = n;
  }
  
  public int getPosition() {
    return position;
  }
  
  public int getValue() {
    return value;
  }
  
  public String getBase() {
    return base;
  }
  
  public void setOpposite(PeakPoint pk) {
    opposite = pk;
    pk.opposite = this;
  }
  
  public PeakPoint getOpposite() {
    return opposite;
  }
  
  public boolean hasOpposite() {
    return opposite != null;
  }
}