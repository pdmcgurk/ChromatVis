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