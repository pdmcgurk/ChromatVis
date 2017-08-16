import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

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
import java.util.Comparator; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class alpha_0_1_0 extends PApplet {

/*
Copyright 2007 Patrick McGurk
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

public void openTrace() {
  //selectInput("Select a chromatogram file to open...", "traceWindow");
  traces_to_align();
}

public void traces_to_align(){
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

public void fileSelectorDraw(PApplet appc, GWinData data){
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

public void fillRefField (File selected){
  ((FilesData)alignSelect[0].data).refField.setText("");
  ((FilesData)alignSelect[0].data).ref = null;
  if (selected != null) {
    ((FilesData)alignSelect[0].data).ref = selected;
    ((FilesData)alignSelect[0].data).refField.setText(selected.getName());
  }
}

public void fillTestField (File selected){
  ((FilesData)alignSelect[0].data).testField.setText("");
  ((FilesData)alignSelect[0].data).test = null;
  if (selected != null) {
    ((FilesData)alignSelect[0].data).test = selected;
    ((FilesData)alignSelect[0].data).testField.setText(selected.getName());
  }
}
 
//WINDOW GENERATORS FOR OPEN and ALIGN COMMANDS
public void traceWindow(File selected){
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
    ((TraceWinData)win.data).scaler.setLimits(0.0f, 0.0f, 4.0f);
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
    ((TraceWinData)win.data).scroller = new GSlider(win, 0, ((TraceWinData)win.data).sy + 40, ((TraceWinData)win.data).sx, 20, 20.0f);
    ((TraceWinData)win.data).scroller.setLimits(0.0f, 0.0f, 1.0f);
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

public void alignWindow(FilesData data) {
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
    ((TraceWinData)win.data).scaler.setLimits(0.0f, 0.0f, 4.0f);
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
    ((TraceWinData)win.data).scroller = new GSlider(win, 0, ((TraceWinData)win.data).sy + 40, ((TraceWinData)win.data).sx, 20, 20.0f);
    ((TraceWinData)win.data).scroller.setLimits(0.0f, 0.0f, 1.0f);
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
public void traceWindow(TraceWinData data_to_copy){
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
  ((TraceWinData)win.data).scaler.setLimits(scale, 0.0f, 4.0f);
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
  ((TraceWinData)win.data).scroller = new GSlider(win, 0, ((TraceWinData)win.data).sy + 40, ((TraceWinData)win.data).sx, 20, 20.0f);
  ((TraceWinData)win.data).scroller.setLimits(scroll, 0.0f, 1.0f);
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
public void scrollControl(PApplet appc, GWinData data, MouseEvent event){
  TraceWinData data2 = (TraceWinData)data;
  switch(event.getAction()) {
    case MouseEvent.WHEEL:
      ((TraceWinData)data).scroller.setValue(constrain(data2.scroller.getValueF() + (event.getCount()/(50.0f * (data2.scaler.getValueF() + 1))), data2.scroller.getStartLimit(), data2.scroller.getEndLimit()));
  }  
}

//CONTAINER CLASSES TO HOLD WINDOW DATA
class MyWinData extends GWinData {
  int sx, sy, ex, ey;
  int col;
}

//CHROMATOGRAM WINDOW DRAW HANDLER

public void drawTraces(PApplet appc, GWinData data) {
  TraceWinData data2 = (TraceWinData)data;
  appc.background(255);
  appc.noFill();
  appc.pushMatrix();
  appc.translate(0 - data2.scroller.getValueF() * (data2.chromat1.tracePics[0].width - data2.sx), 40);
  PImage ref = data2.chromat1.tracePics[PApplet.parseInt(data2.rc_check.isSelected())];
  appc.image(ref, 0, 0);
  if (data2.chromat3 != null) {
    PImage q = data2.chromat3.tracePics[PApplet.parseInt(data2.rc_check.isSelected())];
    int x = 0;
    if (data2.rc_check.isSelected()) {
      x += (ref.width - q.width);
    }
    if (data2.dp_check.isSelected()){
      PImage dp = data2.chromat3.diffPics[PApplet.parseInt(data2.rc_check.isSelected())];
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
  int x = PApplet.parseInt(((TraceWinData)viewers.get(vn).data).wField.getText());
  int y = PApplet.parseInt(((TraceWinData)viewers.get(vn).data).hField.getText());
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
    PImage ref = data2.chromat1.tracePics[PApplet.parseInt(data2.rc_check.isSelected())];
    temp_img.image(ref, 0, 0);
    if (data2.chromat3 != null) {
      PImage q = data2.chromat3.tracePics[PApplet.parseInt(data2.rc_check.isSelected())];
      int x = 0;
      if (data2.rc_check.isSelected()) {
        x += (ref.width - q.width);
      }
      if (data2.dp_check.isSelected()){
        PImage dp = data2.chromat3.diffPics[PApplet.parseInt(data2.rc_check.isSelected())];
        temp_img.image(dp, x, data2.sy / 3);
        temp_img.image(q, x, data2.sy * 2 / 3);
      } else {
        temp_img.image(q, x, data2.sy / 2);      
      }
    }
    temp_img.endDraw();
    temp_img.save("temp." + data2.fmtList.getSelectedText().toLowerCase());
    //MUST UPDATE FOR CURRENT DIRECTORY
    Path temp_path = Paths.get(".\\alpha_0_1_0\\temp." + data2.fmtList.getSelectedText().toLowerCase());
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
/*
Copyright 2007 Patrick McGurk
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
    traceFile.mark(PApplet.parseInt(pow(2, 32) - 1));
    String abinum = "";
    int ver = 0;
    try {
      //readChar() will try to get 2 bytes, can't use for this
      abinum += PApplet.parseChar(traceFile.readByte());
      abinum += PApplet.parseChar(traceFile.readByte());
      abinum += PApplet.parseChar(traceFile.readByte());
      abinum += PApplet.parseChar(traceFile.readByte());
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
          base_order[0] = str(PApplet.parseChar((val >> 24) & 0xff));
          base_order[1] = str(PApplet.parseChar((val >> 16) & 0xff));
          base_order[2] = str(PApplet.parseChar((val >> 8) & 0xff));
          base_order[3] = str(PApplet.parseChar(val & 0xff));
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

  public ABISeqRun copy() {
    ABISeqRun copy = new ABISeqRun(this);
    return copy;
  }

  public int getLength() {
    return len;
  }

  public void setLength(int i) {
    len = i;
  }

  public void resetLength() {
    len = traces.get("A").size();
  }

  public IndexEntry[] readIndex(DataInputStream traceFile) {
    IndexEntry[] iel = new IndexEntry[num_index_entries];
    for (int i = 0; i < this.num_index_entries; i++) {
      iel[i] = (readEntry(traceFile));
    }
    return iel;
  }

  public IndexEntry readEntry(DataInputStream traceFile) {
    IndexEntry ie = new IndexEntry();
    String ident = "";
    try {
      ident += PApplet.parseChar(traceFile.readByte());
      ident += PApplet.parseChar(traceFile.readByte());
      ident += PApplet.parseChar(traceFile.readByte());
      ident += PApplet.parseChar(traceFile.readByte());
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

  public IntList traceData(DataInputStream traceFile, IndexEntry ie) {  
    IntList vals = new IntList();
    try {
      traceFile.reset();
      traceFile.mark(PApplet.parseInt(pow(2, 32) - 1));
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

  public void trim_ends() {
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

  public void normalize() {
    int end = getLength();
    HashMap<String, IntList> normal_traces = new HashMap<String, IntList>();
    normal_traces.put("A", new IntList());
    normal_traces.put("C", new IntList());
    normal_traces.put("G", new IntList());
    normal_traces.put("T", new IntList());
    for (int i = 0; i < end; i++) {
      for (String key : base_order) {
        int sum = 0;
        float count = 0.0f;
        for (int j = constrain(i - 500, 0, end); j < constrain(i + 501, 0, end); j++) {
          sum += traces.get(key).get(j);
          count += 1;
        }
        float scale_factor = sum / (count * 100);
        normal_traces.get(key).append(PApplet.parseInt(traces.get(key).get(i) / scale_factor));
      }
    }
    traces.put("A", normal_traces.get("A"));
    traces.put("C", normal_traces.get("C"));
    traces.put("G", normal_traces.get("G"));
    traces.put("T", normal_traces.get("T"));
    resetLength();
  }

  public ABISeqRun get_best_align(ABISeqRun ref) {
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

  public ABISeqRun align(ABISeqRun ref, int offset, int align_length) {
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

  public int align_score(int start, int align_length, ABISeqRun ref, int offset) {
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

  public String get_basecalls(DataInputStream traceFile, IndexEntry ie) {  
    String bc = "";
    try {
      traceFile.reset();
      traceFile.mark(PApplet.parseInt(pow(2, 32) - 1));
      traceFile.skipBytes(ie.offset);
      for (int i = 0; i < ie.data_count; i++) {
        bc += PApplet.parseChar(traceFile.readByte());
      }
    } 
    catch (IOException e) {
      e.printStackTrace();
    }
    return(bc);
  }

  public PImage[] traceDraw(int h, float scale, boolean bc_check) {
    int w = PApplet.parseInt(scale * getLength());
    float maxh =  (h - 20) / (ymax * 0.8f);
    PImage[] pics = new PImage[2];
    PGraphics fwdimg = createGraphics(w, h);
    PGraphics revimg = createGraphics(w, h);

    float x = 0;
    fwdimg.beginDraw();
    fwdimg.background(255);
    fwdimg.noFill();
    fwdimg.strokeWeight(1.5f);
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
    revimg.strokeWeight(1.5f);
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

  public PImage[] traceDraw() {
    return this.traceDraw(512, 1, true);
  }

  public PImage[] diffDraw(int h, float scale) {
    PImage[] pics = null;
    if (dp != null) {
      int w = PApplet.parseInt(scale * getLength());
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
      float maxh = plimit / 500.0f;
      fwdimg.pushMatrix();
      fwdimg.translate(0, plimit);
      fwdimg.strokeWeight(1.5f);
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
      revimg.strokeWeight(1.5f);
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

  public String getFilename() {
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
      for (int i = 2*round(smoothwidth / 2.0f - 1); i < len - smoothwidth - 1; i++) {
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
      for (int i = 2*round(smoothwidth / 2.0f - 1); i < len - smoothwidth - 1; i++) {
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
    int halfwidth = round(smoothwidth / 2.0f);
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
/*
Copyright 2007 Patrick McGurk
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

public class BCCheckbox extends GCheckbox {
  public BCCheckbox(PApplet theApplet, float x, float y, float w, float h) {
    super(theApplet, x, y, w, h);
  }
  
  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}
/*
Copyright 2007 Patrick McGurk
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

public class BaseExportButton extends GImageButton {
  public BaseExportButton(PApplet theApplet, float x, float y) {
    super(theApplet, x, y, new String[] { "bexport.png", "bexport.png", "bexport.png" } , "allblack.png");
}

  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}
/*
Copyright 2007 Patrick McGurk
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

public class CancelButton extends GButton {
  public CancelButton(PApplet theApplet, float x, float y) {
    super(theApplet, x, y, 50, 20, "Cancel");
}

  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}
/*
Copyright 2007 Patrick McGurk
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

public class DPCheckbox extends GCheckbox {
  public DPCheckbox(PApplet theApplet, float x, float y, float w, float h) {
    super(theApplet, x, y, w, h);
  }
  
  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}
/*
Copyright 2007 Patrick McGurk
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
    
    traces.get("A").append(PApplet.parseInt(Math.signum(a_diff) * pow(a_diff, 2) * sqrt(abs(opp_a)) / 5000.0f));
    traces.get("C").append(PApplet.parseInt(Math.signum(c_diff) * pow(c_diff, 2) * sqrt(abs(opp_c)) / 5000.0f));
    traces.get("G").append(PApplet.parseInt(Math.signum(g_diff) * pow(g_diff, 2) * sqrt(abs(opp_g)) / 5000.0f));
    traces.get("T").append(PApplet.parseInt(Math.signum(t_diff) * pow(t_diff, 2) * sqrt(abs(opp_t)) / 5000.0f));
  }
  
  public int getPeakValue() {
    return peak;
  }
  
}
/*
Copyright 2007 Patrick McGurk
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

public class FilesData extends MyWinData {
  public GTextField refField, testField;
  public File ref, test;
  public String titleStr;
}
/*
Copyright 2007 Patrick McGurk
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
/*
Copyright 2007 Patrick McGurk
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

public class ImageExportButton extends GImageButton {
  public ImageExportButton(PApplet theApplet, float x, float y) {
    super(theApplet, x, y, new String[] { "iexport.png", "iexport.png", "iexport.png" } , "allblack.png");
}

  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}
/*
Copyright 2007 Patrick McGurk
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

public class ImageExportExecutor extends GButton {
  public ImageExportExecutor(PApplet theApplet, float x, float y) {
    super(theApplet, x, y, 50, 20, "Export");
}

  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}
/*
Copyright 2007 Patrick McGurk
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

class IndexEntry {
  String name = "";
  int data_format, fmt_size, data_count, data_len, offset;
  
  public void setName(String s) {
    name = s;
  }
  
  public void setFields(IntList ints) {
    data_format = ints.get(0);
    fmt_size = ints.get(1);
    data_count = ints.get(2);
    data_len = ints.get(3);
    offset = ints.get(4);
  }
  
  public String toString(){
    return name + " " + data_format + " " + fmt_size + " " + data_count + " " + data_len + " " + offset + "\n";
  }
}
/*
Copyright 2007 Patrick McGurk
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
/*
Copyright 2007 Patrick McGurk
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



public class PositionComparator implements Comparator<PeakPoint>{
  @Override
  public int compare(PeakPoint a, PeakPoint b){
    return a.getPosition() > b.getPosition() ? 1 : a.getPosition() < b.getPosition() ? -1 : 0;
  }
}
/*
Copyright 2007 Patrick McGurk
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
/*
Copyright 2007 Patrick McGurk
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

public class ResizeButton extends GImageButton {
  public ResizeButton(PApplet theApplet, float x, float y) {
    super(theApplet, x, y, new String[] { "resize.png", "resize.png", "resize.png" } , "allblack.png");
}

  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}
/*
Copyright 2007 Patrick McGurk
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

public class ResizeExecutor extends GButton {
  public ResizeExecutor(PApplet theApplet, float x, float y) {
    super(theApplet, x, y, 50, 20, "Resize");
}

  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}
/*
Copyright 2007 Patrick McGurk
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

public class ScaleSlider extends GSlider {
  
  public ScaleSlider(PApplet theApplet, int x, int y, int w, int h, int t) {
    super(theApplet, x, y, w, h, t);
    this.setLimits(0.0f, 0.0f, 4.0f);
    this.setNumberFormat(G4P.DECIMAL, 1);
  }
  
  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}
/*
Copyright 2007 Patrick McGurk
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

public class SeqRun {
  StringDict baseRev = new StringDict(); 
  IntDict baseCols = new IntDict(); 
  int[] traceCols;
  
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
/*
Copyright 2007 Patrick McGurk
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

public class TraceWinData extends MyWinData {
  public int viewer_number;
  public ABISeqRun chromat1, chromat2, chromat3;
  public GImageButton imgExport, baseExport, resizeButton;
  public GCheckbox dp_check, rc_check, name_check, bc_check, sub_check, xres_check;
  public GSlider scroller, scaler;
  public GPanel resizePanel, imgExportPanel;
  public GTextField wField, hField;
  public GButton executeResize, cancelResize, executeExport, cancelExport;
  public GLabel wide, high, px1, px2, ielabel1, ielabel2, ielabel3;
  public GDropList resList, fmtList;
  public String titleStr;
  
  public int getViewer() {
    return this.viewer_number;
  }
}
/*
Copyright 2007 Patrick McGurk
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

public class XRCheckbox extends GCheckbox {
  public XRCheckbox(PApplet theApplet, float x, float y, float w, float h) {
    super(theApplet, x, y, w, h);
  }
  
  public int getViewer() {
    return this.vn;
  }
  
  public void setViewer(int viewer_number) {
    vn = viewer_number;
  }
  
  public int vn;
}
/*
Copyright 2007 Patrick McGurk
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

/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

public void imgButton1_click1(GImageButton source, GEvent event) { //_CODE_:imgButton1:482438:
  openTrace();
  println("imgButton1 - GImageButton >> GEvent." + event + " @ " + millis());
} //_CODE_:imgButton1:482438:

/*public void resizeButton_click1(GImageButton source, GEvent event){
  print(event.toString() + "\n");
  if (event.toString() == "CLICKED") {
    //((TraceWinData)source.getPApplet().data).resizePanel.setVisible(true);
    print("This is the resize button");
  }
}*/

// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  surface.setTitle("Sketch Window");
  imgButton1 = new GImageButton(this, 4, 4, new String[] { "open-archive.png", "open-archive.png", "open-archive.png" } , "allblack.png");
  imgButton1.addEventHandler(this, "imgButton1_click1");
  buttonLabel = new GLabel(this, 38, 12, 185, 20);
  buttonLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  buttonLabel.setText("Select chromatogram files to align");
  buttonLabel.setOpaque(true);
}

// Variable declarations 
// autogenerated do not edit
GImageButton imgButton1;
GLabel buttonLabel;
  public void settings() {  size(224, 40, JAVA2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "alpha_0_1_0" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
