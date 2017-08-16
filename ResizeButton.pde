public class ResizeButton extends GImageButton {
  public ResizeButton(PApplet theApplet, float x, float y) {
    super(theApplet, x, y, new String[] { "resize.png", "resize.png", "resize.png" } , "allblack.png");
}

  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}