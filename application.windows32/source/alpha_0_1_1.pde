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

// Need G4P library
import g4p_controls.*;
import java.io.*;
import java.nio.file.*;
import javax.imageio.*;
import javax.imageio.stream.*;
import java.awt.image.BufferedImage;
import java.lang.Math;
import java.util.LinkedList;
import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;

GWindow[] alignSelect = new GWindow[1];
public HashMap<Integer, GWindow> viewers = new HashMap<Integer, GWindow>();
public int keyVal = 0;
public JFileChooser chooser = new JFileChooser();
public FileNameExtensionFilter openFilter = new FileNameExtensionFilter("ABI chromatogram files", "ab1");
public FileNameExtensionFilter[] saveFilters = new FileNameExtensionFilter[4];
public FileNameExtensionFilter jpgFilter = new FileNameExtensionFilter("JPEG images", "jpg", "jpeg");
public FileNameExtensionFilter pngFilter = new FileNameExtensionFilter("PNG images", "png");
public FileNameExtensionFilter tgaFilter = new FileNameExtensionFilter("TGA images", "tga");
public FileNameExtensionFilter tifFilter = new FileNameExtensionFilter("TIFF images", "tif", "tiff");
public FileNameExtensionFilter txtFilter = new FileNameExtensionFilter("Text documents", "txt");
public File exportFile = null;

public void setup(){
  size(224, 40, JAVA2D);
  frameRate(30);
  createGUI();
  customGUI();
  // Place your setup code here
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  GButton.useRoundCorners(false);
  saveFilters[0] = jpgFilter;
  saveFilters[1] = pngFilter;
  saveFilters[2] = tgaFilter;
  saveFilters[3] = tifFilter;
}

public void draw(){
  /*background(230);
  fill(0);
  if (mouseX > 3 && mouseX < 41 && mouseY > 3 && mouseY < 41) {
    text("Open...", 4, 55);
  }*/
}

void openTrace() {
  //selectInput("Select a chromatogram file to open...", "traceWindow");
  traces_to_align();
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
    selectInput("Select a reference sequence file", "fillRefField");
  }
} //_CODE_:textfield3:465123:

