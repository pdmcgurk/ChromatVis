// Need G4P library
import g4p_controls.*;
import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.lang.Math;
import java.util.LinkedList;
GWindow[] alignSelect = new GWindow[1];
public HashMap<Integer, GWindow> viewers = new HashMap<Integer, GWindow>();
public int keyVal = 0;

public void setup(){
  size(260, 60, JAVA2D);
  frameRate(60);
  createGUI();
  customGUI();
  // Place your setup code here
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  GButton.useRoundCorners(false);
}

public void draw(){
  /*background(230);
  fill(0);
  if (mouseX > 3 && mouseX < 41 && mouseY > 3 && mouseY < 41) {
    text("Open...", 4, 55);
  }*/
}

void openTrace() {
  selectInput("Select a chromatogram file to open...", "traceWindow");
  //traces_to_align();
}

void traces_to_align(){
  alignSelect[0] = GWindow.getWindow(this, "Select traces to align...", 50, 50, 300, 100, JAVA2D);
  alignSelect[0].addData(new FilesData());
  alignSelect[0].setActionOnClose(G4P.CLOSE_WINDOW);
  ((FilesData)alignSelect[0].data).col = 255;
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  ((FilesData)alignSelect[0].data).refField = new GTextField(alignSelect[0], 70, 7, 160, 20, G4P.SCROLLBARS_NONE);
  GButton refBrowse = new GButton(alignSelect[0], 233, 7, 60, 21, "Browse...");
  ((FilesData)alignSelect[0].data).refField.setPromptText("Select a reference...");
  ((FilesData)alignSelect[0].data).refField.setOpaque(true);
  refBrowse.addEventHandler(this, "refField_change1");
  ((FilesData)alignSelect[0].data).testField = new GTextField(alignSelect[0], 70, 37, 160, 20, G4P.SCROLLBARS_NONE);
  GButton testBrowse = new GButton(alignSelect[0], 233, 37, 60, 21, "Browse...");
  ((FilesData)alignSelect[0].data).testField.setPromptText("Select trace to align...");
  ((FilesData)alignSelect[0].data).testField.setOpaque(true);
  testBrowse.addEventHandler(this, "testField_change1");
  GButton executor = new GButton(alignSelect[0], 100, 65, 100, 21, "Align Traces");
  executor.addEventHandler(this, "start_align");
  alignSelect[0].addDrawHandler(this, "fileSelectorDraw");
}

void fileSelectorDraw(PApplet appc, GWinData data){
  appc.background(204, 204, 230);
  appc.textAlign(RIGHT);
  appc.fill(0);
  appc.text("Reference:", 68, 20);
  appc.text("Query:", 68, 50);
}

//EVENT HANDLERS FOR ALIGNMENT FILE SELECT WINDOW
public void refField_change1(GButton source, GEvent event) { //_CODE_:textfield3:465123:
  println("refField - GTextField >> GEvent." + event + " @ " + millis());
  if (event.toString() == "CLICKED") {
    selectInput("Select a reference", "fillRefField");
  }
} //_CODE_:textfield3:465123:

public void testField_change1(GButton source, GEvent event) { //_CODE_:testField:477974:
  println("testField - GTextField >> GEvent." + event + " @ " + millis());
  if (event.toString() == "CLICKED") {
    selectInput("Select a reference", "fillTestField");
  }
} //_CODE_:testField:477974:

public void start_align(GButton source, GEvent event) {
  if ((event.toString() == "CLICKED") && (((FilesData)alignSelect[0].data).ref != null) && (((FilesData)alignSelect[0].data).test != null)) {
    alignSelect[0].close();
    alignWindow((FilesData)alignSelect[0].data);
  } else {
    println("booooooooooooo");
  }
}

void fillRefField (File selected){
  ((FilesData)alignSelect[0].data).refField.setText("");
  ((FilesData)alignSelect[0].data).ref = null;
  if (selected != null) {
    ((FilesData)alignSelect[0].data).ref = selected;
    ((FilesData)alignSelect[0].data).refField.setText(selected.getName());
  }
}

