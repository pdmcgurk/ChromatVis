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

public class HetPeak {
  PeakPoint normal, alt, ref, diff = null;
  
  public HetPeak (PeakPoint _pk1, PeakPoint _pk2) {
    normal = _pk1;
    alt = _pk2;
  }
  
  public HetPeak (PeakPoint _pk1, PeakPoint _pk2, PeakPoint _ref) {
    ref = _ref;
    String norm_base = ref.getBase();
    if (_pk1.getBase() == norm_base) {
      normal = _pk1;
      alt = _pk2;
    } else if (_pk2.getBase() == norm_base) {
      normal = _pk2;
      alt = _pk1;
    }
  }
  
  public void setRef(PeakPoint _ref) {
    ref = _ref;
    String norm_base = ref.getBase();
    if (alt.getBase() == norm_base) {
      switchPeaks();
    }
  }
  
  public void setDiff(PeakPoint _diff) {
    diff = _diff;
  }
  
  public PeakPoint getNormalPeak() {
    return normal;
  }
  
  public PeakPoint getAltPeak() {
    return alt;
  }
  
  public PeakPoint getRefPeak() {
    return ref;
  }
  
  public PeakPoint getDiffPeak() {
    return diff;
  }
  
  public void switchPeaks() {
    PeakPoint temp = normal;
    normal = alt;
    alt = temp;
  }
}