public void testField_change1(GButton source, GEvent event) { //_CODE_:testField:477974:
  println("testField - GTextField >> GEvent." + event + " @ " + millis());
  if (event.toString() == "CLICKED") {
    selectInput("Select a query sequence to align to reference", "fillTestField");
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
    String tempStr = selected.getName();
    GWindow win = GWindow.getWindow(this, tempStr, 100, 100, 1024, 572, JAVA2D);
    win.setActionOnClose(G4P.CLOSE_WINDOW);
    viewers.put(keyVal, win);
    win.addData(new TraceWinData());
    ((TraceWinData)win.data).viewer_number = keyVal;
    ((TraceWinData)win.data).sx = 1024;
    ((TraceWinData)win.data).sy = 512;
    ((TraceWinData)win.data).col = 255;
    ((TraceWinData)win.data).titleStr = tempStr;
    
    //read file into ABISeqRun object
    //InputStream ins = createInput(selected);
    //DataInputStream traceFile = new DataInputStream(new BufferedInputStream(ins));
    //traceFile.mark(int(pow(2, 32) - 1));
    ((TraceWinData)win.data).chromat1 = new ABISeqRun(selected);
    ((TraceWinData)win.data).chromat1.peaks = ((TraceWinData)win.data).chromat1.getPeaks();
    ((TraceWinData)win.data).chromat1.tracePics = ((TraceWinData)win.data).chromat1.traceDraw();
    /*try {
      ins.close();
      traceFile.close();
    } catch (IOException e) {
      e.printStackTrace();
    }*/
    
    //build frame elements and toggles
    ((TraceWinData)win.data).resizeButton = new ResizeButton(win, 4, 4);
    ((TraceWinData)win.data).resizeButton.addEventHandler(this, "resizeButton_click1");
    ((TraceWinData)win.data).imgExport = new ImageExportButton(win, 40, 4);
    ((TraceWinData)win.data).imgExport.addEventHandler(this, "imgExport_click1");
    ((TraceWinData)win.data).baseExport = new BaseExportButton(win, 76, 4); //was 326
    ((TraceWinData)win.data).baseExport.addEventHandler(this, "baseExport_click1");
    ((TraceWinData)win.data).rc_check = new GCheckbox(win, 110, 0, 24, 20); //was 74
    ((TraceWinData)win.data).rc_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    ((TraceWinData)win.data).rc_check.setOpaque(false);
      ((TraceWinData)win.data).name_check = new GCheckbox(win, 216, 0, 24, 20);
      ((TraceWinData)win.data).name_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
      ((TraceWinData)win.data).name_check.setVisible(false);
      ((TraceWinData)win.data).name_check.setOpaque(false);
      //((TraceWinData)win.data).name_check.addEventHandler(win, "name_check_clicked1");
      ((TraceWinData)win.data).name_check.setSelected(true);
      ((TraceWinData)win.data).bc_check = new BCCheckbox(win, 216, 20, 24, 20);
      ((TraceWinData)win.data).bc_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
      ((TraceWinData)win.data).bc_check.setVisible(false);
      ((TraceWinData)win.data).bc_check.setOpaque(false);
      ((TraceWinData)win.data).bc_check.addEventHandler(this, "bc_check_clicked1");
      ((TraceWinData)win.data).bc_check.setSelected(true);
    ((TraceWinData)win.data).scaler = new ScaleSlider(win, 272, 20, 60, 15, 10); //was 124 & 90 px long
    ((TraceWinData)win.data).scaler.setLimits(0.0, 0.0, 4.0);
    ((TraceWinData)win.data).scaler.setNbrTicks(4);
    ((TraceWinData)win.data).scaler.setNumberFormat(G4P.DECIMAL, 1);
    ((TraceWinData)win.data).scaler.setOpaque(false);
    ((TraceWinData)win.data).scaler.addEventHandler(this, "scaler_change1");
    ((TraceWinData)win.data).dp_check = new DPCheckbox(win, 110, 20, 24, 20); //was 360,0
    ((TraceWinData)win.data).dp_check.setOpaque(false);
    ((TraceWinData)win.data).dp_check.addEventHandler(this, "dp_check_clicked1");
      ((TraceWinData)win.data).sub_check = new GCheckbox(win, 360, 20, 24, 20);
      ((TraceWinData)win.data).sub_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
      ((TraceWinData)win.data).sub_check.setVisible(false);
      ((TraceWinData)win.data).sub_check.setOpaque(false);
      //((TraceWinData)win.data).sub_check.addEventHandler(win, "sub_check_clicked1");
    ((TraceWinData)win.data).scroller = new GSlider(win, 0, ((TraceWinData)win.data).sy + 40, ((TraceWinData)win.data).sx, 20, 20.0);
    ((TraceWinData)win.data).scroller.setLimits(0.0, 0.0, 1.0);
    ((TraceWinData)win.data).scroller.setNumberFormat(G4P.DECIMAL, 2);
    ((TraceWinData)win.data).scroller.setOpaque(false);
    
    //build resize control elements
    ((TraceWinData)win.data).resizePanel = new GPanel(win, win.width / 2 - 70, win.height / 2 - 52, 140, 104, "Set image dimensions...");
    ((TraceWinData)win.data).resizePanel.setCollapsible(false);
    ((TraceWinData)win.data).resizePanel.setText("Set image dimensions...");
    ((TraceWinData)win.data).resizePanel.setOpaque(true);
    ((TraceWinData)win.data).wField = new GTextField(win, 56, 24, 40, 20, G4P.SCROLLBARS_NONE);
    ((TraceWinData)win.data).wField.setPromptText(str(((TraceWinData)win.data).sx));
    ((TraceWinData)win.data).wField.setOpaque(true);
    ((TraceWinData)win.data).hField = new GTextField(win, 56, 48, 40, 20, G4P.SCROLLBARS_NONE);
    ((TraceWinData)win.data).hField.setPromptText(str(((TraceWinData)win.data).sy));
    ((TraceWinData)win.data).hField.setOpaque(true);
    ((TraceWinData)win.data).wide = new GLabel(win, 16, 24, 40, 20);
    ((TraceWinData)win.data).wide.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
    ((TraceWinData)win.data).wide.setText("Width:");
    ((TraceWinData)win.data).wide.setOpaque(false);
    ((TraceWinData)win.data).high = new GLabel(win, 6, 48, 50, 20);
    ((TraceWinData)win.data).high.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
    ((TraceWinData)win.data).high.setText("Height:");
    ((TraceWinData)win.data).high.setOpaque(false);
    ((TraceWinData)win.data).px1 = new GLabel(win, 94, 24, 20, 20);
    ((TraceWinData)win.data).px1.setText("px");
    ((TraceWinData)win.data).px1.setOpaque(false);
    ((TraceWinData)win.data).px2 = new GLabel(win, 94, 48, 20, 20);
    ((TraceWinData)win.data).px2.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    ((TraceWinData)win.data).px2.setText("px");
    ((TraceWinData)win.data).px2.setOpaque(false);
    ((TraceWinData)win.data).executeResize = new ResizeExecutor(win, 12, 82);
    ((TraceWinData)win.data).executeResize.addEventHandler(this, "resizeGo");
    ((TraceWinData)win.data).cancelResize = new CancelButton(win, 80, 82);
    ((TraceWinData)win.data).cancelResize.addEventHandler(this, "cancelButton_click1");
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).wField);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).hField);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).wide);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).high);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).px1);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).px2);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).executeResize);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).cancelResize);
    ((TraceWinData)win.data).resizePanel.setVisible(false);
    
    //build image export control elements
    ((TraceWinData)win.data).imgExportPanel = new GPanel(win, win.width / 2 - 110, win.height / 2 - 45, 220, 90, "Export as...");
    ((TraceWinData)win.data).imgExportPanel.setText("Export as...");
    ((TraceWinData)win.data).imgExportPanel.setOpaque(true);
    ((TraceWinData)win.data).xres_check = new XRCheckbox(win, 2, 40, 24, 20);
    ((TraceWinData)win.data).xres_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    ((TraceWinData)win.data).xres_check.setOpaque(false);
    ((TraceWinData)win.data).xres_check.addEventHandler(this, "xres_check_clicked1");
    ((TraceWinData)win.data).resList = new GDropList(win, 105, 40, 30, 100, 4);
    ((TraceWinData)win.data).resList.setItems(loadStrings("extra.txt"), 0);
    ((TraceWinData)win.data).resList.setVisible(false);
    ((TraceWinData)win.data).fmtList = new GDropList(win, 178, 40, 40, 100, 4);
    ((TraceWinData)win.data).fmtList.setItems(loadStrings("format.txt"), 0);
    ((TraceWinData)win.data).ielabel1 = new GLabel(win, 2, 20, 240, 20);
    ((TraceWinData)win.data).ielabel1.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
    ((TraceWinData)win.data).ielabel1.setText("Image resolution: " + ((TraceWinData)win.data).sx + " x " + ((TraceWinData)win.data).sy + " pixels");
    ((TraceWinData)win.data).ielabel1.setOpaque(false);
    ((TraceWinData)win.data).ielabel2 = new GLabel(win, 18, 40, 150, 20);
    ((TraceWinData)win.data).ielabel2.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
    ((TraceWinData)win.data).ielabel2.setText("Extra resolution");
    ((TraceWinData)win.data).ielabel2.setLocalColorScheme(GCScheme.CENTER);
    ((TraceWinData)win.data).ielabel2.setOpaque(false);
    ((TraceWinData)win.data).ielabel3 = new GLabel(win, 136, 40, 50, 20);
    ((TraceWinData)win.data).ielabel3.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
    ((TraceWinData)win.data).ielabel3.setText("Format:");
    ((TraceWinData)win.data).ielabel3.setOpaque(false);
    ((TraceWinData)win.data).executeExport = new ImageExportExecutor(win, 40, 65);
    ((TraceWinData)win.data).executeExport.addEventHandler(this, "exportGo");
    ((TraceWinData)win.data).cancelExport = new CancelButton(win, 130, 65);
    ((TraceWinData)win.data).cancelExport.addEventHandler(this, "cancelButton_click1");
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).xres_check);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).resList);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).fmtList);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).ielabel1);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).ielabel2);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).ielabel3);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).executeExport);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).cancelExport);
    ((TraceWinData)win.data).imgExportPanel.setVisible(false);

    
        /*/build resize control elements
    ((TraceWinData)win.data).resizePanel = new GPanel(win, win.width / 2 - 70, win.height / 2 - 52, 140, 104, "Set image dimensions...");
    ((TraceWinData)win.data).resizePanel.setCollapsible(false);
    ((TraceWinData)win.data).resizePanel.setText("Set image dimensions...");
    ((TraceWinData)win.data).resizePanel.setOpaque(true);
    //((TraceWinData)win.data).resizePanel.addEventHandler(win, "resizePanel_Click1");
    ((TraceWinData)win.data).wField = new GTextField(win, 56, 24, 40, 20, G4P.SCROLLBARS_NONE);
    ((TraceWinData)win.data).wField.setPromptText(str(((TraceWinData)win.data).sx));
    ((TraceWinData)win.data).wField.setOpaque(true);
    //((TraceWinData)win.data).wField.addEventHandler(win, "wField_change1");
    ((TraceWinData)win.data).hField = new GTextField(win, 56, 48, 40, 20, G4P.SCROLLBARS_NONE);
    ((TraceWinData)win.data).hField.setPromptText(str(((TraceWinData)win.data).sy));
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
    ((TraceWinData)win.data).px1 = new GLabel(win, 94, 24, 20, 20);
    ((TraceWinData)win.data).px1.setText("px");
    ((TraceWinData)win.data).px1.setOpaque(false);
    ((TraceWinData)win.data).px2 = new GLabel(win, 94, 48, 20, 20);
    ((TraceWinData)win.data).px2.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    ((TraceWinData)win.data).px2.setText("px");
    ((TraceWinData)win.data).px2.setOpaque(false);
    ((TraceWinData)win.data).executeResize = new ResizeExecutor(win, 12, 82);
    ((TraceWinData)win.data).executeResize.addEventHandler(this, "resizeGo");
    ((TraceWinData)win.data).cancelResize = new CancelButton(win, 80, 82);
    ((TraceWinData)win.data).cancelResize.addEventHandler(this, "cancelResize_click1");
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).wField);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).hField);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).wide);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).high);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).px1);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).px2);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).executeResize);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).cancelResize);
    ((TraceWinData)win.data).resizePanel.setVisible(false);*/
    
    ((ScaleSlider)((TraceWinData)win.data).scaler).setViewer(keyVal);
    ((ResizeButton)((TraceWinData)win.data).resizeButton).setViewer(keyVal);
    ((CancelButton)((TraceWinData)win.data).cancelResize).setViewer(keyVal);
    ((ResizeExecutor)((TraceWinData)win.data).executeResize).setViewer(keyVal);
    ((BCCheckbox)((TraceWinData)win.data).bc_check).setViewer(keyVal);
    ((DPCheckbox)((TraceWinData)win.data).dp_check).setViewer(keyVal);
    ((XRCheckbox)((TraceWinData)win.data).xres_check).setViewer(keyVal);
    ((ImageExportButton)((TraceWinData)win.data).imgExport).setViewer(keyVal);
    ((ImageExportExecutor)((TraceWinData)win.data).executeExport).setViewer(keyVal);
    ((CancelButton)((TraceWinData)win.data).cancelExport).setViewer(keyVal);
    ((BaseExportButton)((TraceWinData)win.data).baseExport).setViewer(keyVal);
    
    //add handlers for window
    win.addDrawHandler(this, "drawTraces");
    win.addMouseHandler(this, "scrollControl");
    
    keyVal++;
  }
}