void fillTestField (File selected){
  ((FilesData)alignSelect[0].data).testField.setText("");
  ((FilesData)alignSelect[0].data).test = null;
  if (selected != null) {
    ((FilesData)alignSelect[0].data).test = selected;
    ((FilesData)alignSelect[0].data).testField.setText(selected.getName());
  }
}
 
//WINDOW GENERATORS FOR OPEN and ALIGN COMMANDS
void traceWindow(File selected){
  if (selected != null) {
    //set up window
    GWindow win = GWindow.getWindow(this, selected.getName(), 100, 100, 1024, 572, JAVA2D);
    win.setActionOnClose(G4P.CLOSE_WINDOW);
    viewers.put(keyVal, win);
    win.addData(new TraceWinData());
    ((TraceWinData)win.data).viewer_number = keyVal;
    ((TraceWinData)win.data).sx = 1024;
    ((TraceWinData)win.data).sy = 512;
    ((TraceWinData)win.data).col = 255;
    
    //read file into ABISeqRun object
    InputStream ins = createInput(selected);
    DataInputStream traceFile = new DataInputStream(new BufferedInputStream(ins));
    traceFile.mark(int(pow(2, 32) - 1));
    ((TraceWinData)win.data).chromat1 = new ABISeqRun(selected);
    try {
      ins.close();
      traceFile.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
    
    //build UI elements
    ((TraceWinData)win.data).imgExport = new GImageButton(win, 40, 4, new String[] { "allblack.png", "allblack.png", "allblack.png" } , "allblack.png");
    //((TraceWinData)win.data).imgExport.addEventHandler(win, "imgExport_click1");
    ((TraceWinData)win.data).rc_check = new GCheckbox(win, 74, 0, 24, 20);
    ((TraceWinData)win.data).rc_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    //((TraceWinData)win.data).rc_check.setText("Reverse complement");
    ((TraceWinData)win.data).rc_check.setOpaque(false);
    //((TraceWinData)win.data).rc_check.addEventHandler(win, "rc_check_clicked1");
    ((TraceWinData)win.data).name_check = new GCheckbox(win, 216, 0, 24, 20);
    ((TraceWinData)win.data).name_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    //((TraceWinData)win.data).name_check.setText("Show filenames");
    ((TraceWinData)win.data).name_check.setOpaque(false);
    //((TraceWinData)win.data).name_check.addEventHandler(win, "name_check_clicked1");
    ((TraceWinData)win.data).name_check.setSelected(true);
    ((TraceWinData)win.data).bc_check = new GCheckbox(win, 216, 20, 24, 20);
    ((TraceWinData)win.data).bc_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    //((TraceWinData)win.data).bc_check.setText("Show basecalls");
    ((TraceWinData)win.data).bc_check.setOpaque(false);
    //((TraceWinData)win.data).bc_check.addEventHandler(win, "bc_check_clicked1");
    ((TraceWinData)win.data).bc_check.setSelected(true);
    ((TraceWinData)win.data).scaler = new ScaleSlider(win, 124, 20, 90, 20, 10);
    ((TraceWinData)win.data).scaler.setLimits(0.0, 0.0, 4.0);
    ((TraceWinData)win.data).scaler.setNbrTicks(4);
    ((TraceWinData)win.data).scaler.setNumberFormat(G4P.DECIMAL, 1);
    ((TraceWinData)win.data).scaler.setOpaque(false);
    ((TraceWinData)win.data).scaler.addEventHandler(this, "scaler_change1");
    ((TraceWinData)win.data).baseExport = new GImageButton(win, 326, 4, new String[] { "allblack.png", "allblack.png", "allblack.png" } , "allblack.png");
    //((TraceWinData)win.data).baseExport.addEventHandler(win, "baseExport_click1");
    ((TraceWinData)win.data).dp_check = new GCheckbox(win, 360, 0, 24, 20);
    //((TraceWinData)win.data).dp_check.setText("Show difference profile");
    ((TraceWinData)win.data).dp_check.setOpaque(false);
    //((TraceWinData)win.data).dp_check.addEventHandler(win, "dp_check_clicked1");
    ((TraceWinData)win.data).sub_check = new GCheckbox(win, 360, 20, 24, 20);
    ((TraceWinData)win.data).sub_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    //((TraceWinData)win.data).sub_check.setText("Parse heterozygous sequences");
    ((TraceWinData)win.data).sub_check.setOpaque(false);
    //((TraceWinData)win.data).sub_check.addEventHandler(win, "sub_check_clicked1");
    ((TraceWinData)win.data).resizeButton = new ResizeButton(win, 4, 4);
    ((TraceWinData)win.data).resizeButton.addEventHandler(this, "resizeButton_click1");
    ((TraceWinData)win.data).scroller = new GSlider(win, 0, ((TraceWinData)win.data).sy + 40, ((TraceWinData)win.data).sx, 20, 20.0);
    ((TraceWinData)win.data).scroller.setLimits(0.0, 0.0, 1.0);
    ((TraceWinData)win.data).scroller.setNumberFormat(G4P.DECIMAL, 2);
    ((TraceWinData)win.data).scroller.setOpaque(false);
    //((TraceWinData)win.data).scroller.addEventHandler(win, "slider1_change1");
    
    //build resize control elements
    ((TraceWinData)win.data).resizePanel = new GPanel(win, 168, 320, 128, 104, "Set image dimensions...");
    ((TraceWinData)win.data).resizePanel.setCollapsible(false);
    ((TraceWinData)win.data).resizePanel.setText("Set image dimensions...");
    ((TraceWinData)win.data).resizePanel.setOpaque(true);
    //((TraceWinData)win.data).resizePanel.addEventHandler(win, "resizePanel_Click1");
    ((TraceWinData)win.data).wField = new GTextField(win, 56, 24, 30, 20, G4P.SCROLLBARS_NONE);
    ((TraceWinData)win.data).wField.setPromptText("w");
    ((TraceWinData)win.data).wField.setOpaque(true);
    //((TraceWinData)win.data).wField.addEventHandler(win, "wField_change1");
    ((TraceWinData)win.data).hField = new GTextField(win, 56, 48, 30, 20, G4P.SCROLLBARS_NONE);
    ((TraceWinData)win.data).hField.setPromptText("h");
    ((TraceWinData)win.data).hField.setOpaque(true);
    //((TraceWinData)win.data).hField.addEventHandler(win, "hField_change1");
    ((TraceWinData)win.data).wide = new GLabel(win, 16, 24, 40, 20);
    ((TraceWinData)win.data).wide.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
    ((TraceWinData)win.data).wide.setText("Width:");
    ((TraceWinData)win.data).wide.setOpaque(false);
    ((TraceWinData)win.data).high = new GLabel(win, 6, 48, 50, 20);
    ((TraceWinData)win.data).high.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
    ((TraceWinData)win.data).high.setText("Height:");
    ((TraceWinData)win.data).high.setOpaque(false);
    ((TraceWinData)win.data).px1 = new GLabel(win, 88, 24, 20, 20);
    ((TraceWinData)win.data).px1.setText("px");
    ((TraceWinData)win.data).px1.setOpaque(false);
    ((TraceWinData)win.data).px2 = new GLabel(win, 88, 48, 20, 20);
    ((TraceWinData)win.data).px2.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    ((TraceWinData)win.data).px2.setText("px");
    ((TraceWinData)win.data).px2.setOpaque(false);
    ((TraceWinData)win.data).executeResize = new ResizeExecutor(win, 6, 72);
    ((TraceWinData)win.data).executeResize.addEventHandler(this, "resizeGo");
    ((TraceWinData)win.data).cancelResize = new CancelButton(win, 68, 72);
    ((TraceWinData)win.data).cancelResize.addEventHandler(this, "cancelResize_click1");
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).wField);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).hField);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).wide);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).high);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).px1);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).px2);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).executeResize);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).cancelResize);
    ((TraceWinData)win.data).resizePanel.setVisible(false);
    
    ((ScaleSlider)((TraceWinData)win.data).scaler).setViewer(keyVal);
    ((ResizeButton)((TraceWinData)win.data).resizeButton).setViewer(keyVal);
    ((CancelButton)((TraceWinData)win.data).cancelResize).setViewer(keyVal);
    ((ResizeExecutor)((TraceWinData)win.data).executeResize).setViewer(keyVal);
    
    //add handlers for window
    win.addDrawHandler(this, "drawTraces");
    win.addMouseHandler(this, "scrollControl");
    
    keyVal++;
  }
}

