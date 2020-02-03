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

  cp5.addSlider("maxForceBoids").setRange(0.05, 6.0).setValue(maxForceBoids).setLabel("Force de rappel")
    .setSize(wSlider, hSlider).setPosition(x, y).setGroup(groupControls);
  y+=hSlider+margin;

  cp5.addRange("maxSpeed").setRange(0.05, 10.0).setRangeValues(speedInfBoids, speedSupBoids).setLabel("Vitesses")
    .setSize(wSlider, hSlider).setPosition(x, y).setGroup(groupControls);
  y+=hSlider+margin;

  rbColors = cp5.addRadioButton("rbColors")
    .setPosition(x, y).setSize(wSlider/5, hSlider).setGroup(groupControls)
    .setItemsPerRow(5)
    .setSpacingColumn(20)
    .addItem("c1", 0).addItem("c2", 1).addItem("c3", 2).addItem("c4", 3).addItem("c5", 4);
  rbColors.activate(1);

  y+=hSlider+margin;

  rbModes = cp5.addRadioButton("rbModes")
    .setPosition(x, y).setSize(wSlider/5, hSlider).setGroup(groupControls)
    .setItemsPerRow(3)
    .setSpacingColumn(40)
    .addItem("boids", 0).addItem("lignes", 1).addItem("lignes 2", 2);
  rbModes.activate(mode);

  y+=hSlider+margin;

  cp5.addToggle("bDrawTargets").setLabel("dessin des points")
    .setPosition(x, y).setSize(hSlider, hSlider).setGroup(groupControls);

  y+=2*hSlider+margin;

  Textlabel lblInstructions = cp5.addTextlabel("lbInstructions").setText("+ Instructions\nTouche 'e' pour passer du mode edition au mode dessin")
  .setPosition(x,400-40).setSize(390,40).setGroup(groupControls);
  
  
  yBgCurvesControlsBegin = yBgCurvesControls = y;

  // ------------------------------------------------------------------------------

  Button btnExport = cp5.addButton("exportSVG").setLabel("exporter courbe")
    .setSize(wButton, hButton).setPosition(width-wButton-margin, height-hButton-5);

  Button btnExportCards = cp5.addButton("exportCards").setLabel("exporter cartes")
    .setSize(wButton, hButton).setPosition(btnExport.getPosition()[0]-wButton-margin, height-hButton-5);


  Button btnSaveGrid = cp5.addButton("saveCellsVisited").setLabel("sauver la grille")
    .setSize(wButton, hButton).setPosition(btnExportCards.getPosition()[0]-wButton-margin, height-hButton-5);

  Button btnEraseGrid = cp5.addButton("eraseCellsVisited").setLabel("effacer la grille")
    .setSize(wButton, hButton).setPosition(btnSaveGrid.getPosition()[0]-wButton-margin, height-hButton-5);

  Button btnSaveApp = cp5.addButton("saveApp").setLabel("sauver la config")
    .setSize(wButton, hButton).setPosition(btnEraseGrid.getPosition()[0]-wButton-margin, height-hButton-5);

  btnRelaunch = cp5.addButton("relaunch").setLabel("relancer")
    .setSize(wButton, hButton).setPosition(btnSaveApp.getPosition()[0]-wButton-margin, height-hButton-5);

  groupControls.close();
}

// ----------------------------------------------------------
void controlEvent(ControlEvent theEvent) 
{
  if (theEvent.isFrom(rbColors)) 
  {
    int indexColor = int(theEvent.getGroup().getValue());
    colorBoids = colorsBoids[indexColor];
  }
  else if (theEvent.isFrom(rbModes)) 
  {
    int indexMode = int(theEvent.getGroup().getValue());
    setMode(indexMode);
  }
}
