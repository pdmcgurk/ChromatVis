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