//CONSTRUCTOR FOR COPYING WINDOWS
void traceWindow(TraceWinData data_to_copy){
  int vn = data_to_copy.getViewer();
  float scale = data_to_copy.scaler.getValueF();
  float scroll = data_to_copy.scroller.getValueF();
  Boolean rc = data_to_copy.rc_check.isSelected();
  Boolean fnames = data_to_copy.name_check.isSelected();
  Boolean bc = data_to_copy.bc_check.isSelected();
  Boolean dp = data_to_copy.dp_check.isSelected();
  Boolean parse = data_to_copy.sub_check.isSelected();
  
  GWindow oldwin = viewers.get(vn);
  //set up window
  GWindow win = GWindow.getWindow(this, data_to_copy.chromat1.getFilename(), 100, 100, data_to_copy.ex, data_to_copy.ey + 60, JAVA2D);
  win.setActionOnClose(G4P.CLOSE_WINDOW);
  win.addData(data_to_copy);
  viewers.put(vn, win);
  oldwin.close();
  
  //update data and redraw traces
  ((TraceWinData)win.data).sx = ((TraceWinData)win.data).ex;
  ((TraceWinData)win.data).sy = ((TraceWinData)win.data).ey;
  ((TraceWinData)win.data).chromat1.tracePics = ((TraceWinData)win.data).chromat1.traceDraw(((TraceWinData)win.data).sy, scale + 1);
  
  //build UI elements
  ((TraceWinData)win.data).imgExport = new GImageButton(win, 40, 4, new String[] { "allblack.png", "allblack.png", "allblack.png" } , "allblack.png");
  //((TraceWinData)win.data).imgExport.addEventHandler(win, "imgExport_click1");
  ((TraceWinData)win.data).rc_check = new GCheckbox(win, 74, 0, 24, 20);
  ((TraceWinData)win.data).rc_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  //((TraceWinData)win.data).rc_check.setText("Reverse complement");
  ((TraceWinData)win.data).rc_check.setOpaque(false);
  ((TraceWinData)win.data).rc_check.setSelected(rc);
  //((TraceWinData)win.data).rc_check.addEventHandler(win, "rc_check_clicked1");
  ((TraceWinData)win.data).name_check = new GCheckbox(win, 216, 0, 24, 20);
  ((TraceWinData)win.data).name_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  //((TraceWinData)win.data).name_check.setText("Show filenames");
  ((TraceWinData)win.data).name_check.setOpaque(false);
  //((TraceWinData)win.data).name_check.addEventHandler(win, "name_check_clicked1");
  ((TraceWinData)win.data).name_check.setSelected(fnames);
  ((TraceWinData)win.data).bc_check = new GCheckbox(win, 216, 20, 24, 20);
  ((TraceWinData)win.data).bc_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  //((TraceWinData)win.data).bc_check.setText("Show basecalls");
  ((TraceWinData)win.data).bc_check.setOpaque(false);
  //((TraceWinData)win.data).bc_check.addEventHandler(win, "bc_check_clicked1");
  ((TraceWinData)win.data).bc_check.setSelected(bc);
  ((TraceWinData)win.data).scaler = new ScaleSlider(win, 124, 20, 90, 20, 10);
  ((TraceWinData)win.data).scaler.setLimits(scale, 0.0, 4.0);
  ((TraceWinData)win.data).scaler.setNbrTicks(4);
  ((TraceWinData)win.data).scaler.setNumberFormat(G4P.DECIMAL, 1);
  ((TraceWinData)win.data).scaler.setOpaque(false);
  ((TraceWinData)win.data).scaler.addEventHandler(this, "scaler_change1");
  ((TraceWinData)win.data).baseExport = new GImageButton(win, 326, 4, new String[] { "allblack.png", "allblack.png", "allblack.png" } , "allblack.png");
  //((TraceWinData)win.data).baseExport.addEventHandler(win, "baseExport_click1");
  ((TraceWinData)win.data).dp_check = new GCheckbox(win, 360, 0, 24, 20);
  //((TraceWinData)win.data).dp_check.setText("Show difference profile");
  ((TraceWinData)win.data).dp_check.setOpaque(false);
  ((TraceWinData)win.data).dp_check.setSelected(dp);
  //((TraceWinData)win.data).dp_check.addEventHandler(win, "dp_check_clicked1");
  ((TraceWinData)win.data).sub_check = new GCheckbox(win, 360, 20, 24, 20);
  ((TraceWinData)win.data).sub_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  //((TraceWinData)win.data).sub_check.setText("Parse heterozygous sequences");
  ((TraceWinData)win.data).sub_check.setOpaque(false);
  ((TraceWinData)win.data).sub_check.setSelected(parse);
  //((TraceWinData)win.data).sub_check.addEventHandler(win, "sub_check_clicked1");
  ((TraceWinData)win.data).resizeButton = new ResizeButton(win, 4, 4);
  ((TraceWinData)win.data).resizeButton.addEventHandler(this, "resizeButton_click1");
  ((TraceWinData)win.data).scroller = new GSlider(win, 0, ((TraceWinData)win.data).sy + 40, ((TraceWinData)win.data).sx, 20, 20.0);
  ((TraceWinData)win.data).scroller.setLimits(scroll, 0.0, 1.0);
  ((TraceWinData)win.data).scroller.setNumberFormat(G4P.DECIMAL, 2);
  ((TraceWinData)win.data).scroller.setOpaque(false);
  //((TraceWinData)win.data).scroller.addEventHandler(win, "slider1_change1");
  
  //build resize control elements
  ((TraceWinData)win.data).resizePanel = new GPanel(win, 168, 320, 128, 104, "Set image dimensions...");
  ((TraceWinData)win.data).resizePanel.setCollapsible(false);
  ((TraceWinData)win.data).resizePanel.setText("Set image dimensions...");
  ((TraceWinData)win.data).resizePanel.setOpaque(true);
  //((TraceWinData)win.data).resizePanel.addEventHandler(win, "resizePanel_Click1");
  ((TraceWinData)win.data).wField = new GTextField(win, 56, 24, 30, 20, G4P.SCROLLBARS_NONE);
  ((TraceWinData)win.data).wField.setPromptText("w");
  ((TraceWinData)win.data).wField.setOpaque(true);
  //((TraceWinData)win.data).wField.addEventHandler(win, "wField_change1");
  ((TraceWinData)win.data).hField = new GTextField(win, 56, 48, 30, 20, G4P.SCROLLBARS_NONE);
  ((TraceWinData)win.data).hField.setPromptText("h");
  ((TraceWinData)win.data).hField.setOpaque(true);
  //((TraceWinData)win.data).hField.addEventHandler(win, "hField_change1");
  ((TraceWinData)win.data).wide = new GLabel(win, 16, 24, 40, 20);
  ((TraceWinData)win.data).wide.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  ((TraceWinData)win.data).wide.setText("Width:");
  ((TraceWinData)win.data).wide.setOpaque(false);
  ((TraceWinData)win.data).high = new GLabel(win, 6, 48, 50, 20);
  ((TraceWinData)win.data).high.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  ((TraceWinData)win.data).high.setText("Height:");
  ((TraceWinData)win.data).high.setOpaque(false);
  ((TraceWinData)win.data).px1 = new GLabel(win, 88, 24, 20, 20);
  ((TraceWinData)win.data).px1.setText("px");
  ((TraceWinData)win.data).px1.setOpaque(false);
  ((TraceWinData)win.data).px2 = new GLabel(win, 88, 48, 20, 20);
  ((TraceWinData)win.data).px2.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  ((TraceWinData)win.data).px2.setText("px");
  ((TraceWinData)win.data).px2.setOpaque(false);
  ((TraceWinData)win.data).executeResize = new ResizeExecutor(win, 6, 72);
  ((TraceWinData)win.data).executeResize.addEventHandler(this, "resizeGo");
  ((TraceWinData)win.data).cancelResize = new CancelButton(win, 68, 72);
  ((TraceWinData)win.data).cancelResize.addEventHandler(this, "cancelResize_click1");
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).wField);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).hField);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).wide);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).high);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).px1);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).px2);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).executeResize);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).cancelResize);
  ((TraceWinData)win.data).resizePanel.setVisible(false);
    
  ((ScaleSlider)((TraceWinData)win.data).scaler).setViewer(vn);
  ((ResizeButton)((TraceWinData)win.data).resizeButton).setViewer(vn);
  ((CancelButton)((TraceWinData)win.data).cancelResize).setViewer(vn);
  ((ResizeExecutor)((TraceWinData)win.data).executeResize).setViewer(vn);
  
  //add handlers for window
  win.addDrawHandler(this, "drawTraces");
  win.addMouseHandler(this, "scrollControl");
}

