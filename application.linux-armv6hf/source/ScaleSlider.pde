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

public class ScaleSlider extends GSlider {
  
  public ScaleSlider(PApplet theApplet, int x, int y, int w, int h, int t) {
    super(theApplet, x, y, w, h, t);
    this.setLimits(0.0, 0.0, 4.0);
    this.setNumberFormat(G4P.DECIMAL, 1);
  }
  
  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}