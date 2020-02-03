
// --------------------------------------------------
import controlP5.*;
import java.io.*;
import java.util.*;
import java.lang.reflect.*;
import java.awt.event.*;
import processing.svg.*;
import drop.*;

// --------------------------------------------------
PApplet applet;
SDrop drop;

// --------------------------------------------------
int MODE_BOIDS = 0;
int MODE_LINES = 1;
int MODE_LINES2 = 2;
int mode = MODE_LINES2;

// --------------------------------------------------
// Interface
ControlP5 cp5;
float yBgCurvesControls = 5;
float yBgCurvesControlsBegin = 5;
Group groupControls;
Button btnRelaunch;
RadioButton rbColors;
RadioButton rbModes;

// --------------------------------------------------
ArrayList<Boid> boids;
ArrayList<PVector> targets;
ArrayList<Grid> cellsClicked;

float alphaTargets = 200.0;
float strokeWeightBoids = 5;
float maxForceBoids = 0.05;
float speedInfBoids = 8.0;
float speedSupBoids = 20.0;

// --------------------------------------------------
float margin = 150;
boolean bExportSVG = false;
float distTargetMin = 3;
float gridRndDistort = 10;

float marginImage = 56;
float paddingImage = 40;

boolean bEdit = true;
boolean bDrawTargets = false;
ArrayList<PShapeCustom> bgCurves;
ArrayList<ControlBgCurve> controlsBgCurves;

// --------------------------------------------------
// Assets
PImage bg;
float f = 1.75;
PFont hindRegular;

// --------------------------------------------------
// Grid
Grid grid;

// --------------------------------------------------
// App State
String filenameCellsVisited = "";


// --------------------------------------------------
void settings()
{
  applet=(PApplet)this;
  loadAssets();
  setupWindow();
  createGrid();
}

// --------------------------------------------------
void setupWindow()
{
  int wWindow = int( float(bg.width)/f );
  int hWindow = int( float(bg.height)/f );
  size(wWindow, hWindow);
  bg.resize(wWindow, hWindow);
}

// --------------------------------------------------
void setMode(int m)
{
  mode = m;  
  if (mode == MODE_BOIDS)
    run();
}

// --------------------------------------------------
void setWindowTitle(String title)
{
  surface.setTitle(title);
}

// --------------------------------------------------
void createGrid()
{
  marginImage /= f;
  paddingImage /= f;

  float wGrid = width-2*marginImage;
  float hGrid = height-2*marginImage;
  grid = new Grid(4, 4, marginImage, marginImage, wGrid, hGrid, paddingImage);
  grid.buildSub();
  for (int i=0; i<grid.cells.length; i++)
    grid.cells[i].buildSub();

  cellsClicked = new ArrayList<Grid>();
}

// --------------------------------------------------
void loadAssets()
{
  bg = loadImage("images/cdv-montaigne5.jpg");
  hindRegular = loadFont("fonts/Hind-Regular-24.vlw");

  bgCurves = new ArrayList<PShapeCustom>();
  controlsBgCurves = new ArrayList<ControlBgCurve>();
}

// --------------------------------------------------
void setup()
{
  drop = new SDrop(this);
  initControls();
  setWindowTitle("Master DIIS 2019-2020 / Cartes de visite génératives");
  loadAppState();
  setEdit(true);
  setMode(mode);
}

// --------------------------------------------------
void relaunch()
{
  run();
}

// --------------------------------------------------
void run()
{
  boids = new ArrayList<Boid>();
  if (targets != null && targets.size() >= 2)
    createBoids(1, targets.get(0).copy().add(random(-gridRndDistort, gridRndDistort), random(-gridRndDistort, gridRndDistort)));
  else
    println("run() : create at least two targets !");
}

// --------------------------------------------------
void createBoids(int nbBoids, PVector posStart)
{
  for (int i=0; i<nbBoids; i++)
  {
    // Boid(float x, float y, float maxspeed_inf_, float maxspeed_sup_, float maxforce_)  
    Boid b = new Boid(posStart.x, posStart.y, speedInfBoids, speedSupBoids, maxForceBoids);
    b.targetIndex = 0;

    boids.add( b );
  }
}

// --------------------------------------------------
void updateBoids()
{
  if (targets == null) return;
  if (targets.size() <= 2) return;
  if (boids == null) return;

  PVector target = null;
  int nbTargets = targets.size();
  for (Boid b : boids)
  {
    target = targets.get(b.targetIndex);
    if (b.stop == false)
    {
      b.update();
      PVector force = b.seek( target );
      b.applyForce(force);

      if (dist(b.position, target) < 10)
      {
        b.targetIndex = (b.targetIndex+1)%nbTargets;
        b.maxforce = random(1, 4);
        if (b.targetIndex == 0) 
        { 
          b.stop();
          //          b.positionHistory = new ArrayList<PVector>();
          //          PVector posStart = targets.get(b.targetIndex); 
          //          b.position.set(posStart.x, posStart.y);
        }
      }
    }
  }
}