void alignWindow(FilesData data) {
  FilesData data2 = (FilesData)data;
  GWindow[] win = new GWindow[1];
  
  //set up window  
  win[0] = GWindow.getWindow(this, "Alignment: " + data2.ref.getName() + " to " + data2.test.getName(), 100, 100, 1024, 552, JAVA2D);
  win[0].addData(new TraceWinData());
  ((TraceWinData)win[0].data).sx = 1024;
  ((TraceWinData)win[0].data).sy = 512;
  
  
  //read files into ABISeqRun objects
  /*InputStream refin = createInput(data2.ref);
  InputStream testin = createInput(data2.test);
  DataInputStream refFile = new DataInputStream(new BufferedInputStream(refin));
  DataInputStream testFile = new DataInputStream(new BufferedInputStream(testin));
  refFile.mark(int(pow(2, 32) - 1));
  testFile.mark(int(pow(2, 32) - 1));*/
  ((TraceWinData)win[0].data).chromat1 = new ABISeqRun(data2.ref);
  ((TraceWinData)win[0].data).chromat2 = new ABISeqRun(data2.test);
  /*try {
    refin.close();
    testin.close();
    refFile.close();
    testFile.close();
  } catch (IOException e) {
    e.printStackTrace();
  }*/
  //make aligned trace
  ((TraceWinData)win[0].data).chromat3 = ((TraceWinData)win[0].data).chromat2.get_best_align(((TraceWinData)win[0].data).chromat1);
  //make difference profile
  ((TraceWinData)win[0].data).dp = ((TraceWinData)win[0].data).chromat3.diff_profile(((TraceWinData)win[0].data).chromat1);
  //build UI elements
  ((TraceWinData)win[0].data).dp_check = new GCheckbox (win[0], 600, 0, 300, 20, "Show difference profile");
  ((TraceWinData)win[0].data).scroller = new GSlider (win[0], 0, win[0].height - 20, win[0].width, 20, 20);
  ((TraceWinData)win[0].data).scroller.setNumberFormat(G4P.DECIMAL, 2);
  ((TraceWinData)win[0].data).scroller.setLimits(0.0, 0.0, 1.0);
  ((TraceWinData)win[0].data).scaler = new GSlider (win[0], 100, 5, 100, 10, 8);
  ((TraceWinData)win[0].data).scaler.setNumberFormat(G4P.DECIMAL);
  ((TraceWinData)win[0].data).scaler.setLimits(0.0, 0.0, 4.0);
  ((TraceWinData)win[0].data).rc_check = new GCheckbox (win[0], 300, 0, 300, 20, "Reverse complement");
  win[0].addDrawHandler(this, "drawTraces");
  win[0].addMouseHandler(this, "scrollControl");
}
//DISPLAY WINDOW MOUSE WHEEL HANDLER
void scrollControl(PApplet appc, GWinData data, MouseEvent event){
  TraceWinData data2 = (TraceWinData)data;
  switch(event.getAction()) {
    case MouseEvent.WHEEL:
      ((TraceWinData)data).scroller.setValue(constrain(data2.scroller.getValueF() + (event.getCount()/50.0), data2.scroller.getStartLimit(), data2.scroller.getEndLimit()));
  }  
}
//CONTAINER CLASSES TO HOLD WINDOW DATA
class MyWinData extends GWinData {
  int sx, sy, ex, ey;
  int col;
}

