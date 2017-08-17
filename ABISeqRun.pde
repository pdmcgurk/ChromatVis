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

public class ABISeqRun extends SeqRun {
  File inFile;
  int index_entry_len, num_index_entries, total_index_size, index_offset;
  int x_offset, len;
  HashMap<String, IntList> traces = new HashMap<String, IntList>();
  DifferenceProfile dp = null;
  IntList trace9, trace10, trace11, trace12, basepos, parsed_pos = null;
  float ymax;
  String[] base_order = new String[4];
  String basecalls = "";
  String parsed_calls = "";
  String filename;
  PImage[] tracePics, diffPics = null;
  ArrayList<PeakPoint> peaks, diffPeaks = null;
  ArrayList<HetPeak> hetPeaks = null;

  public ABISeqRun(File _inFile) {
    super();
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
    } 
    catch (IOException e) {
      e.printStackTrace();
    }
    if (!abinum.equals("ABIF") | ver / 100 != 1) { //INSERT ERROR HANDLING
      print("no match\n");
      //do not open new window
      //display error message
    } else {
      //skip 10 bytes
      try {
        traceFile.skipBytes(10);
      } 
      catch (IOException e) {
        e.printStackTrace();
      }
      //the next several bytes contain file index info
      try {
        index_entry_len = traceFile.readShort();
        num_index_entries = traceFile.readInt();
        total_index_size = traceFile.readInt();
        index_offset = traceFile.readInt(); 
        traceFile.skipBytes(index_offset - 30);
      } 
      catch (IOException e) {
        e.printStackTrace();
      }
      //read the file index
      IndexEntry[] abiIndex = readIndex(traceFile);

      //read the data for each trace
      for (IndexEntry ie : abiIndex) {
        if (ie.name.equals("DATA_9")) {
          trace9 = (traceData(traceFile, ie));
        } else if (ie.name.equals("DATA_10")) {
          trace10 = (traceData(traceFile, ie));
        } else if (ie.name.equals("DATA_11")) {
          trace11 = (traceData(traceFile, ie));
        } else if (ie.name.equals("DATA_12")) {
          trace12 = (traceData(traceFile, ie));
        } else if (ie.name.equals("FWO__1")) {
          int val = ie.offset;
          base_order[0] = str(char((val >> 24) & 0xff));
          base_order[1] = str(char((val >> 16) & 0xff));
          base_order[2] = str(char((val >> 8) & 0xff));
          base_order[3] = str(char(val & 0xff));
        } else if (ie.name.equals("PBAS_1")) {
          basecalls = get_basecalls(traceFile, ie);
        } else if (ie.name.equals("PLOC_1")) {
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
      //tracePics = traceDraw();
      /* self.readBaseCalls()
       self.readConfScores()
       self.readTraceData()
       self.readBaseLocations()
       self.readComments() */
    }
    try {
      traceFile.close();
    } 
    catch (IOException e) {
      e.printStackTrace();
    }
  }

  ABISeqRun(ABISeqRun to_copy) {
    super();
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
    filename = "";
    filename += to_copy.filename;
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
    } 
    catch (IOException e) {
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
    } 
    catch (IOException e) {
      e.printStackTrace();
    }
    return(vals);
  }