void alignWindow(FilesData data) {
  if (data.ref != null && data.test != null) {
    //set up window
    String tempStr = "Aligning " + data.test.getName() + " to " + data.ref.getName();
    GWindow win = GWindow.getWindow(this, tempStr, 100, 100, 1024, 572, JAVA2D);
    win.setActionOnClose(G4P.CLOSE_WINDOW);
    win.frameRate(30);
    viewers.put(keyVal, win);
    win.addData(new TraceWinData());
    ((TraceWinData)win.data).viewer_number = keyVal;
    ((TraceWinData)win.data).sx = 1024;
    ((TraceWinData)win.data).sy = 512;
    ((TraceWinData)win.data).col = 255;
    ((TraceWinData)win.data).titleStr = tempStr;
  
  
    //read files into ABISeqRun objects
    /*InputStream refin = createInput(data2.ref);
    InputStream testin = createInput(data2.test);
    DataInputStream refFile = new DataInputStream(new BufferedInputStream(refin));
    DataInputStream testFile = new DataInputStream(new BufferedInputStream(testin));
    refFile.mark(int(pow(2, 32) - 1));
    testFile.mark(int(pow(2, 32) - 1));*/
    ((TraceWinData)win.data).chromat1 = new ABISeqRun(data.ref);
    ((TraceWinData)win.data).chromat1.peaks = ((TraceWinData)win.data).chromat1.getPeaks();
    ((TraceWinData)win.data).chromat2 = new ABISeqRun(data.test);
    //make aligned trace
    ((TraceWinData)win.data).chromat3 = ((TraceWinData)win.data).chromat2.get_best_align(((TraceWinData)win.data).chromat1);
    ((TraceWinData)win.data).chromat3.peaks = ((TraceWinData)win.data).chromat3.getPeaks();
    
    Table peaktable = new Table();
    peaktable.addColumn("basecalls");
    peaktable.addColumn("called peaks");
    int bcnum = ((TraceWinData)win.data).chromat3.basecalls.length();
    for (int i = 0; i < ((TraceWinData)win.data).chromat3.peaks.size(); i++) {
      TableRow newRow = peaktable.addRow();
      if (i < bcnum){
        String bcid = ((TraceWinData)win.data).chromat3.basecalls.charAt(i) + Integer.toString(((TraceWinData)win.data).chromat3.basepos.get(i));
        newRow.setString("basecalls", bcid);
      }
      String pid = ((PeakPoint)((TraceWinData)win.data).chromat3.peaks.get(i)).getBase() + Integer.toString(((PeakPoint)((TraceWinData)win.data).chromat3.peaks.get(i)).getPosition());
      newRow.setString("called peaks", pid);
    }
    saveTable(peaktable, "peaks.csv");
    
    //make difference profile
    ((TraceWinData)win.data).chromat3.dp = new DifferenceProfile(((TraceWinData)win.data).chromat3, ((TraceWinData)win.data).chromat1);
    ((TraceWinData)win.data).chromat3.diffPeaks = ((TraceWinData)win.data).chromat3.getBidirectionalPeaks();
    
    //parse heterozygous peaks
    ((TraceWinData)win.data).chromat3.hetPeaks = ((TraceWinData)win.data).chromat3.getHetPeaks();
    //((TraceWinData)win.data).chromat3.refsForHets(((TraceWinData)win.data).chromat1);
    
    ((TraceWinData)win.data).chromat1.tracePics = ((TraceWinData)win.data).chromat1.traceDraw(((TraceWinData)win.data).sy / 2, 1, true);
    ((TraceWinData)win.data).chromat3.tracePics = ((TraceWinData)win.data).chromat3.traceDraw(((TraceWinData)win.data).sy / 2, 1, true);
    ((TraceWinData)win.data).chromat3.diffPics = ((TraceWinData)win.data).chromat3.diffDraw(((TraceWinData)win.data).sy/3,1);
    
    //build frame elements and toggles
    ((TraceWinData)win.data).resizeButton = new ResizeButton(win, 4, 4);
    ((TraceWinData)win.data).resizeButton.addEventHandler(this, "resizeButton_click1");
    ((TraceWinData)win.data).imgExport = new ImageExportButton(win, 40, 4);
    ((TraceWinData)win.data).imgExport.addEventHandler(this, "imgExport_click1");
    ((TraceWinData)win.data).baseExport = new BaseExportButton(win, 76, 4); //was 326
    ((TraceWinData)win.data).baseExport.addEventHandler(this, "baseExport_click1");
    ((TraceWinData)win.data).rc_check = new GCheckbox(win, 110, 0, 24, 20); //was 74
    ((TraceWinData)win.data).rc_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    ((TraceWinData)win.data).rc_check.setOpaque(false);
      ((TraceWinData)win.data).name_check = new GCheckbox(win, 216, 0, 24, 20);
      ((TraceWinData)win.data).name_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
      ((TraceWinData)win.data).name_check.setVisible(false);
      ((TraceWinData)win.data).name_check.setOpaque(false);
      //((TraceWinData)win.data).name_check.addEventHandler(win, "name_check_clicked1");
      ((TraceWinData)win.data).name_check.setSelected(true);
      ((TraceWinData)win.data).bc_check = new BCCheckbox(win, 216, 20, 24, 20);
      ((TraceWinData)win.data).bc_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
      ((TraceWinData)win.data).bc_check.setVisible(false);
      ((TraceWinData)win.data).bc_check.setOpaque(false);
      ((TraceWinData)win.data).bc_check.addEventHandler(this, "bc_check_clicked1");
      ((TraceWinData)win.data).bc_check.setSelected(true);
    ((TraceWinData)win.data).scaler = new ScaleSlider(win, 272, 20, 60, 15, 10); //was 124 & 90 px long
    ((TraceWinData)win.data).scaler.setLimits(0.0, 0.0, 4.0);
    ((TraceWinData)win.data).scaler.setNbrTicks(4);
    ((TraceWinData)win.data).scaler.setNumberFormat(G4P.DECIMAL, 1);
    ((TraceWinData)win.data).scaler.setOpaque(false);
    ((TraceWinData)win.data).scaler.addEventHandler(this, "scaler_change1");
    ((TraceWinData)win.data).dp_check = new DPCheckbox(win, 110, 20, 24, 20); //was 360,0
    ((TraceWinData)win.data).dp_check.setOpaque(false);
    ((TraceWinData)win.data).dp_check.addEventHandler(this, "dp_check_clicked1");
      ((TraceWinData)win.data).sub_check = new GCheckbox(win, 360, 20, 24, 20);
      ((TraceWinData)win.data).sub_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
      ((TraceWinData)win.data).sub_check.setVisible(false);
      ((TraceWinData)win.data).sub_check.setOpaque(false);
      //((TraceWinData)win.data).sub_check.addEventHandler(win, "sub_check_clicked1");
    ((TraceWinData)win.data).scroller = new GSlider(win, 0, ((TraceWinData)win.data).sy + 40, ((TraceWinData)win.data).sx, 20, 20.0);
    ((TraceWinData)win.data).scroller.setLimits(0.0, 0.0, 1.0);
    ((TraceWinData)win.data).scroller.setNumberFormat(G4P.DECIMAL, 2);
    ((TraceWinData)win.data).scroller.setOpaque(false);
    
    //build resize control elements
    ((TraceWinData)win.data).resizePanel = new GPanel(win, win.width / 2 - 70, win.height / 2 - 52, 140, 104, "Set image dimensions...");
    ((TraceWinData)win.data).resizePanel.setCollapsible(false);
    ((TraceWinData)win.data).resizePanel.setText("Set image dimensions...");
    ((TraceWinData)win.data).resizePanel.setOpaque(true);
    ((TraceWinData)win.data).wField = new GTextField(win, 56, 24, 40, 20, G4P.SCROLLBARS_NONE);
    ((TraceWinData)win.data).wField.setPromptText(str(((TraceWinData)win.data).sx));
    ((TraceWinData)win.data).wField.setOpaque(true);
    ((TraceWinData)win.data).hField = new GTextField(win, 56, 48, 40, 20, G4P.SCROLLBARS_NONE);
    ((TraceWinData)win.data).hField.setPromptText(str(((TraceWinData)win.data).sy));
    ((TraceWinData)win.data).hField.setOpaque(true);
    ((TraceWinData)win.data).wide = new GLabel(win, 16, 24, 40, 20);
    ((TraceWinData)win.data).wide.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
    ((TraceWinData)win.data).wide.setText("Width:");
    ((TraceWinData)win.data).wide.setOpaque(false);
    ((TraceWinData)win.data).high = new GLabel(win, 6, 48, 50, 20);
    ((TraceWinData)win.data).high.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
    ((TraceWinData)win.data).high.setText("Height:");
    ((TraceWinData)win.data).high.setOpaque(false);
    ((TraceWinData)win.data).px1 = new GLabel(win, 94, 24, 20, 20);
    ((TraceWinData)win.data).px1.setText("px");
    ((TraceWinData)win.data).px1.setOpaque(false);
    ((TraceWinData)win.data).px2 = new GLabel(win, 94, 48, 20, 20);
    ((TraceWinData)win.data).px2.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
    ((TraceWinData)win.data).px2.setText("px");
    ((TraceWinData)win.data).px2.setOpaque(false);
    ((TraceWinData)win.data).executeResize = new ResizeExecutor(win, 12, 82);
    ((TraceWinData)win.data).executeResize.addEventHandler(this, "resizeGo");
    ((TraceWinData)win.data).cancelResize = new CancelButton(win, 80, 82);
    ((TraceWinData)win.data).cancelResize.addEventHandler(this, "cancelButton_click1");
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).wField);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).hField);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).wide);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).high);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).px1);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).px2);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).executeResize);
    ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).cancelResize);
    ((TraceWinData)win.data).resizePanel.setVisible(false);
    
    //build image export control elements
    ((TraceWinData)win.data).imgExportPanel = new GPanel(win, win.width / 2 - 110, win.height / 2 - 45, 220, 90, "Export as...");
    ((TraceWinData)win.data).imgExportPanel.setText("Export as...");
    ((TraceWinData)win.data).imgExportPanel.setOpaque(true);
    ((TraceWinData)win.data).xres_check = new XRCheckbox(win, 2, 40, 24, 20);
    ((TraceWinData)win.data).xres_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    ((TraceWinData)win.data).xres_check.setOpaque(false);
    ((TraceWinData)win.data).xres_check.addEventHandler(this, "xres_check_clicked1");
    ((TraceWinData)win.data).resList = new GDropList(win, 105, 40, 30, 100, 4);
    ((TraceWinData)win.data).resList.setItems(loadStrings("extra.txt"), 0);
    ((TraceWinData)win.data).resList.setVisible(false);
    ((TraceWinData)win.data).fmtList = new GDropList(win, 178, 40, 40, 100, 4);
    ((TraceWinData)win.data).fmtList.setItems(loadStrings("format.txt"), 0);
    ((TraceWinData)win.data).ielabel1 = new GLabel(win, 2, 20, 240, 20);
    ((TraceWinData)win.data).ielabel1.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
    ((TraceWinData)win.data).ielabel1.setText("Image resolution: " + ((TraceWinData)win.data).sx + " x " + ((TraceWinData)win.data).sy + " pixels");
    ((TraceWinData)win.data).ielabel1.setOpaque(false);
    ((TraceWinData)win.data).ielabel2 = new GLabel(win, 18, 40, 150, 20);
    ((TraceWinData)win.data).ielabel2.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
    ((TraceWinData)win.data).ielabel2.setText("Extra resolution");
    ((TraceWinData)win.data).ielabel2.setLocalColorScheme(GCScheme.CENTER);
    ((TraceWinData)win.data).ielabel2.setOpaque(false);
    ((TraceWinData)win.data).ielabel3 = new GLabel(win, 136, 40, 50, 20);
    ((TraceWinData)win.data).ielabel3.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
    ((TraceWinData)win.data).ielabel3.setText("Format:");
    ((TraceWinData)win.data).ielabel3.setOpaque(false);
    ((TraceWinData)win.data).executeExport = new ImageExportExecutor(win, 40, 65);
    ((TraceWinData)win.data).executeExport.addEventHandler(this, "exportGo");
    ((TraceWinData)win.data).cancelExport = new CancelButton(win, 130, 65);
    ((TraceWinData)win.data).cancelExport.addEventHandler(this, "cancelButton_click1");
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).xres_check);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).resList);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).fmtList);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).ielabel1);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).ielabel2);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).ielabel3);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).executeExport);
    ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).cancelExport);
    ((TraceWinData)win.data).imgExportPanel.setVisible(false);
    
    ((ScaleSlider)((TraceWinData)win.data).scaler).setViewer(keyVal);
    ((ResizeButton)((TraceWinData)win.data).resizeButton).setViewer(keyVal);
    ((CancelButton)((TraceWinData)win.data).cancelResize).setViewer(keyVal);
    ((ResizeExecutor)((TraceWinData)win.data).executeResize).setViewer(keyVal);
    ((BCCheckbox)((TraceWinData)win.data).bc_check).setViewer(keyVal);
    ((DPCheckbox)((TraceWinData)win.data).dp_check).setViewer(keyVal);
    ((XRCheckbox)((TraceWinData)win.data).xres_check).setViewer(keyVal);
    ((ImageExportButton)((TraceWinData)win.data).imgExport).setViewer(keyVal);
    ((ImageExportExecutor)((TraceWinData)win.data).executeExport).setViewer(keyVal);
    ((CancelButton)((TraceWinData)win.data).cancelExport).setViewer(keyVal);
    ((BaseExportButton)((TraceWinData)win.data).baseExport).setViewer(keyVal);
    
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
  GWindow win = GWindow.getWindow(this, data_to_copy.titleStr, 100, 100, data_to_copy.ex, data_to_copy.ey + 60, JAVA2D);
  win.setActionOnClose(G4P.CLOSE_WINDOW);
  win.addData(data_to_copy);
  viewers.put(vn, win);
  oldwin.close();
  
  //update data and redraw traces
  ((TraceWinData)win.data).sx = ((TraceWinData)win.data).ex;
  if (((TraceWinData)win.data).sy != ((TraceWinData)win.data).ey) {
    ((TraceWinData)win.data).sy = ((TraceWinData)win.data).ey;
    redrawTraces((TraceWinData)win.data);
    if (((TraceWinData)win.data).chromat3 != null) {
      ((TraceWinData)win.data).chromat3.diffPics = ((TraceWinData)win.data).chromat3.diffDraw(((TraceWinData)win.data).sy / 3, scale + 1);
    }
  }
  
  //build frame elements and toggles
  ((TraceWinData)win.data).resizeButton = new ResizeButton(win, 4, 4);
  ((TraceWinData)win.data).resizeButton.addEventHandler(this, "resizeButton_click1");
  ((TraceWinData)win.data).imgExport = new ImageExportButton(win, 40, 4);
  ((TraceWinData)win.data).imgExport.addEventHandler(this, "imgExport_click1");
  ((TraceWinData)win.data).baseExport = new BaseExportButton(win, 76, 4); //was 326
  ((TraceWinData)win.data).baseExport.addEventHandler(this, "baseExport_click1");
  ((TraceWinData)win.data).rc_check = new GCheckbox(win, 110, 0, 24, 20); //was 74
  ((TraceWinData)win.data).rc_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  ((TraceWinData)win.data).rc_check.setOpaque(false);
  ((TraceWinData)win.data).rc_check.setSelected(rc);
    ((TraceWinData)win.data).name_check = new GCheckbox(win, 216, 0, 24, 20);
    ((TraceWinData)win.data).name_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    ((TraceWinData)win.data).name_check.setVisible(false);
    ((TraceWinData)win.data).name_check.setOpaque(false);
    ((TraceWinData)win.data).name_check.setSelected(fnames);
    ((TraceWinData)win.data).bc_check = new BCCheckbox(win, 216, 20, 24, 20);
    ((TraceWinData)win.data).bc_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    ((TraceWinData)win.data).bc_check.setVisible(false);
    ((TraceWinData)win.data).bc_check.setOpaque(false);
    ((TraceWinData)win.data).bc_check.addEventHandler(this, "bc_check_clicked1");
    ((TraceWinData)win.data).bc_check.setSelected(bc);
  ((TraceWinData)win.data).scaler = new ScaleSlider(win, 272, 20, 60, 15, 10); //was 124 & 90 px long
  ((TraceWinData)win.data).scaler.setLimits(scale, 0.0, 4.0);
  ((TraceWinData)win.data).scaler.setNbrTicks(4);
  ((TraceWinData)win.data).scaler.setNumberFormat(G4P.DECIMAL, 1);
  ((TraceWinData)win.data).scaler.setOpaque(false);
  ((TraceWinData)win.data).scaler.addEventHandler(this, "scaler_change1");
  ((TraceWinData)win.data).dp_check = new DPCheckbox(win, 110, 20, 24, 20); //was 360,0
  ((TraceWinData)win.data).dp_check.setOpaque(false);
  ((TraceWinData)win.data).dp_check.setSelected(dp);
  ((TraceWinData)win.data).dp_check.addEventHandler(this, "dp_check_clicked1");
    ((TraceWinData)win.data).sub_check = new GCheckbox(win, 360, 20, 24, 20);
    ((TraceWinData)win.data).sub_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
    ((TraceWinData)win.data).sub_check.setVisible(false);
    ((TraceWinData)win.data).sub_check.setOpaque(false);
    ((TraceWinData)win.data).sub_check.setSelected(parse);
  ((TraceWinData)win.data).scroller = new GSlider(win, 0, ((TraceWinData)win.data).sy + 40, ((TraceWinData)win.data).sx, 20, 20.0);
  ((TraceWinData)win.data).scroller.setLimits(scroll, 0.0, 1.0);
  ((TraceWinData)win.data).scroller.setNumberFormat(G4P.DECIMAL, 2);
  ((TraceWinData)win.data).scroller.setOpaque(false);
  
  //build resize control elements
  ((TraceWinData)win.data).resizePanel = new GPanel(win, win.width / 2 - 70, win.height / 2 - 52, 140, 104, "Set image dimensions...");
  ((TraceWinData)win.data).resizePanel.setCollapsible(false);
  ((TraceWinData)win.data).resizePanel.setText("Set image dimensions...");
  ((TraceWinData)win.data).resizePanel.setOpaque(true);
  ((TraceWinData)win.data).wField = new GTextField(win, 56, 24, 40, 20, G4P.SCROLLBARS_NONE);
  ((TraceWinData)win.data).wField.setPromptText(str(((TraceWinData)win.data).sx));
  ((TraceWinData)win.data).wField.setOpaque(true);
  ((TraceWinData)win.data).hField = new GTextField(win, 56, 48, 40, 20, G4P.SCROLLBARS_NONE);
  ((TraceWinData)win.data).hField.setPromptText(str(((TraceWinData)win.data).sy));
  ((TraceWinData)win.data).hField.setOpaque(true);
  ((TraceWinData)win.data).wide = new GLabel(win, 16, 24, 40, 20);
  ((TraceWinData)win.data).wide.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  ((TraceWinData)win.data).wide.setText("Width:");
  ((TraceWinData)win.data).wide.setOpaque(false);
  ((TraceWinData)win.data).high = new GLabel(win, 6, 48, 50, 20);
  ((TraceWinData)win.data).high.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  ((TraceWinData)win.data).high.setText("Height:");
  ((TraceWinData)win.data).high.setOpaque(false);
  ((TraceWinData)win.data).px1 = new GLabel(win, 94, 24, 20, 20);
  ((TraceWinData)win.data).px1.setText("px");
  ((TraceWinData)win.data).px1.setOpaque(false);
  ((TraceWinData)win.data).px2 = new GLabel(win, 94, 48, 20, 20);
  ((TraceWinData)win.data).px2.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  ((TraceWinData)win.data).px2.setText("px");
  ((TraceWinData)win.data).px2.setOpaque(false);
  ((TraceWinData)win.data).executeResize = new ResizeExecutor(win, 12, 82);
  ((TraceWinData)win.data).executeResize.addEventHandler(this, "resizeGo");
  ((TraceWinData)win.data).cancelResize = new CancelButton(win, 80, 82);
  ((TraceWinData)win.data).cancelResize.addEventHandler(this, "cancelButton_click1");
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).wField);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).hField);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).wide);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).high);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).px1);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).px2);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).executeResize);
  ((TraceWinData)win.data).resizePanel.addControl(((TraceWinData)win.data).cancelResize);
  ((TraceWinData)win.data).resizePanel.setVisible(false);
  
  //build image export control elements
  ((TraceWinData)win.data).imgExportPanel = new GPanel(win, win.width / 2 - 110, win.height / 2 - 45, 220, 90, "Export as...");
  ((TraceWinData)win.data).imgExportPanel.setText("Export as...");
  ((TraceWinData)win.data).imgExportPanel.setOpaque(true);
  ((TraceWinData)win.data).xres_check = new XRCheckbox(win, 2, 40, 24, 20);
  ((TraceWinData)win.data).xres_check.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  ((TraceWinData)win.data).xres_check.setOpaque(false);
  ((TraceWinData)win.data).xres_check.addEventHandler(this, "xres_check_clicked1");
  ((TraceWinData)win.data).resList = new GDropList(win, 105, 40, 30, 100, 4);
  ((TraceWinData)win.data).resList.setItems(loadStrings("extra.txt"), 0);
  ((TraceWinData)win.data).resList.setVisible(false);
  ((TraceWinData)win.data).fmtList = new GDropList(win, 178, 40, 40, 100, 4);
  ((TraceWinData)win.data).fmtList.setItems(loadStrings("format.txt"), 0);
  ((TraceWinData)win.data).ielabel1 = new GLabel(win, 2, 20, 240, 20);
  ((TraceWinData)win.data).ielabel1.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  ((TraceWinData)win.data).ielabel1.setText("Image resolution: " + ((TraceWinData)win.data).sx + " x " + ((TraceWinData)win.data).sy + " pixels");
  ((TraceWinData)win.data).ielabel1.setOpaque(false);
  ((TraceWinData)win.data).ielabel2 = new GLabel(win, 18, 40, 150, 20);
  ((TraceWinData)win.data).ielabel2.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  ((TraceWinData)win.data).ielabel2.setText("Extra resolution");
  ((TraceWinData)win.data).ielabel2.setLocalColorScheme(GCScheme.CENTER);
  ((TraceWinData)win.data).ielabel2.setOpaque(false);
  ((TraceWinData)win.data).ielabel3 = new GLabel(win, 136, 40, 50, 20);
  ((TraceWinData)win.data).ielabel3.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  ((TraceWinData)win.data).ielabel3.setText("Format:");
  ((TraceWinData)win.data).ielabel3.setOpaque(false);
  ((TraceWinData)win.data).executeExport = new ImageExportExecutor(win, 40, 65);
  ((TraceWinData)win.data).executeExport.addEventHandler(this, "exportGo");
  ((TraceWinData)win.data).cancelExport = new CancelButton(win, 130, 65);
  ((TraceWinData)win.data).cancelExport.addEventHandler(this, "cancelButton_click1");
  ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).xres_check);
  ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).resList);
  ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).fmtList);
  ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).ielabel1);
  ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).ielabel2);
  ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).ielabel3);
  ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).executeExport);
  ((TraceWinData)win.data).imgExportPanel.addControl(((TraceWinData)win.data).cancelExport);
  ((TraceWinData)win.data).imgExportPanel.setVisible(false);
    
  ((ScaleSlider)((TraceWinData)win.data).scaler).setViewer(vn);
  ((ResizeButton)((TraceWinData)win.data).resizeButton).setViewer(vn);
  ((CancelButton)((TraceWinData)win.data).cancelResize).setViewer(vn);
  ((ResizeExecutor)((TraceWinData)win.data).executeResize).setViewer(vn);
  ((BCCheckbox)((TraceWinData)win.data).bc_check).setViewer(vn);
  ((DPCheckbox)((TraceWinData)win.data).dp_check).setViewer(vn);
  ((XRCheckbox)((TraceWinData)win.data).xres_check).setViewer(vn);
  ((ImageExportButton)((TraceWinData)win.data).imgExport).setViewer(vn);
  ((ImageExportExecutor)((TraceWinData)win.data).executeExport).setViewer(vn);
  ((CancelButton)((TraceWinData)win.data).cancelExport).setViewer(vn);
  ((BaseExportButton)((TraceWinData)win.data).baseExport).setViewer(vn);
  
  //add handlers for window
  win.addDrawHandler(this, "drawTraces");
  win.addMouseHandler(this, "scrollControl");
}

