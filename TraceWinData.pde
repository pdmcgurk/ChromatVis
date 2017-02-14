public class TraceWinData extends MyWinData {
  public int viewer_number;
  public ABISeqRun chromat1, chromat2, chromat3;
  public HashMap<String, IntList> dp;
  public GImageButton imgExport, baseExport, resizeButton;
  public GCheckbox dp_check, rc_check, name_check, bc_check, sub_check;
  public GSlider scroller, scaler;
  public GPanel resizePanel;
  public GTextField wField, hField;
  public GButton executeResize, cancelResize;
  public GLabel wide, high, px1, px2;
  
  public int getViewer() {
    return this.viewer_number;
  }
}