/*public class TraceWinData extends MyWinData {
  ABISeqRun chromat1, chromat2, chromat3;
  HashMap<String, IntList> dp;
  GImageButton imgExport, baseExport, resizeButton;
  GCheckbox dp_check, rc_check, name_check, bc_check, sub_check;
  GSlider scroller, scaler;
  GPanel resizePanel;
  GTextField wField, hField;
  GButton executeResize, cancelResize;
  GLabel wide, high, px1, px2;
}

public class FilesData extends MyWinData {
  GTextField refField, testField;
  File ref, test;
}*/

//CHROMATOGRAM WINDOW DRAW HANDLER
void drawTraces(PApplet appc, GWinData data) {
  TraceWinData data2 = (TraceWinData)data;
  //int eff_h = appc.height - 40;
  appc.background(255);
  appc.noFill();
  appc.pushMatrix();
  //if how many panes?
  //control RC with chromat.tracePics[data2.rc_check.isSelected()]
  int x_val = data2.chromat1.tracePics[0].width; //max(data2.chromat1.getLength(),data2.chromat2.getLength(),data2.chromat3.getLength())
  appc.translate(0 - data2.scroller.getValueF() * x_val, 40);
  appc.image(data2.chromat1.tracePics[int(data2.rc_check.isSelected())], 0, 00);
  appc.popMatrix();
  appc.fill(150,150,255);
  appc.noStroke();
  appc.rect(0, 0, appc.width, 40);
  appc.fill(0);
  appc.text("X-scale:", 78, 34);
  appc.text("Reverse complement", 92, 14);
  appc.text("Show filenames", 234, 14);
  appc.text("Show basecalls", 234, 34);
  appc.text("Show difference profile", 380, 14);
  appc.text("Parse heterozygous sequences", 380, 34);
}
  