//DISPLAY WINDOW MOUSE WHEEL HANDLER
void scrollControl(PApplet appc, GWinData data, MouseEvent event){
  TraceWinData data2 = (TraceWinData)data;
  switch(event.getAction()) {
    case MouseEvent.WHEEL:
      ((TraceWinData)data).scroller.setValue(constrain(data2.scroller.getValueF() + (event.getCount()/(50.0 * (data2.scaler.getValueF() + 1))), data2.scroller.getStartLimit(), data2.scroller.getEndLimit()));
  }  
}

//CONTAINER CLASSES TO HOLD WINDOW DATA
class MyWinData extends GWinData {
  int sx, sy, ex, ey;
  int col;
}

//CHROMATOGRAM WINDOW DRAW HANDLER

void drawTraces(PApplet appc, GWinData data) {
  TraceWinData data2 = (TraceWinData)data;
  appc.background(255);
  appc.noFill();
  appc.pushMatrix();
  appc.translate(0 - data2.scroller.getValueF() * (data2.chromat1.tracePics[0].width - data2.sx), 40);
  PImage ref = data2.chromat1.tracePics[int(data2.rc_check.isSelected())];
  appc.image(ref, 0, 0);
  if (data2.chromat3 != null) {
    PImage q = data2.chromat3.tracePics[int(data2.rc_check.isSelected())];
    int x = 0;
    if (data2.rc_check.isSelected()) {
      x += (ref.width - q.width);
    }
    if (data2.dp_check.isSelected()){
      PImage dp = data2.chromat3.diffPics[int(data2.rc_check.isSelected())];
      appc.image(dp, x, data2.sy / 3);
      appc.image(q, x, data2.sy * 2 / 3);
    } else {
      appc.image(q, x, data2.sy / 2);      
    }
  }
  //
  appc.popMatrix();
  appc.fill(150,150,255);
  appc.noStroke();
  appc.rect(0, 0, appc.width, 40);
  appc.fill(0);
  appc.textAlign(LEFT);
  appc.text("Reverse complement", 128, 14); //was 92
  //appc.text("Show filenames", 234, 14);
  //appc.text("Show basecalls", 234, 34);
  appc.text("Show difference profile", 128, 34); //was 380, 14
  //appc.text("Parse heterozygous sequences", 380, 34);
  appc.textAlign(CENTER);
  appc.text("X-scale", 302, 20); //was 78, 34
  
  //println("ref pic " + data2.chromat1.tracePics[0].width + " pixels wide; query pic " + data2.chromat3.tracePics[0].width + " pixels wide; diff pic "+ data2.chromat3.diffPics[0].width + " pixels wide");
}
  
