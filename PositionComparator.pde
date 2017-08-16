import java.util.Comparator;

public class PositionComparator implements Comparator<PeakPoint>{
  @Override
  public int compare(PeakPoint a, PeakPoint b){
    return a.getPosition() > b.getPosition() ? 1 : a.getPosition() < b.getPosition() ? -1 : 0;
  }
}