// --------------------------------------------------
void drawBackgroundCurves()
{
  synchronized(bgCurves)
  {
    for (PShapeCustom bgCurve : bgCurves)
      shape(bgCurve.shape, 0, 0, width, height);
  }
}

// --------------------------------------------------
void drawBoids()
{
  if (boids == null) return;

  for (Boid b : boids)
  {
    if (bExportSVG == false)
      b.render();
    b.renderHistory();
  }
}

// --------------------------------------------------
void createTargets()
{
  targets = new ArrayList<PVector>();
  for (Grid g : cellsClicked)
  {
    targets.add( new PVector( g.x+0.5*g.w, g.y+0.5*g.h ) );
  }
}

// --------------------------------------------------
void drawTargets()
{
  if (targets == null) return;
  if (bEdit || bDrawTargets)
  {
    pushStyle();
    noStroke();
    int index = 0;  
    fill(0, alphaTargets);
    textFont(hindRegular, 14);
    for (PVector p : targets)
    {
      ellipse(p.x, p.y, 10, 10);
      if (bEdit)
        text(""+index, p.x+8, p.y+4);
      index++;
    }
    popStyle();
  }
}

// --------------------------------------------------
void drawBackground()
{
  image(bg, 0, 0);
}

// --------------------------------------------------
void drawInfos()
{
  pushStyle();
  fill(0);
  textFont(hindRegular, 16);
  text(( bEdit ? "Mode édition" : "Mode courbe"), marginImage, height-12);
  popStyle();
}

// --------------------------------------------------
void drawLines()
{
  if (targets == null) return;
  
  pushStyle();
  strokeWeight(strokeWeightBoids);
  stroke(colorBoids);
  int nbTargets = targets.size();
  PVector A,B;
  for (int i=0;i<nbTargets-1;i++)
  {
    A = targets.get(i);
    B = targets.get(i+1);
    line(A.x,A.y,B.x,B.y);
  }
  popStyle();
}

// --------------------------------------------------
void drawLines2()
{
  if (targets == null) return;
  
  pushStyle();
  strokeWeight(strokeWeightBoids);
  stroke(colorBoids);
  noFill();
  int nbTargets = targets.size();
  PVector A,B;
  for (int i=0;i<nbTargets-1;i++)
  {
    A = targets.get(i);
    B = targets.get(i+1);
    
    float dx = abs(B.x-A.x);
    float dy = abs(B.y-A.y);
    
    if (dx <= 0.001 || dy <= 0.001)
    {
      line(A.x,A.y,B.x,B.y);
    }
    else
    {
      if (B.x > A.x)
        bezier( A.x,A.y,A.x+dx,A.y,B.x-dx,B.y,B.x,B.y );
      else
        bezier( A.x,A.y,A.x-dx,A.y,B.x+dx,B.y,B.x,B.y );
    }

  }
  popStyle();
}



// --------------------------------------------------
void draw()
{
  // Update
  updateBoids();

  // Draw
  drawBackground();
  if (bEdit)
    grid.draw();
  drawBackgroundCurves();
  //  image(mask,0,height-height/8,width/9,height/8);

  if (bEdit)
  {
  } else
  {
    if (bExportSVG)
    {
      beginRecord(SVG, "data/exports/svg/courbe_"+timestamp()+".svg");
    }
    if (mode == MODE_BOIDS)
      drawBoids();
    else if (mode == MODE_LINES)
      drawLines();
    else if (mode == MODE_LINES2)
      drawLines2();

    if (bExportSVG)
    {
      endRecord();
      bExportSVG = false;
    }
  }
  drawTargets();
  drawInfos();
  cp5.draw();

  // Remove controls not needed
  removeControlsBgCurves();
}


// ----------------------------------------------------------
void toggleEdit()
{
  setEdit( !bEdit );
}
// ----------------------------------------------------------
void setEdit(boolean is)
{
  bEdit = is;
  if (bEdit)
  {
    btnRelaunch.hide();
  } else
  {
    btnRelaunch.show();
    run();
  }
}

// ----------------------------------------------------------
void mouseMoved()
{
  if (bEdit && cp5.isMouseOver()==false)
    grid.handleMouseMove();
}

// ----------------------------------------------------------
void mousePressed()
{
  if (bEdit && cp5.isMouseOver()==false)
  {
    grid.handleMouseClick();
  }
}

// ----------------------------------------------------------
void addGridCellClicked(Grid g)
{
  cellsClicked.add(g);
  createTargets();
}

// ----------------------------------------------------------
void removeGridCellClicked(Grid g)
{
  cellsClicked.remove(g);
  createTargets();
}


// ----------------------------------------------------------
void keyPressed()
{
  if (key == 'v')
  {
    exportSVG();
  } else if (key == 'e')
  {
    toggleEdit();
  }
  else if (key == 'c')
  {
    exportCards();
  }
}

// ----------------------------------------------------------
void exportSVG()
{
  bExportSVG = true;
}



