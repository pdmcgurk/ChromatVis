public class ABISeqRun {
  File inFile;
  int index_entry_len, num_index_entries, total_index_size, index_offset;
  int x_offset, len;
  HashMap<String, IntList> traces = new HashMap<String, IntList>();
  IntList trace9, trace10, trace11, trace12, basepos;
  float ymax;
  String[] base_order = new String[4];
  String basecalls = "";
  String filename;
  PGraphics[] tracePics = new PGraphics[2];
  
  public ABISeqRun(File _inFile) {
    x_offset = 0;
    inFile = _inFile;
    filename = _inFile.getName();
    InputStream ins = createInput(inFile);
    DataInputStream traceFile = new DataInputStream(new BufferedInputStream(ins));
    traceFile.mark(int(pow(2, 32) - 1));
    String abinum = "";
    int ver = 0;
    try {
      //readChar() will try to get 2 bytes, can't use for this
      abinum += char(traceFile.readByte());
      abinum += char(traceFile.readByte());
      abinum += char(traceFile.readByte());
      abinum += char(traceFile.readByte());
      ver = traceFile.readShort();
    } catch (IOException e) {
      e.printStackTrace();
    }
    if (!abinum.equals("ABIF") | ver / 100 != 1){ //INSERT ERROR HANDLING
      print("no match\n");
      //do not open new window
      //display error message
    }
    else {
      //skip 10 bytes
      try {
        traceFile.skipBytes(10);
      } catch (IOException e) {
        e.printStackTrace();
      }
      //the next several bytes contain file index info
      try {
        index_entry_len = traceFile.readShort();
        num_index_entries = traceFile.readInt();
        total_index_size = traceFile.readInt();
        index_offset = traceFile.readInt(); 
        traceFile.skipBytes(index_offset - 30);
      } catch (IOException e) {
        e.printStackTrace();
      }
      //read the file index
      IndexEntry[] abiIndex = readIndex(traceFile);
      
      //read the data for each trace
      for (IndexEntry ie : abiIndex) {
        if (ie.name.equals("DATA_9")) {
          trace9 = (traceData(traceFile, ie));
        }
        else if (ie.name.equals("DATA_10")) {
          trace10 = (traceData(traceFile, ie));
        }
        else if (ie.name.equals("DATA_11")) {
          trace11 = (traceData(traceFile, ie));
        }
        else if (ie.name.equals("DATA_12")) {
          trace12 = (traceData(traceFile, ie));
        }
        else if (ie.name.equals("FWO__1")) {
          int val = ie.offset;
          base_order[0] = str(char((val >> 24) & 0xff));
          base_order[1] = str(char((val >> 16) & 0xff));
          base_order[2] = str(char((val >> 8) & 0xff));
          base_order[3] = str(char(val & 0xff));
        }
        else if (ie.name.equals("PBAS_1")) {
          basecalls = get_basecalls(traceFile, ie);
        }
        else if (ie.name.equals("PLOC_1")) {
          basepos = traceData(traceFile, ie);
        }
      }
      len = trace9.size();
      traces.put(base_order[0], trace9);
      traces.put(base_order[1], trace10);
      traces.put(base_order[2], trace11);
      traces.put(base_order[3], trace12);
      
      trim_ends();
      normalize();
      ymax = 0;
      for (String s : base_order) {
        if (traces.get(s).max() > ymax) {
          ymax = traces.get(s).max();
        }
      }
      tracePics = traceDraw();
      /* self.readBaseCalls()
        self.readConfScores()
        self.readTraceData()
        self.readBaseLocations()
        self.readComments() */
    }
    try {
      traceFile.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }
  
  ABISeqRun(ABISeqRun to_copy) {
    x_offset = 0;
    x_offset += to_copy.x_offset;
    index_entry_len = 0;
    index_entry_len += to_copy.index_entry_len;
    num_index_entries = 0;
    num_index_entries += to_copy.num_index_entries;
    total_index_size = 0;
    total_index_size += to_copy.total_index_size;
    index_offset = 0;
    index_offset += to_copy.index_offset;
    traces = new HashMap<String, IntList>();
    for (String key : to_copy.base_order) {
      traces.put(key, new IntList());
      for (int val : to_copy.traces.get(key)) {
        traces.get(key).append(val);
      }
    }
    basepos = new IntList();
    for (int val : to_copy.basepos) {
      basepos.append(val);
    }
    ymax = 0;
    ymax += to_copy.ymax;
    base_order = new String[4];
    for (int i = 0; i < 4; i++) {
      base_order[i] = to_copy.base_order[i];
    }
    basecalls = "";
    basecalls += to_copy.basecalls;
  }
  
  ABISeqRun copy() {
    ABISeqRun copy = new ABISeqRun(this);
    return copy;
  }
  
  int getLength() {
    return len;
  }
  
  void setLength(int i) {
    len = i;
  }
  
  void resetLength() {
    len = traces.get("A").size();
  }
  
  IndexEntry[] readIndex(DataInputStream traceFile) {
    IndexEntry[] iel = new IndexEntry[num_index_entries];
    for (int i = 0; i < this.num_index_entries; i++) {
      iel[i] = (readEntry(traceFile));
    }
    return iel;
  }
  
  IndexEntry readEntry(DataInputStream traceFile) {
    IndexEntry ie = new IndexEntry();
    String ident = "";
    try {
      ident += char(traceFile.readByte());
      ident += char(traceFile.readByte());
      ident += char(traceFile.readByte());
      ident += char(traceFile.readByte());
      int idv = traceFile.readInt();
      ident += "_" + str(idv);
      ie.setName(ident);
      IntList ints = new IntList();
      ints.append(traceFile.readShort());
      ints.append(traceFile.readShort());
      ints.append(traceFile.readInt());
      ints.append(traceFile.readInt());
      ints.append(traceFile.readInt());
      ie.setFields(ints);
      traceFile.skipBytes(4);
    } catch (IOException e) {
      e.printStackTrace();
    }
    return ie;
  }
  
  IntList traceData(DataInputStream traceFile, IndexEntry ie) {  
    IntList vals = new IntList();
    try {
      traceFile.reset();
      traceFile.mark(int(pow(2, 32) - 1));
      traceFile.skipBytes(ie.offset);
      for (int i = 0; i < ie.data_count; i++) {
        vals.append(traceFile.readShort());
      }
    } catch (IOException e) {
      e.printStackTrace();
    }
    return(vals);
  }
  
  void trim_ends(){
    boolean trim_start = false, trim_end = false;
    HashMap<String, IntList> trimmed_traces = new HashMap<String, IntList>();
    trimmed_traces.put("A", new IntList());
    trimmed_traces.put("C", new IntList());
    trimmed_traces.put("G", new IntList());
    trimmed_traces.put("T", new IntList());
    for (int i = 0; i < getLength(); i++){
      if (!trim_start) {
        for (String key : base_order) {
          if (traces.get(key).get(i) > 50) {
            trim_start = true;
          }
        }
      }
      if ((trim_start) && (!trim_end)){
        IntList vals = new IntList();
        for (String key : base_order) {
          vals.append(traces.get(key).get(i));
        }
        if (vals.max() < 50) {
          trim_end = true;
          for (int j = i; j < i + 100; j++) {
            vals = new IntList();
            for (String key : base_order) {
              vals.append(traces.get(key).get(j));
            }
            if (vals.max() > 50) {
              trim_end = false;
              break;
            }
          }
        } else {
          for (String key : base_order) {
            trimmed_traces.get(key).append(traces.get(key).get(i));
          }
        }
      }
      else if (trim_end) {
        break;
      }
    } 
    traces.put("A", trimmed_traces.get("A"));
    traces.put("C", trimmed_traces.get("C"));
    traces.put("G", trimmed_traces.get("G"));
    traces.put("T", trimmed_traces.get("T"));
    resetLength();
  }
  
  void normalize(){
    int end = getLength();
    HashMap<String, IntList> normal_traces = new HashMap<String, IntList>();
    normal_traces.put("A", new IntList());
    normal_traces.put("C", new IntList());
    normal_traces.put("G", new IntList());
    normal_traces.put("T", new IntList());
    for (int i = 0; i < end; i++){
      for (String key : base_order) {
        int sum = 0;
        float count = 0.0;
        for (int j = constrain(i - 500, 0, end);  j < constrain(i + 501, 0, end); j++){
          sum += traces.get(key).get(j);
          count += 1;
        }
        float scale_factor = sum / (count * 100);
        normal_traces.get(key).append(int(traces.get(key).get(i) / scale_factor));
      }
    }
    traces.put("A", normal_traces.get("A"));
    traces.put("C", normal_traces.get("C"));
    traces.put("G", normal_traces.get("G"));
    traces.put("T", normal_traces.get("T"));
    resetLength();
  }
  
  ABISeqRun get_best_align(ABISeqRun ref) {
    int best, best_offset;
    ABISeqRun temp = align(ref, 0, 1500);
    best = temp.align_score(201, 1000, ref, 0);
    best_offset = 0;
    
    for (int i = 10; i < 201; i += 10) {
      temp = align(ref, i, 1500);
      if (temp.getLength() >  1200) {
        int temp_score = temp.align_score(201, 1000, ref, 0);
        if (temp_score < best) {
          //print ("new best! " + temp_score + " at " + i + " offset\n");
          best = temp_score;
          best_offset = i;
        }
      }
      temp = align(ref, 0-i, 1500);
      if (temp.getLength() >  1200) {
        int temp_score = temp.align_score(201, 1000, ref, 0);
        if (temp_score < best) {
          //print ("new best! " + temp_score + " at " + str(0-i) + " offset\n");
          best = temp_score;
          best_offset = 0-i;
        }
      }
    }
    println(best_offset);
    ABISeqRun new_run = align(ref, best_offset, getLength());
    return new_run;
  }
  
  ABISeqRun align(ABISeqRun ref, int offset, int align_length) {
    ABISeqRun temp_run = copy();
    temp_run.traces.put("A", new IntList());
    temp_run.traces.put("C", new IntList());
    temp_run.traces.put("G", new IntList());
    temp_run.traces.put("T", new IntList());
    //make an array to align to ref[0:align_length]
    if (offset < 0) {
      for (String key : base_order) {
        for (int i = 0; i < abs(offset); i++) {
          temp_run.traces.get(key).append(0);
        }
        for (int i = 0; i < align_length + offset; i++) {
          temp_run.traces.get(key).append(traces.get(key).get(i));
        }
      }
    } else {
      for (String key : base_order) {
        for (int i = offset; i < min(align_length + offset, getLength()); i++) {
          temp_run.traces.get(key).append(traces.get(key).get(i));
        }
      }
    }
    temp_run.resetLength();
    //add or delete points to adjust alignment
    ABISeqRun temp2 = copy();
    temp2.traces.put("A", new IntList());
    temp2.traces.put("C", new IntList());
    temp2.traces.put("G", new IntList());
    temp2.traces.put("T", new IntList());
    PrintWriter indel_log;
    indel_log = createWriter("indel_log.txt");
    int start = 0;
    
    if (offset < 0) {
      start -= offset;
      for (String key : base_order) {
        for (int i = 0; i < start; i++) {
          temp2.traces.get(key).append(0);
        }
      }
    }
    int pred = 0;
    int end = temp_run.getLength();
    pred += end;
    int ref_idx = start, test_idx = start;
    int adj_offset = test_idx - ref_idx;
    while ((ref_idx < ref.getLength() - 30) && (test_idx < end - 30)) {
      if (test_idx % 3 == 2) {
        adj_offset = test_idx - ref_idx;
        //ref_idx + adj_offset = test_idx
        int base_score = temp_run.align_score(ref_idx, 30, ref, adj_offset);
        int ins_score = temp_run.align_score(ref_idx, 30, ref, -1 + adj_offset);
        int del_score = temp_run.align_score(ref_idx, 30, ref, 1 + adj_offset);
        /*if (align_length > 1501) {
          print (String.format("Aligning reference bases %d-%d to test sequence bases %d-%d. Base score: %d\n", ref_idx, ref_idx+29, ref_idx+adj_offset, ref_idx+adj_offset+29, base_score));
          print (String.format("Aligning reference bases %d-%d to test sequence bases %d-%d. Insert score: %d\n", ref_idx, ref_idx+29, ref_idx+adj_offset-1, ref_idx+adj_offset+28, ins_score));
          print (String.format("Aligning reference bases %d-%d to test sequence bases %d-%d. Delete score: %d\n\n", ref_idx, ref_idx+29, ref_idx+adj_offset+1, ref_idx+adj_offset+30, del_score));
        }*/
        if ((ins_score < base_score) && (ins_score < del_score)) {
          pred += 1;
          for (String key : base_order) {
            temp2.traces.get(key).append(temp_run.traces.get(key).get(test_idx - 1));
            temp2.traces.get(key).append(temp_run.traces.get(key).get(test_idx));
          }
          indel_log.println("ref " + ref_idx + " test " + test_idx + " INSERT");
          test_idx += 1;
          ref_idx += 2;
          //adj_offset -= 1;
        }
        else if ((del_score < base_score) && (del_score < ins_score)) {
          pred -= 1;
          //skip the current trace point
          indel_log.println("ref " + ref_idx + " test " + test_idx + " DELETE");
          test_idx += 1;
          //adj_offset += 1;
          //do not increment ref_idx
        } else {
          //add the next trace point as normal; iterate both arrays
          for (String key : base_order) {
            temp2.traces.get(key).append(temp_run.traces.get(key).get(test_idx));
          }
          indel_log.println("ref " + ref_idx + " test " + test_idx + " CONTINUE");
          test_idx += 1;
          ref_idx += 1;
        }
      } else {
        for (String key : base_order) {
          temp2.traces.get(key).append(temp_run.traces.get(key).get(test_idx));
        }
        test_idx += 1;
        ref_idx += 1;
      }
    }
    for (String key : base_order) {
      for (int i = end - 30; i < end; i++) {
        temp2.traces.get(key).append(temp_run.traces.get(key).get(i));
      }
    }
    temp2.resetLength();
    if (align_length > 1501) {
      println ("length before: " + end);
      println ("predicted length: " + pred);
      println ("actual length: " + temp2.getLength());
    }
    return temp2;
  }
          
  int align_score(int start, int align_length, ABISeqRun ref, int offset) {
    //start = starting index in reference trace
    //align_length = length of aligned sequences to score
    //ref = run containing reference trace
    //offset + reference index = query index
    int score = 0;
    for (String key : base_order) {
      for (int i = start; i < start + align_length; i++) {
        score += abs(ref.traces.get(key).get(i) - traces.get(key).get(i + offset));
      }
    }
    return score;
  }
  
  String get_basecalls(DataInputStream traceFile, IndexEntry ie) {  
    String bc = "";
    try {
      traceFile.reset();
      traceFile.mark(int(pow(2, 32) - 1));
      traceFile.skipBytes(ie.offset);
      for (int i = 0; i < ie.data_count; i++) {
        bc += char(traceFile.readByte());
      }
    } catch (IOException e) {
      e.printStackTrace();
    }
    return(bc);
  }
  
  HashMap<String, IntList> diff_profile(ABISeqRun ref) {
    HashMap<String, IntList> dp = new HashMap<String, IntList>();
    int a_diff, c_diff, g_diff, t_diff;
    dp.put("A", new IntList());
    dp.put("C", new IntList());
    dp.put("G", new IntList());
    dp.put("T", new IntList());
    int dp_len = min(getLength(), ref.getLength());
    
    for (int i = 0; i < dp_len; i++) {
      a_diff = ref.traces.get("A").get(i) - traces.get("A").get(i);
      c_diff = ref.traces.get("C").get(i) - traces.get("C").get(i);
      g_diff = ref.traces.get("G").get(i) - traces.get("G").get(i);
      t_diff = ref.traces.get("T").get(i) - traces.get("T").get(i);
      
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
      
      dp.get("A").append(constrain(int(Math.signum(a_diff) * pow(a_diff, 2) * sqrt(abs(opp_a)) / 5000.0), -500, 500));
      dp.get("C").append(constrain(int(Math.signum(c_diff) * pow(c_diff, 2) * sqrt(abs(opp_c)) / 5000.0), -500, 500));
      dp.get("G").append(constrain(int(Math.signum(g_diff) * pow(g_diff, 2) * sqrt(abs(opp_g)) / 5000.0), -500, 500));
      dp.get("T").append(constrain(int(Math.signum(t_diff) * pow(t_diff, 2) * sqrt(abs(opp_t)) / 5000.0), -500, 500));
    }
  return dp;
  }
  
  PGraphics[] traceDraw(int h, float scale){
    int w = int(scale * getLength());
    PGraphics[] pics = new PGraphics[2];
    PGraphics fwdimg = createGraphics(w, h);
    PGraphics revimg = createGraphics(w, h);
    StringDict baseRev = new StringDict(); 
    baseRev.set("A", "T");
    baseRev.set("C", "G");
    baseRev.set("G", "C");
    baseRev.set("T", "A");
    baseRev.set("N", "N");
    IntDict baseCols = new IntDict(); 
    baseCols.set("A", color(0, 200, 0, 200));
    baseCols.set("C", color(0, 0, 255, 200));
    baseCols.set("G", color(0, 200));
    baseCols.set("N", color(128, 200));
    baseCols.set("T", color(255, 0, 0, 200));
    color[] traceCols;
    
    traceCols = baseCols.valueArray();
    float x = 0;
    fwdimg.beginDraw();
    fwdimg.background(255);
    fwdimg.noFill();
    fwdimg.strokeWeight(1.5);
    fwdimg.stroke(traceCols[0]);
    fwdimg.beginShape();
    for (int y : traces.get("A")) {
      fwdimg.curveVertex(x, h - (y / ymax  * (h - 20)));
      x += scale;
    }
    fwdimg.endShape();
    x = 0;
    fwdimg.stroke(traceCols[1]);
    fwdimg.beginShape();
    for (int y : traces.get("C")) {
      fwdimg.curveVertex(x, h - (y / ymax * (h - 20)));
      x += scale;
    }
    fwdimg.endShape();
    x = 0;
    fwdimg.stroke(traceCols[2]);
    fwdimg.beginShape();
    for (int y : traces.get("G")) {
      fwdimg.curveVertex(x, h - (y / ymax * (h - 20)));
      x += scale;
    }
    fwdimg.endShape();
    x = 0;
    fwdimg.stroke(traceCols[4]);
    fwdimg.beginShape();
    for (int y : traces.get("T")) {
      fwdimg.curveVertex(x, h - (y / ymax * (h - 20)));
      x += scale;
    }
    fwdimg.endShape();
    fwdimg.endDraw();
    
    scale = 0 - scale;
    x = w;
    baseCols.sortKeysReverse();
    revimg.beginDraw();
    revimg.background(255);
    revimg.noFill();
    revimg.strokeWeight(1.5);
    revimg.stroke(traceCols[4]);
    revimg.beginShape();
    for (int y : traces.get("A")) {
      revimg.curveVertex(x, h - (y / ymax * (h - 20)));
      x += scale;
    }
    revimg.endShape();
    x = w;
    revimg.stroke(traceCols[2]);
    revimg.beginShape();
    for (int y : traces.get("C")) {
      revimg.curveVertex(x, h - (y / ymax * (h - 20)));
      x += scale;
    }
    revimg.endShape();
    x = w;
    revimg.stroke(traceCols[1]);
    revimg.beginShape();
    for (int y : traces.get("G")) {
      revimg.curveVertex(x, h - (y / ymax * (h - 20)));
      x += scale;
    }
    revimg.endShape();
    x = w;
    revimg.stroke(traceCols[0]);
    revimg.beginShape();
    for (int y : traces.get("T")) {
      revimg.curveVertex(x, h - (y / ymax * (h - 20)));
      x += scale;
    }
    revimg.endShape();
    revimg.endDraw();
    
    pics[0] = fwdimg;
    pics[1] = revimg;
    fwdimg.save("fwd.tif");
    revimg.save("rev.tif");
    return pics;
  }
  
  PGraphics[] traceDraw(){
    return this.traceDraw(512, 1);
  }
  
  /*void drawSubTraces(ABISeqRun ref) {
    int y_baseline = height - 40;
    noFill();
    float x_scale = (4 * scaler.value) + 1;
    float x = 0 - (scroller.value * (x_scale * getLength() - width));
    float x_init = x;
    stroke(0, 200, 0, 200);
    beginShape();
    for (int y = 0; y < getLength(); y++) {
      curveVertex(x, y_baseline - ((traces.get("A").get(y) - ref.traces.get("A").get(y)) / ymax * (height - 25)));
      x += x_scale;
    }
    endShape();
    x = x_init;
    stroke(0, 0, 255, 200);
    beginShape();
    for (int y = 0; y < getLength(); y++) {
      curveVertex(x, y_baseline - ((traces.get("C").get(y) - ref.traces.get("C").get(y)) / ymax * (height - 25)));
      x += x_scale;
    }
    endShape();
    x = x_init;
    stroke(0, 200);
    textAlign(CENTER);
    for (int n = 0; n < 10000; n += 100) {
      text(str(n), x + n * x_scale, 20);
    }
    beginShape();
    for (int y = 0; y < getLength(); y++) {
      curveVertex(x, y_baseline - ((traces.get("G").get(y) - ref.traces.get("G").get(y)) / ymax * (height - 25)));
      x += x_scale;
    }
    endShape();
    x = x_init;
    stroke(255, 0, 0, 200);
    beginShape();
    for (int y = 0; y < getLength(); y++) {
      curveVertex(x, y_baseline - ((traces.get("T").get(y) - ref.traces.get("T").get(y)) / ymax * (height - 25)));
      x += x_scale;
    }
    endShape();
  }*/
  
  String getFilename(){
    return filename;
  }
}