//UI CONTROL EVENT HANDLERS
public void resizeButton_click1(ResizeButton source, GEvent event) { //_CODE_:resizeButton:451682:
  println("ResizeButton1 - GImageButton >> GEvent." + event + " @ " + millis());
  ((TraceWinData)viewers.get(source.getViewer()).data).resizePanel.setVisible(true);
}

public void imgExport_click1(ImageExportButton source, GEvent event) { 
  println("ImageExportButton1 - GImageButton >> GEvent." + event + " @ " + millis());
  ((TraceWinData)viewers.get(source.getViewer()).data).imgExportPanel.setVisible(true);
}

public void cancelButton_click1(CancelButton source, GEvent event) { 
  println("cancelResize1 - GImageButton >> GEvent." + event + " @ " + millis());
  ((TraceWinData)viewers.get(source.getViewer()).data).resizePanel.setVisible(false);
  ((TraceWinData)viewers.get(source.getViewer()).data).imgExportPanel.setVisible(false);
}

public void baseExport_click1(BaseExportButton source, GEvent event) { 
  println("BaseExportButton1 - GImageButton >> GEvent." + event + " @ " + millis());
  int vn = source.getViewer();
  TraceWinData data2 = (TraceWinData)viewers.get(vn).data;
  chooser.setFileFilter(txtFilter);
  int returnVal = chooser.showSaveDialog(null);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    String extension = "txt";
    String path_str = chooser.getSelectedFile().toPath().toAbsolutePath().toString();
    if (!path_str.endsWith("." + extension)) {
      path_str += ("." + extension);
    }
    File export_file = new File(path_str);
    Path export_path = export_file.toPath();
    
    String[] writeout = new String[8];
    writeout[0] = '>' + data2.chromat1.filename;
    writeout[1] = data2.chromat1.basecalls;
    if (data2.chromat3 != null) {
      writeout[2] = "";
      writeout[3] ='>' + data2.chromat3.filename + " bases called by sequencer";
      writeout[4] =data2.chromat3.basecalls;
      if (data2.chromat3.hetPeaks != null) {
        writeout[5] = "";
        writeout[6] = '>' + data2.chromat3.filename + " parsed with reference " + data2.chromat1.filename;
        writeout[7] = data2.chromat3.parsed_calls;
      }
    }
    saveStrings(path_str, writeout);
  } else {
  //WHAT DO
  }
}
    
    /*data2.imgExportPanel.setVisible(false);
    int scale = 1;
    if (data2.xres_check.isSelected()) {
      scale = scale * (2 + data2.resList.getSelectedIndex());
    }
    PGraphics temp_img = createGraphics(data2.sx * scale, data2.sy * scale);
    float offset = 0 - data2.scroller.getValueF() * (data2.chromat1.tracePics[0].width - data2.sx);
    temp_img.beginDraw();
    temp_img.background(255);
    temp_img.pushMatrix();
    temp_img.scale(scale);
    temp_img.translate(offset, 0);
    PImage ref = data2.chromat1.tracePics[int(data2.rc_check.isSelected())];
    temp_img.image(ref, 0, 0);
    if (data2.chromat3 != null) {
      PImage q = data2.chromat3.tracePics[int(data2.rc_check.isSelected())];
      int x = 0;
      if (data2.rc_check.isSelected()) {
        x += (ref.width - q.width);
      }
      if (data2.dp_check.isSelected()){
        PImage dp = data2.chromat3.diffPics[int(data2.rc_check.isSelected())];
        temp_img.image(dp, x, data2.sy / 3);
        temp_img.image(q, x, data2.sy * 2 / 3);
      } else {
        temp_img.image(q, x, data2.sy / 2);      
      }
    }
    temp_img.endDraw();
    temp_img.save("temp." + data2.fmtList.getSelectedText().toLowerCase());
    //MUST UPDATE FOR CURRENT DIRECTORY
    Path temp_path = Paths.get(".\\committee_demo\\temp." + data2.fmtList.getSelectedText().toLowerCase());
    try {
      Files.move(temp_path, export_path, StandardCopyOption.REPLACE_EXISTING);
      //buffout = ImageIO.read(new File("temp." + data2.fmtList.getSelectedText().toLowerCase()));
      //ImageIO.write(buffout,data2.fmtList.getSelectedText().toLowerCase(), chooser.getSelectedFile());
    } catch (IOException e) {
      println(e);
    }
  }
}*/

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

