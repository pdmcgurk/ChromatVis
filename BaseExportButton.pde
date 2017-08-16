public class BaseExportButton extends GImageButton {
  public BaseExportButton(PApplet theApplet, float x, float y) {
    super(theApplet, x, y, new String[] { "bexport.png", "bexport.png", "bexport.png" } , "allblack.png");
}

  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}