  void trim_ends() {
    boolean trim_start = false, trim_end = false;
    HashMap<String, IntList> trimmed_traces = new HashMap<String, IntList>();
    trimmed_traces.put("A", new IntList());
    trimmed_traces.put("C", new IntList());
    trimmed_traces.put("G", new IntList());
    trimmed_traces.put("T", new IntList());
    for (int i = 200; i < getLength(); i++) {
      //OPTION A: Skip until start point determined 
      if (!trim_start) {
        for (String key : base_order) {
          if (traces.get(key).get(i) > 50) {
            trim_start = true;
          }
        }
        if (trim_start) {
          String new_bc = "";
          IntList new_bp = new IntList();
          boolean new_start = false;
          for (int j = 0; j < basecalls.length(); j++) {
            if (!new_start) {
              if (basepos.get(j) < i) {
              } else {
                new_bc = basecalls.substring(j);
                new_bp.append(basepos.get(j) - i);
                new_start = true;
              }
            } else {
              new_bp.append(basepos.get(j) - i);
            }
          }        
          basecalls = new_bc;
          basepos = new_bp;
        }
      }

      //OPTION B: Appending quality data points
      if ((trim_start) && (!trim_end)) {
        IntList vals = new IntList();
        for (String key : base_order) {
          int temp_val = traces.get(key).get(i);
          vals.append(temp_val);
          trimmed_traces.get(key).append(temp_val);
        }
        //If signal drops below 50, stop appending if next 100 data points are also below threshold
        if (vals.max() < 50) {
          trim_end = true;
          int scan_end = min(i + 100, getLength());
          for (int j = i; j < scan_end; j++) {
            vals = new IntList();
            for (String key : base_order) {
              vals.append(traces.get(key).get(j));
            }
            if (vals.max() > 50) {
              trim_end = false;
              break;
            }
          }
        }
      }
      //OPTION C: Stop loop
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

  void normalize() {
    int end = getLength();
    HashMap<String, IntList> normal_traces = new HashMap<String, IntList>();
    normal_traces.put("A", new IntList());
    normal_traces.put("C", new IntList());
    normal_traces.put("G", new IntList());
    normal_traces.put("T", new IntList());
    for (int i = 0; i < end; i++) {
      for (String key : base_order) {
        int sum = 0;
        float count = 0.0;
        for (int j = constrain(i - 500, 0, end); j < constrain(i + 501, 0, end); j++) {
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
          best = temp_score;
          best_offset = i;
        }
      }
      temp = align(ref, 0-i, 1500);
      if (temp.getLength() >  1200) {
        int temp_score = temp.align_score(201, 1000, ref, 0);
        if (temp_score < best) {
          best = temp_score;
          best_offset = 0-i;
        }
      }
    }
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
      int end = min(align_length + offset, getLength());
      for (String key : base_order) {
        for (int i = offset; i < end; i++) {
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
    int start = 0;
    //adjust base positions with offset
    if (align_length > 1500) {  
      for (int i = 0; i < basecalls.length(); i++) {
        temp2.basepos.set(i, basepos.get(i) - offset);
      }
    }
    if (offset < 0) {
      start -= offset;
      for (String key : base_order) {
        for (int i = 0; i < start; i++) {
          temp2.traces.get(key).append(0);
        }
      }
    }
    int end = temp_run.getLength();
    int ref_idx = start, test_idx = start;
    int adj_offset = test_idx - ref_idx;
    while ((ref_idx < ref.getLength() - 30) && (test_idx < end - 30)) {
      if (test_idx % 3 == 2) {
        adj_offset = test_idx - ref_idx;
        //ref_idx + adj_offset = test_idx
        int base_score = temp_run.align_score(ref_idx, 30, ref, adj_offset);
        int ins_score = temp_run.align_score(ref_idx, 30, ref, -1 + adj_offset);
        int del_score = temp_run.align_score(ref_idx, 30, ref, 1 + adj_offset);

        if ((ins_score < base_score) && (ins_score < del_score)) {
          for (String key : base_order) {
            temp2.traces.get(key).append(temp_run.traces.get(key).get(test_idx - 1));
            temp2.traces.get(key).append(temp_run.traces.get(key).get(test_idx));
          }
          for (int i = 0; i < basecalls.length(); i++) {
            int pos = temp2.basepos.get(i);
            if (align_length > 1500 && pos > test_idx) {
              temp2.basepos.set(i, pos + 1);
            }
          }
          test_idx += 1;
          ref_idx += 2;
          //adj_offset -= 1;
        } else if ((del_score < base_score) && (del_score < ins_score)) {
          //skip the current trace point
          for (int i = 0; i < basecalls.length(); i++) {
            int pos = temp2.basepos.get(i);
            if (align_length > 1500 && pos > test_idx) {
              temp2.basepos.set(i, pos - 1);
            }
          }
          test_idx += 1;
          //adj_offset += 1;
          //do not increment ref_idx
        } else {
          //add the next trace point as normal; iterate both arrays
          for (String key : base_order) {
            temp2.traces.get(key).append(temp_run.traces.get(key).get(test_idx));
          }
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
    } 
    catch (IOException e) {
      e.printStackTrace();
    }
    return(bc);
  }

  PImage[] traceDraw(int h, float scale, boolean bc_check) {
    int w = int(scale * getLength());
    float maxh =  (h - 20) / (ymax * 0.8);
    PImage[] pics = new PImage[2];
    PGraphics fwdimg = createGraphics(w, h);
    PGraphics revimg = createGraphics(w, h);

    float x = 0;
    fwdimg.beginDraw();
    fwdimg.background(255);
    fwdimg.noFill();
    fwdimg.strokeWeight(1.5);
    fwdimg.stroke(traceCols[0]);
    fwdimg.beginShape();
    for (int y : traces.get("A")) {
      fwdimg.curveVertex(x, h - (y * maxh));
      x += scale;
    }
    fwdimg.endShape();
    x = 0;
    fwdimg.stroke(traceCols[1]);
    fwdimg.beginShape();
    for (int y : traces.get("C")) {
      fwdimg.curveVertex(x, h - (y * maxh));
      x += scale;
    }
    fwdimg.endShape();
    x = 0;
    fwdimg.stroke(traceCols[2]);
    fwdimg.beginShape();
    for (int y : traces.get("G")) {
      fwdimg.curveVertex(x, h - (y * maxh));
      x += scale;
    }
    fwdimg.endShape();
    x = 0;
    fwdimg.stroke(traceCols[4]);
    fwdimg.beginShape();
    for (int y : traces.get("T")) {
      fwdimg.curveVertex(x, h - (y * maxh));
      x += scale;
    }
    fwdimg.endShape();
    if (bc_check) {
      fwdimg.textSize(12);
      fwdimg.textAlign(CENTER);
      for (int i = 0; i < basecalls.length(); i++) {
        String letter = str(basecalls.charAt(i));
        fwdimg.fill(baseCols.get(letter));
        fwdimg.text(letter, basepos.get(i) * scale, 14);
      }
      if (hetPeaks != null) {
        fwdimg.textSize(16);
        fwdimg.textAlign(CENTER);
        for (HetPeak hpk : hetPeaks) {
          String letter = hpk.getAltPeak().getBase();
          fwdimg.fill(baseCols.get(letter));
          fwdimg.text(letter, hpk.getAltPeak().getPosition() * scale, 32);
        }
        /*/QA for double peak detection
        for (HetPeak hpk : hetPeaks) {
          fwdimg.stroke(0);
          int xpos = int(hpk.getAltPeak().getPosition() * scale);
          fwdimg.line(xpos, 0, xpos, fwdimg.height);
        }*/
      }
    }
    fwdimg.endDraw();

    revimg.beginDraw();
    revimg.background(255);
    scale = 0 - scale;
    x = w;
    revimg.noFill();
    revimg.strokeWeight(1.5);
    revimg.stroke(traceCols[4]);
    revimg.beginShape();
    for (int y : traces.get("A")) {
      revimg.curveVertex(x, h - (y * maxh));
      x += scale;
    }
    revimg.endShape();
    x = w;
    revimg.stroke(traceCols[2]);
    revimg.beginShape();
    for (int y : traces.get("C")) {
      revimg.curveVertex(x, h - (y * maxh));
      x += scale;
    }
    revimg.endShape();
    x = w;
    revimg.stroke(traceCols[1]);
    revimg.beginShape();
    for (int y : traces.get("G")) {
      revimg.curveVertex(x, h - (y * maxh));
      x += scale;
    }
    revimg.endShape();
    x = w;
    revimg.stroke(traceCols[0]);
    revimg.beginShape();
    for (int y : traces.get("T")) {
      revimg.curveVertex(x, h - (y * maxh));
      x += scale;
    }
    revimg.endShape();
    if (bc_check) {
      scale = 0 - scale;
      revimg.textSize(12);
      revimg.textAlign(CENTER);
      for (int i = 0; i < basecalls.length(); i++) {
        String rev_letter = baseRev.get(str(basecalls.charAt(i)));
        revimg.fill(baseCols.get(rev_letter));
        revimg.text(rev_letter, w - basepos.get(i) * scale, 14);
      }
      if (hetPeaks != null) { 
        revimg.textSize(16);
        revimg.textAlign(CENTER);
        for (HetPeak hpk : hetPeaks) {
          String letter = baseRev.get(hpk.getAltPeak().getBase());
          revimg.fill(baseCols.get(letter));
          revimg.text(letter, w - hpk.getAltPeak().getPosition() * scale, 32);
        }
      }
    }
    revimg.endDraw();

    pics[0] = fwdimg;
    pics[1] = revimg;
    return pics;
  }

  PImage[] traceDraw() {
    return this.traceDraw(512, 1, true);
  }

  PImage[] diffDraw(int h, float scale) {
    PImage[] pics = null;
    if (dp != null) {
      int w = int(scale * getLength());
      int dp_baseline = 0;
      pics = new PGraphics[2];
      PGraphics fwdimg = createGraphics(w, h);
      PGraphics revimg = createGraphics(w, h);

      fwdimg.beginDraw();
      fwdimg.background(255);
      fwdimg.noFill();
      float x = 0;
      float plimit = h/2;
      float nlimit = 0 - plimit;
      float maxh = plimit / 500.0;
      fwdimg.pushMatrix();
      fwdimg.translate(0, plimit);
      fwdimg.strokeWeight(1.5);
      fwdimg.stroke(traceCols[0]);
      fwdimg.beginShape();
      for (int y : dp.traces.get("A")) {
        fwdimg.curveVertex(x, constrain(dp_baseline - (y * maxh), nlimit, plimit));
        x += scale;
      }
      fwdimg.endShape();
      x = 0;
      fwdimg.stroke(traceCols[1]);
      fwdimg.beginShape();
      for (int y : dp.traces.get("C")) {
        fwdimg.curveVertex(x, constrain(dp_baseline - (y * maxh), nlimit, plimit));
        x += scale;
      }
      fwdimg.endShape();
      x = 0;
      fwdimg.stroke(traceCols[2]);
      fwdimg.beginShape();
      for (int y : dp.traces.get("G")) {
        fwdimg.curveVertex(x, constrain(dp_baseline - (y * maxh), nlimit, plimit));
        x += scale;
      }
      fwdimg.endShape();
      x = 0;
      fwdimg.stroke(traceCols[4]);
      fwdimg.beginShape();
      for (int y : dp.traces.get("T")) {
        fwdimg.curveVertex(x, constrain(dp_baseline - (y * maxh), nlimit, plimit));
        x += scale;
      }
      fwdimg.endShape();
      /*/QA for bidirectional peak detection
      if (diffPeaks != null) {
        for (PeakPoint pk : diffPeaks) {
          PeakPoint pk2 = pk.getOpposite();
          fwdimg.stroke(baseCols.get(pk.getBase()));
          fwdimg.line(pk.getPosition() * scale, 0, pk.getPosition() * scale, plimit * (0-Math.signum(pk.getValue())));
          fwdimg.stroke(baseCols.get(pk2.getBase()));
          fwdimg.line(pk2.getPosition() * scale, 0, pk2.getPosition() * scale, plimit * (0-Math.signum(pk2.getValue())));
        }
      }*/
      fwdimg.popMatrix();
      fwdimg.endDraw();

      revimg.beginDraw();
      revimg.background(255);
      revimg.noFill();
      revimg.pushMatrix();
      revimg.translate(0, plimit);
      x = w;
      scale = 0 - scale;
      revimg.strokeWeight(1.5);
      revimg.stroke(traceCols[4]);
      revimg.beginShape();
      for (int y : dp.traces.get("A")) {
        revimg.curveVertex(x, constrain(dp_baseline - (y * maxh), nlimit, plimit));
        x += scale;
      }
      revimg.endShape();
      x = w;
      revimg.stroke(traceCols[2]);
      revimg.beginShape();
      for (int y : dp.traces.get("C")) {
        revimg.curveVertex(x, constrain(dp_baseline - (y * maxh), nlimit, plimit));
        x += scale;
      }
      revimg.endShape();
      x = w;
      revimg.stroke(traceCols[1]);
      revimg.beginShape();
      for (int y : dp.traces.get("G")) {
        revimg.curveVertex(x, constrain(dp_baseline - (y * maxh), nlimit, plimit));
        x += scale;
      }
      revimg.endShape();
      x = w;
      revimg.stroke(traceCols[0]);
      revimg.beginShape();
      for (int y : dp.traces.get("T")) {
        revimg.curveVertex(x, constrain(dp_baseline - (y * maxh), nlimit, plimit));
        x += scale;
      }
      revimg.endShape();
      revimg.popMatrix();
      revimg.endDraw();

      pics[0] = fwdimg;
      pics[1] = revimg;
    }
    return pics;
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

  String getFilename() {
    return filename;
  }

  public ArrayList getPeaks() {
    ArrayList<PeakPoint> pks = new ArrayList<PeakPoint>();
    float[] derivs;
    int smoothwidth = 5;
    int slope_threshold = 1;
    float amp_threshold = ymax / 10;
    //int peakgroup = 5;
    //int n = round(peakgroup / 2.0 + 1);
    int len = getLength();
    for (String s : base_order) {
      int[] t = traces.get(s).array();
      derivs = rolling_avg(deriv(t), smoothwidth);
      for (int i = 2*round(smoothwidth / 2.0 - 1); i < len - smoothwidth - 1; i++) {
        if (Math.signum(derivs[i]) > Math.signum(derivs[i+1])) {
          if (derivs[i] - derivs[i+1] > slope_threshold) {
            if (t[i] > amp_threshold) {
              PeakPoint new_peak = new PeakPoint(i, traces.get(s).get(i));
              new_peak.setBase(s);
              pks.add(new_peak);
            }
          }
        }
      }
    }
    pks.sort(new PositionComparator());
    /*for (PeakPoint pk : pks) {
     print (pk.getPosition() + ":" + pk.getValue() + "\t");
     }*/
    return pks;
  }

  public ArrayList<HetPeak> getHetPeaks() {
    if (peaks != null) {
      ArrayList<HetPeak> hpks = new ArrayList<HetPeak>();
      parsed_pos = new IntList();
      for (int i = 0; i < basepos.size() - 1; i++) {
        
      }
      for (int i = 0; i < peaks.size() - 1; i++) {
        PeakPoint pk1 = peaks.get(i);
        PeakPoint pk2 = peaks.get(i+1);
        if (pk2.getPosition() - pk1.getPosition() < 6) {
          if (diffPeaks != null) {
            PeakPoint dpk = findNearestBiPeak(pk1.getPosition());
            if (dpk != null) {
              if (abs(pk1.getPosition() - dpk.getPosition()) < 5 || abs(pk2.getPosition() - dpk.getOpposite().getPosition()) < 5) {
                if (pk1.getBase() == dpk.getBase() && pk2.getBase() == dpk.getOpposite().getBase()) {
                  if (dpk.getValue() < 0) {
                    parsed_calls += pk1.getBase();
                    parsed_pos.append(pk1.getPosition());
                    hpks.add(new HetPeak(pk2, pk1));
                  } else {
                    parsed_calls += pk2.getBase();
                    parsed_pos.append(pk2.getPosition());
                    hpks.add(new HetPeak(pk1, pk2));
                  }
                } else if (pk2.getBase() == dpk.getBase() && pk1.getBase() == dpk.getOpposite().getBase()) {
                  if (dpk.getValue() > 0) {
                    parsed_calls += pk1.getBase();
                    parsed_pos.append(pk1.getPosition());
                    hpks.add(new HetPeak(pk2, pk1));
                  } else {
                    parsed_calls += pk2.getBase();
                    parsed_pos.append(pk2.getPosition());
                    hpks.add(new HetPeak(pk1, pk2));
                  }
                }
                i++;
              }
            } else {
              if (pk1.getValue() > pk2.getValue()) {
                parsed_calls += pk1.getBase();
                parsed_pos.append(pk1.getPosition());
              } else if (pk2.getValue() > pk1.getValue()){
                parsed_calls += pk2.getBase();
                parsed_pos.append(pk2.getPosition());
              }
              i++;
            }
          } else {
            if (pk1.getValue() > pk2.getValue() * 3) {
              parsed_calls += pk1.getBase();
              parsed_pos.append(pk1.getPosition());
            } else if (pk2.getValue() > pk1.getValue() * 3){
              parsed_calls += pk2.getBase();
              parsed_pos.append(pk2.getPosition());
            } else {
              parsed_calls += 'N';
              parsed_pos.append(pk1.getPosition());
              hpks.add(new HetPeak(pk1, pk2));
            }
          }
        } else {
          parsed_calls += pk1.getBase();
          parsed_pos.append(pk1.getPosition());
        }
        //print (pk.getPosition() + ":" + pk.getValue() + "\t");
      }
      return hpks;
    } else {
      return null;
    }
  }

  public PeakPoint findNearestBiPeak(int position) {
    for (int i = 0; i < diffPeaks.size() - 1; i++) {
      int p1 = diffPeaks.get(i).getPosition();
      int p2 = diffPeaks.get(i+1).getPosition();
      if (p1 - 5 < position && position < p2 + 6) {
        if (abs(position - p1) < 6) {
          return diffPeaks.get(i);
        } else if (abs(position - p2) < 6) {
          return diffPeaks.get(i+1);
        } else return null;
      }
    }
    return null;
  }

  public void refsForHets(ABISeqRun ref) {
    if (hetPeaks != null && ref.peaks != null) {
      if (!hetPeaks.isEmpty() && !ref.peaks.isEmpty()) {
        int het_idx = 0;
        int ref_idx = 0;
        int lpos = min(hetPeaks.get(het_idx).getNormalPeak().getValue(), hetPeaks.get(het_idx).getAltPeak().getValue());
        int rpos = max(hetPeaks.get(het_idx).getNormalPeak().getValue(), hetPeaks.get(het_idx).getAltPeak().getValue());
        while (het_idx < hetPeaks.size() && ref_idx < ref.peaks.size()) {
          if (ref.peaks.get(ref_idx).getValue() < lpos - 5) {
            ref_idx += 1;
          } else if (ref.peaks.get(ref_idx).getValue() < rpos + 6) {
            hetPeaks.get(het_idx).setRef(ref.peaks.get(ref_idx));
            het_idx += 1;
            lpos = min(hetPeaks.get(het_idx).getNormalPeak().getValue(), hetPeaks.get(het_idx).getAltPeak().getValue());
            rpos = max(hetPeaks.get(het_idx).getNormalPeak().getValue(), hetPeaks.get(het_idx).getAltPeak().getValue());
          } else {
            het_idx += 1;
            lpos = min(hetPeaks.get(het_idx).getNormalPeak().getValue(), hetPeaks.get(het_idx).getAltPeak().getValue());
            rpos = max(hetPeaks.get(het_idx).getNormalPeak().getValue(), hetPeaks.get(het_idx).getAltPeak().getValue());
          }
        }
      }
    }
  }

  public ArrayList getBidirectionalPeaks() {
    ArrayList<PeakPoint> pks = new ArrayList<PeakPoint>();
    float[] derivs;
    int smoothwidth = 5;
    int slope_threshold = 1;
    float amp_threshold = dp.getPeakValue() / 100;
    //int peakgroup = 5;
    //int n = round(peakgroup / 2.0 + 1);
    int len = getLength();
    for (String s : base_order) {
      int[] t = dp.traces.get(s).array();
      derivs = rolling_avg(deriv(t), smoothwidth);
      for (int i = 2*round(smoothwidth / 2.0 - 1); i < len - smoothwidth - 1; i++) {
        if (Math.signum(derivs[i]) > Math.signum(derivs[i+1])) {
          if (derivs[i] - derivs[i+1] > slope_threshold) {
            if (t[i] > amp_threshold) {
              PeakPoint new_peak = new PeakPoint(i, dp.traces.get(s).get(i));
              new_peak.setBase(s);
              pks.add(new_peak);
            }
          }
        } else if (Math.signum(derivs[i]) < Math.signum(derivs[i+1])) {
          if (derivs[i] - derivs[i+1] < 0 - slope_threshold) {
            if (abs(t[i]) > amp_threshold) {
              PeakPoint new_peak = new PeakPoint(i, dp.traces.get(s).get(i));
              new_peak.setBase(s);
              pks.add(new_peak);
            }
          }
        }
      }
    }
    pks.sort(new PositionComparator());
    ArrayList<PeakPoint> pks_2 = new ArrayList<PeakPoint>();
    for (int i = 0; i < pks.size() - 1; i ++) {
      PeakPoint pk1 = pks.get(i);
      PeakPoint pk2 = pks.get(i+1);
      if (!pk1.hasOpposite() && pk2.getPosition() - pk1.getPosition() < 6 && pk1.getValue() * pk2.getValue() < 0) {
        pk1.setOpposite(pk2);
        pks_2.add(pk1);
      }
      //print (pk.getPosition() + ":" + pk.getValue() + "\t");
    }
    return pks_2;
  }

  public float[] deriv(int[] trace) {
    int len = trace.length;
    float[] d = new float[len];
    d[0] = trace[1] - trace[0];
    d[len-1] = trace[len-1] - trace[len-2];
    for (int i = 1; i < len-1; i++) {
      d[i] = (trace[i+1] - trace[i-1]) / 2;
    }
    return d;
  }

  public float[] moreSmooth(float[] trace, int smoothwidth) {
    return rolling_avg(rolling_avg(trace, smoothwidth), smoothwidth);
  }

  public float[] evenSmoother(float[] trace, int smoothwidth) {
    return rolling_avg(rolling_avg(rolling_avg(trace, smoothwidth), smoothwidth), smoothwidth);
  }

  public float[] rolling_avg(float[] trace, int smoothwidth) {
    int halfwidth = round(smoothwidth / 2.0);
    int len = trace.length;
    float[] smo_trace = new float[len];
    float sumPoints = 0;
    for (int i = 0; i < smoothwidth; i++) {
      sumPoints += trace[i];
    }
    for (int i = 0; i < len - smoothwidth; i++) {
      smo_trace[i + halfwidth - 1] = sumPoints / smoothwidth;
      sumPoints = sumPoints - trace[i] + trace[i+smoothwidth];
    }
    return smo_trace;
  }
}