//UI CONTROL EVENT HANDLERS
public void resizeButton_click1(ResizeButton source, GEvent event) { //_CODE_:resizeButton:451682:
  println("ResizeButton1 - GImageButton >> GEvent." + event + " @ " + millis());
  ((TraceWinData)viewers.get(source.getViewer()).data).resizePanel.setVisible(true);
}

public void cancelResize_click1(CancelButton source, GEvent event) { //_CODE_:resizeButton:451682:
  println("cancelResize1 - GImageButton >> GEvent." + event + " @ " + millis());
  ((TraceWinData)viewers.get(source.getViewer()).data).resizePanel.setVisible(false);
}

public void resizeGo(ResizeExecutor source, GEvent event) { //_CODE_:resizeButton:451682:
  println("resizeGo1 - GImageButton >> GEvent." + event + " @ " + millis());
  int vn = source.getViewer();
  int x = int(((TraceWinData)viewers.get(vn).data).wField.getText());
  int y = int(((TraceWinData)viewers.get(vn).data).hField.getText());
  if (x > 0 && y > 0) {
    ((TraceWinData)viewers.get(vn).data).resizePanel.setVisible(false);
    ((TraceWinData)viewers.get(vn).data).ex = x;
    ((TraceWinData)viewers.get(vn).data).ey = y;
    println("create a new "+((TraceWinData)viewers.get(vn).data).ex+" x "+((TraceWinData)viewers.get(vn).data).ey+" window.");
    traceWindow((TraceWinData)viewers.get(vn).data);
  }
}

public void scaler_change1(ScaleSlider source, GEvent event){
  println("scaler_change1 - " + (source.getValueF() + 1) +" >> GEvent." + event + " @ " + millis());
  if (event.toString() == "VALUE_STEADY") {
    int h = ((TraceWinData)viewers.get(source.getViewer()).data).sy;
    ((TraceWinData)viewers.get(source.getViewer()).data).chromat1.tracePics = ((TraceWinData)viewers.get(source.getViewer()).data).chromat1.traceDraw(h, source.getValueF() + 1);
  }
}
// Use this method to add additional statements
// to customise the GUI controls
public void customGUI(){

}