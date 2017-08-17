/*
Copyright 2017 Patrick McGurk
This file is part of ChromatVis.

ChromatVis is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ChromatVis is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with ChromatVis.  If not, see <http://www.gnu.org/licenses/>.
*/

public class DifferenceProfile {
  HashMap<String, IntList> traces;
  String[] bases;
  int peak;
  
  public DifferenceProfile (ABISeqRun q, ABISeqRun ref) {
    bases = new String[4];
    bases[0] = "A";
    bases[1] = "C";
    bases[2] = "G";
    bases[3] = "T";
    traces = new HashMap<String, IntList>();
    peak = 0;
    
    for (String s : bases) {
      traces.put(s, new IntList());
    }
    int dp_len = min(q.getLength(), ref.getLength());
    
    for (int i = 0; i < dp_len; i++) {
      calcDiffs(q, ref, i);
    }
    
    for (String s : bases) {
      int[] temparray = traces.get(s).array();
      peak = max(peak, max(temparray), abs(min(temparray)));
    }
  }
  
  public void calcDiffs(ABISeqRun q, ABISeqRun ref, int i) {
    int a_diff, c_diff, g_diff, t_diff;
    a_diff = ref.traces.get("A").get(i) - q.traces.get("A").get(i);
    c_diff = ref.traces.get("C").get(i) - q.traces.get("C").get(i);
    g_diff = ref.traces.get("G").get(i) - q.traces.get("G").get(i);
    t_diff = ref.traces.get("T").get(i) - q.traces.get("T").get(i);
    
    int opp_a = 0, opp_c = 0, opp_g = 0, opp_t = 0;
    if (a_diff * c_diff < 0) {
      opp_a += c_diff;
      opp_c += a_diff;
    }
    if (a_diff * g_diff < 0) {
      opp_a += g_diff;
      opp_g += a_diff;
    }
    if (a_diff * t_diff < 0) {
      opp_a += t_diff;
      opp_t += a_diff;
    }
    if (c_diff * g_diff < 0) {
      opp_c += g_diff;
      opp_g += c_diff;
    }
    if (c_diff * t_diff < 0) {
      opp_c += t_diff;
      opp_t += c_diff;
    }
    if (g_diff * t_diff < 0) {
      opp_g += t_diff;
      opp_t += g_diff;
    }
    
    traces.get("A").append(int(Math.signum(a_diff) * pow(a_diff, 2) * sqrt(abs(opp_a)) / 5000.0));
    traces.get("C").append(int(Math.signum(c_diff) * pow(c_diff, 2) * sqrt(abs(opp_c)) / 5000.0));
    traces.get("G").append(int(Math.signum(g_diff) * pow(g_diff, 2) * sqrt(abs(opp_g)) / 5000.0));
    traces.get("T").append(int(Math.signum(t_diff) * pow(t_diff, 2) * sqrt(abs(opp_t)) / 5000.0));
  }
  
  public int getPeakValue() {
    return peak;
  }
  
}