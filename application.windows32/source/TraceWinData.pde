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

public class TraceWinData extends MyWinData {
  public int viewer_number;
  public ABISeqRun chromat1, chromat2, chromat3;
  public GImageButton imgExport, baseExport, resizeButton;
  public GCheckbox dp_check, rc_check, name_check, bc_check, sub_check, xres_check;
  public GSlider scroller, scaler;
  public GPanel resizePanel, imgExportPanel;
  public GTextField wField, hField;
  public GButton executeResize, cancelResize, executeExport, cancelExport;
  public GLabel wide, high, px1, px2, ielabel1, ielabel2, ielabel3;
  public GDropList resList, fmtList;
  public String titleStr;
  
  public int getViewer() {
    return this.viewer_number;
  }
}