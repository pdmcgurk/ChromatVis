public class ResizeExecutor extends GButton {
  public ResizeExecutor(PApplet theApplet, float x, float y) {
    super(theApplet, x, y, 50, 20, "Resize");
}

  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}