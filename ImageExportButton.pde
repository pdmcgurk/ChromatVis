public class ImageExportButton extends GImageButton {
  public ImageExportButton(PApplet theApplet, float x, float y) {
    super(theApplet, x, y, new String[] { "iexport.png", "iexport.png", "iexport.png" } , "allblack.png");
}

  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}