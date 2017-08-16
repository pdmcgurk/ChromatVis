public class PeakPoint {
  int position, value;
  String base;
  PeakPoint opposite = null;

  public PeakPoint (int pos, int val) {
    position = pos;
    value = val;
  }
  
  public void setPosition(int pos) {
    position = pos;
  }
  
  public void setValue(int val) {
    value = val;
  }
  
  public void setBase(String n) {
    base = n;
  }
  
  public int getPosition() {
    return position;
  }
  
  public int getValue() {
    return value;
  }
  
  public String getBase() {
    return base;
  }
  
  public void setOpposite(PeakPoint pk) {
    opposite = pk;
    pk.opposite = this;
  }
  
  public PeakPoint getOpposite() {
    return opposite;
  }
  
  public boolean hasOpposite() {
    return opposite != null;
  }
}