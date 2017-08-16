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

public class SeqRun {
  StringDict baseRev = new StringDict(); 
  IntDict baseCols = new IntDict(); 
  color[] traceCols;
  
  public SeqRun() {
    baseRev.set("A", "T");
    baseRev.set("C", "G");
    baseRev.set("G", "C");
    baseRev.set("T", "A");
    baseRev.set("N", "N");
    baseCols.set("A", color(0, 200, 0, 200));
    baseCols.set("C", color(0, 0, 255, 200));
    baseCols.set("G", color(0, 200));
    baseCols.set("N", color(128, 200));
    baseCols.set("T", color(255, 0, 0, 200));
    traceCols = baseCols.valueArray();
  }
}