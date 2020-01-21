
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
// Interface
ControlP5 cp5;
float yBgCurvesControls = 5;
float yBgCurvesControlsBegin = 5;
Group groupControls;
Button btnRelaunch;
RadioButton rbColors;

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

ArrayList<PShape> bgCurves;
ArrayList<ControlBgCurve> controlsBgCurves;

// --------------------------------------------------
// Assets
PImage bg;
float f = 1.25;
PFont hindRegular;

// --------------------------------------------------
// Grid
Grid grid;

// --------------------------------------------------
// App State
String filenameCellsVisited = "";


// --------------------------------------------------
color[] colorsBoids = 
  {
  color(255, 255, 0), 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 0, 255)
};

color colorBoids = colorsBoids[0];
// --------------------------------------------------
String[] competences = 
  {
  "Collaboration", 
  "Esprit critique", 
  "Logique", 
  "Empathie", 
  "Créatif", 
  "Technique", 
  "Curieux", 
  "Esprit analytique", 
  "Observateur", 
  "Méthodique", 
  "Entrepreneur", 
  "Organisé", 
  "Leadership", 
  "Perfectionniste", 
  "Gestion du stress", 
  "Programmation", 
  "À l'écoute", 
  "Produit", 
  "UX / UI", 
  "Communication / Graphisme", 
  "Recherche et théorie", 
  "Espace", 
  "Prototypage", 
  "Être force de proposition", 
  "Productivité", 
  "Vision systémique", 
  "Efficacité", 
  "Modélisation 3D", 
  "Expression orale / écrite", 
  " ??? "
};


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

  bgCurves = new ArrayList<PShape>();
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
    for (PShape bgCurve : bgCurves)
      shape(bgCurve, 0, 0, width, height);
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
  pushStyle();
  noStroke();
  int index = 0;  
  fill(0, alphaTargets);
  textFont(hindRegular, 14);
  for (PVector p : targets)
  {
    ellipse(p.x, p.y, 10, 10);
    text(""+index, p.x+8, p.y+4);
    index++;
  }
  popStyle();
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
  text(( bEdit ? "Mode édition" : "Mode courbe" ) + " (touche e pour changer)", marginImage, height-12);
  popStyle();
}

// --------------------------------------------------
void draw()
{
  // Update
  updateBoids();

  // Draw
  drawBackground();
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
    drawBoids();
    //mask(mask,0,0);

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
}

// ----------------------------------------------------------
void exportSVG()
{
  bExportSVG = true;
}

// ----------------------------------------------------------
void initControls()
{
  int wSlider = 400, hSlider = 20, margin = 5;
  int wButton = 100;
  int hButton = hSlider;
  float x = 5, y = 5;

  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);

  groupControls = cp5.addGroup("Menu").setPosition(0, 10).setBackgroundHeight(400).setWidth(wSlider+2*margin+100).setBackgroundColor(color(0, 190));

  cp5.addSlider("strokeWeightBoids").setRange(1, 6).setValue(strokeWeightBoids).setLabel("Epaisseur")
    .setSize(wSlider, hSlider).setPosition(x, y).setGroup(groupControls);
  y+=hSlider+margin;

  cp5.addSlider("maxForceBoids").setRange(0.05, 4.0).setValue(maxForceBoids).setLabel("Force de rappel")
    .setSize(wSlider, hSlider).setPosition(x, y).setGroup(groupControls);
  y+=hSlider+margin;

  cp5.addRange("maxSpeed").setRange(0.05, 4.0).setRangeValues(speedInfBoids, speedSupBoids).setLabel("Vitesses")
    .setSize(wSlider, hSlider).setPosition(x, y).setGroup(groupControls);
  y+=hSlider+margin;

  rbColors = cp5.addRadioButton("radioButton")
    .setPosition(x, y).setSize(wSlider/5, hSlider).setGroup(groupControls)
    .setItemsPerRow(5)
    .setSpacingColumn(20)
    .addItem("c1", 0).addItem("c2", 1).addItem("c3", 2).addItem("c4", 3).addItem("c5", 4);
  rbColors.activate(0);

  y+=hSlider+margin;
  yBgCurvesControlsBegin = yBgCurvesControls = y;

  // ------------------------------------------------------------------------------

  Button btnExport = cp5.addButton("exportSVG").setLabel("exporter")
    .setSize(wButton, hButton).setPosition(width-wButton-margin, height-hButton-5);

  Button btnSaveGrid = cp5.addButton("saveCellsVisited").setLabel("sauver la grille")
    .setSize(wButton, hButton).setPosition(btnExport.getPosition()[0]-wButton-margin, height-hButton-5);

  Button btnEraseGrid = cp5.addButton("eraseCellsVisited").setLabel("effacer la grille")
    .setSize(wButton, hButton).setPosition(btnSaveGrid.getPosition()[0]-wButton-margin, height-hButton-5);

  Button btnSaveApp = cp5.addButton("saveApp").setLabel("sauver la config")
    .setSize(wButton, hButton).setPosition(btnEraseGrid.getPosition()[0]-wButton-margin, height-hButton-5);

  btnRelaunch = cp5.addButton("relaunch").setLabel("relancer")
    .setSize(wButton, hButton).setPosition(btnSaveApp.getPosition()[0]-wButton-margin, height-hButton-5);

  groupControls.close();
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
void controlEvent(ControlEvent theEvent) 
{
  if (theEvent.isFrom(rbColors)) 
  {
    int indexColor = int(theEvent.getGroup().getValue());
    colorBoids = colorsBoids[indexColor];
  }
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
void updateControlsBgCurves(String filename, PShape s)
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
          bgCurves.add( s );
        }
        updateControlsBgCurves(filename, s);
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
  
  saveJSONObject(jAppState, "appstate.json");
}

// ----------------------------------------------------------
void loadAppState()
{
  try{
    JSONObject jAppState = loadJSONObject("appstate.json");
    filenameCellsVisited = jAppState.getString("filenameCellsVisited");
    loadCellsVisited(filenameCellsVisited);
  } catch(Exception e){
  
  }
}
