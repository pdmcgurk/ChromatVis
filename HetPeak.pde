public class HetPeak {
  PeakPoint normal, alt, ref, diff = null;
  
  public HetPeak (PeakPoint _pk1, PeakPoint _pk2) {
    normal = _pk1;
    alt = _pk2;
  }
  
  public HetPeak (PeakPoint _pk1, PeakPoint _pk2, PeakPoint _ref) {
    ref = _ref;
    String norm_base = ref.getBase();
    if (_pk1.getBase() == norm_base) {
      normal = _pk1;
      alt = _pk2;
    } else if (_pk2.getBase() == norm_base) {
      normal = _pk2;
      alt = _pk1;
    }
  }
  
  public void setRef(PeakPoint _ref) {
    ref = _ref;
    String norm_base = ref.getBase();
    if (alt.getBase() == norm_base) {
      switchPeaks();
    }
  }
  
  public void setDiff(PeakPoint _diff) {
    diff = _diff;
  }
  
  public PeakPoint getNormalPeak() {
    return normal;
  }
  
  public PeakPoint getAltPeak() {
    return alt;
  }
  
  public PeakPoint getRefPeak() {
    return ref;
  }
  
  public PeakPoint getDiffPeak() {
    return diff;
  }
  
  public void switchPeaks() {
    PeakPoint temp = normal;
    normal = alt;
    alt = temp;
  }
}