// --------------------------------------------------
void saveApp()
{
  saveAppState();
}

// --------------------------------------------------
void eraseCellsVisited()
{
  for (int i=0; i<grid.cells.length; i++)
    grid.cells[i].resetState();
  cellsClicked = new ArrayList<Grid>();
  createTargets();
  setEdit(true);
}

// --------------------------------------------------
void saveCellsVisited()
{
  JSONArray ja = new JSONArray();
  int index = 0;
  for (Grid g : cellsClicked)
    ja.setJSONObject(index++, g.getJSONObject());
  saveJSONArray(ja, "data/exports/grid/grid_"+timestamp()+".json");
}

// --------------------------------------------------
void loadCellsVisited(String filename)
{
  if (filenameCellsVisited.equals("")) 
    return;
  for (int i=0; i<grid.cells.length; i++)
    grid.cells[i].resetState();
  cellsClicked = new ArrayList<Grid>();


  JSONArray ja = loadJSONArray("data/exports/grid/"+filename);
  for (int i=0; i<ja.size(); i++)
  {
    JSONObject jCell = ja.getJSONObject(i);
    int parent_index = jCell.getInt("parent_index");
    int index = jCell.getInt("index");

    Grid g = grid.cells[parent_index].cells[index];
    g.bClicked = true;
    cellsClicked.add( g );
  }
  createTargets();
}

// ----------------------------------------------------------
void removeControlsBgCurves()
{
  synchronized (controlsBgCurves)
  {
    for (int i=controlsBgCurves.size()-1; i>=0; i--)
    {
      ControlBgCurve c = controlsBgCurves.get(i);
      if (c.bRemove)
      {
        c.remove();
        controlsBgCurves.remove(c);
      }
    }

    float y = yBgCurvesControlsBegin;
    for (ControlBgCurve c : controlsBgCurves)
    {
      c.setPositionY(y);
      y+=20;
    }
  }
}

// ----------------------------------------------------------
void updateControlsBgCurves(String filename, PShapeCustom s)
{
  ControlBgCurve newControlBgCurve = new ControlBgCurve();
  newControlBgCurve.addForCurve(filename, s);
  synchronized (controlsBgCurves)
  {
    controlsBgCurves.add( newControlBgCurve );
  }
}

// ----------------------------------------------------------
void dropEvent(DropEvent theDropEvent) 
{
  if (theDropEvent.isFile())
  {
    File f = theDropEvent.file();
    if (getFileExtension(f).toLowerCase().equals("svg"))
    {
      String filename = f.getName();
      PShape s = loadShape(f.getPath());
      if (s != null)
      {
        
        synchronized(bgCurves)
        {
          PShapeCustom newShape = new PShapeCustom(filename,s);
          bgCurves.add( newShape );
          updateControlsBgCurves(filename, newShape);
        }
        
      }
    } else if (getFileExtension(f).toLowerCase().equals("json"))
    {
      String filename = f.getName();
      loadCellsVisited(filename);

      filenameCellsVisited = filename;
    }
  }
}

// ----------------------------------------------------------
void saveAppState()
{
  JSONObject jAppState = new JSONObject();
  jAppState.setString("filenameCellsVisited",filenameCellsVisited);
  JSONArray jBgCurves = new JSONArray();
  synchronized(bgCurves)
  {
    int index=0;
    for (PShapeCustom c : bgCurves)
    {
      JSONObject jc = new JSONObject();
      jc.setString("filename", c.filename);
      jBgCurves.setJSONObject( index++, jc );
    }
    jAppState.setJSONArray("curves", jBgCurves);
  }
  
  saveJSONObject(jAppState, "appstate.json");
}

// ----------------------------------------------------------
void loadAppState()
{
  try{
    JSONObject jAppState = loadJSONObject("appstate.json");
    filenameCellsVisited = jAppState.getString("filenameCellsVisited");
    JSONArray jBgCurves = jAppState.getJSONArray("curves");
    for (int i=0; i < jBgCurves.size(); i++)
    {
      JSONObject j = jBgCurves.getJSONObject(i);
      String filename = j.getString("filename");
      PShape s = loadShape( "data/exports/svg/"+filename );
      if (s != null)
      {
        synchronized(bgCurves)
        {
          PShapeCustom newShape = new PShapeCustom(filename,s);
          bgCurves.add( newShape );
          updateControlsBgCurves(filename, newShape);
        }
      }
    }
    
    loadCellsVisited(filenameCellsVisited);
  } catch(Exception e){
  println(e);
  }
}


// ----------------------------------------------------------
void exportCards()
{
    String folderCards = "data/exports/cards_"+timestamp()+"/";
    for (int j=0; j<grid.resy; j++)
    {
      for (int i=0; i<grid.resx; i++)
      {
        int offset = i + grid.resx*j;
        GridCell cell = grid.cells[offset];
        PImage crop = get((int)cell.x,(int)cell.y,(int)cell.w,(int)cell.h);
        crop.save(folderCards+"card_"+offset+".png");
      }
    }
}
