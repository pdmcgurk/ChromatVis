public class RLEArray {
  IntList values, lengths;
  
  public RLEArray(IntList list) {
    values = new IntList();
    lengths = new IntList();
    int idx = 0;
    while (idx < list.size()){
      values.append(list.get(idx));
      int len = 0;
      for (int i = idx; i < list.size(); i++) {
        if (list.get(idx) == list.get(i)) {
          len += 1;
        } else {
          break;
        }
      }
      lengths.append(len);
      idx += len;
    }
  }
  
  public IntList getValues(){
    return values;
  }
  
  public IntList getLengths(){
    return lengths;
  }
}