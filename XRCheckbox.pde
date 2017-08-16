public class XRCheckbox extends GCheckbox {
  public XRCheckbox(PApplet theApplet, float x, float y, float w, float h) {
    super(theApplet, x, y, w, h);
  }
  
  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}