public void exportGo(ImageExportExecutor source, GEvent event) { //_CODE_:resizeButton:451682:
  println("exportGo1 - GImageButton >> GEvent." + event + " @ " + millis());
  int vn = source.getViewer();
  TraceWinData data2 = (TraceWinData)viewers.get(vn).data;
  chooser.setFileFilter(saveFilters[data2.fmtList.getSelectedIndex()]);
  int returnVal = chooser.showSaveDialog(null);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    String extension = data2.fmtList.getSelectedText().toLowerCase();
    String path_str = chooser.getSelectedFile().toPath().toAbsolutePath().toString();
    if (!path_str.endsWith("." + extension)) {
      path_str += ("." + extension);
    }
    File export_file = new File(path_str);
    Path export_path = export_file.toPath();
    data2.imgExportPanel.setVisible(false);
    int scale = 1;
    if (data2.xres_check.isSelected()) {
      scale = scale * (2 + data2.resList.getSelectedIndex());
    }
    PGraphics temp_img = createGraphics(data2.sx * scale, data2.sy * scale);
    float offset = 0 - data2.scroller.getValueF() * (data2.chromat1.tracePics[0].width - data2.sx);
    temp_img.beginDraw();
    temp_img.background(255);
    temp_img.pushMatrix();
    temp_img.scale(scale);
    temp_img.translate(offset, 0);
    PImage ref = data2.chromat1.tracePics[int(data2.rc_check.isSelected())];
    temp_img.image(ref, 0, 0);
    if (data2.chromat3 != null) {
      PImage q = data2.chromat3.tracePics[int(data2.rc_check.isSelected())];
      int x = 0;
      if (data2.rc_check.isSelected()) {
        x += (ref.width - q.width);
      }
      if (data2.dp_check.isSelected()){
        PImage dp = data2.chromat3.diffPics[int(data2.rc_check.isSelected())];
        temp_img.image(dp, x, data2.sy / 3);
        temp_img.image(q, x, data2.sy * 2 / 3);
      } else {
        temp_img.image(q, x, data2.sy / 2);      
      }
    }
    temp_img.endDraw();
    temp_img.save("temp." + data2.fmtList.getSelectedText().toLowerCase());
    //MUST UPDATE FOR CURRENT DIRECTORY
    Path temp_path = Paths.get(".\\alpha_0_1_1\\temp." + data2.fmtList.getSelectedText().toLowerCase());
    try {
      Files.move(temp_path, export_path, StandardCopyOption.REPLACE_EXISTING);
      //buffout = ImageIO.read(new File("temp." + data2.fmtList.getSelectedText().toLowerCase()));
      //ImageIO.write(buffout,data2.fmtList.getSelectedText().toLowerCase(), chooser.getSelectedFile());
    } catch (IOException e) {
      println(e);
    }
  }
}

