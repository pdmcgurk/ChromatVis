public class SeqRun {
  StringDict baseRev = new StringDict(); 
  IntDict baseCols = new IntDict(); 
  color[] traceCols;
  
  public SeqRun() {
    baseRev.set("A", "T");
    baseRev.set("C", "G");
    baseRev.set("G", "C");
    baseRev.set("T", "A");
    baseRev.set("N", "N");
    baseCols.set("A", color(0, 200, 0, 200));
    baseCols.set("C", color(0, 0, 255, 200));
    baseCols.set("G", color(0, 200));
    baseCols.set("N", color(128, 200));
    baseCols.set("T", color(255, 0, 0, 200));
    traceCols = baseCols.valueArray();
  }
}