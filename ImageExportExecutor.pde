public class ImageExportExecutor extends GButton {
  public ImageExportExecutor(PApplet theApplet, float x, float y) {
    super(theApplet, x, y, 50, 20, "Export");
}

  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}