public void setExportFile(File selected) {
  if (selected == null) {
    exportFile = null;
  } else {
    exportFile = new File (selected.getAbsolutePath());
    try {
      exportFile.createNewFile();
    } catch (IOException e) {
      
    }
  }
}

public void scaler_change1(ScaleSlider source, GEvent event){
  println("scaler_change1 - " + (source.getValueF() + 1) +" >> GEvent." + event + " @ " + millis());
  if (event.toString() == "VALUE_STEADY") {
    if (((TraceWinData)viewers.get(source.getViewer()).data).chromat3 != null) {
      ((TraceWinData)viewers.get(source.getViewer()).data).chromat3.diffPics = ((TraceWinData)viewers.get(source.getViewer()).data).chromat3.diffDraw(((TraceWinData)viewers.get(source.getViewer()).data).sy / 3, ((TraceWinData)viewers.get(source.getViewer()).data).scaler.getValueF() + 1);
    }
    redrawTraces((TraceWinData)viewers.get(source.getViewer()).data);
  }
}

public void bc_check_clicked1(BCCheckbox source, GEvent event){
  println("bc_check_clicked >> GEvent." + event + " @ " + millis());
  //if (event.toString() == "SELECTED" || event.toString() == "DESELECTED") {
    redrawTraces((TraceWinData)viewers.get(source.getViewer()).data);
  //}
}

public void dp_check_clicked1(DPCheckbox source, GEvent event){
  println("dp_check_clicked >> GEvent." + event + " @ " + millis());
  //if (event.toString() == "SELECTED" || event.toString() == "DESELECTED") {
    redrawTraces((TraceWinData)viewers.get(source.getViewer()).data);
  //}
}

public void xres_check_clicked1 (XRCheckbox source, GEvent event){
  println("dp_check_clicked >> GEvent." + event + " @ " + millis());
  TraceWinData data2 = (TraceWinData)viewers.get(source.getViewer()).data;
  data2.resList.setVisible(!data2.resList.isVisible());
}

public void redrawTraces(TraceWinData data) {
  boolean bc = data.bc_check.isSelected();
  boolean dp = data.dp_check.isSelected();
  float scale = data.scaler.getValueF() + 1;
  int h = data.sy;
  int panes = 1;
  if (data.chromat3 != null) {
    panes += 1;
    if (dp) {
      panes += 1;
    }
    data.chromat3.tracePics = data.chromat3.traceDraw(h / panes, scale, bc);
  }
  data.chromat1.tracePics = data.chromat1.traceDraw(h / panes, scale, bc);
}
  
// Use this method to add additional statements
// to customise the GUI controls
public void customGUI(){

}