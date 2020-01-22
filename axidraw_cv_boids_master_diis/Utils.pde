float dist(PVector A, PVector B)
{
  return dist(A.x, A.y, B.x, B.y);
}

// ----------------------------------------------------------------
String timestamp() 
{
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

// ----------------------------------------------------------------
String getFileExtension(File f)
{
  String[] split = f.getName().split("\\.");
  String ext = split[split.length - 1];
  return ext;
}

class PShapeCustom
{
  String filename;
  PShape shape;
  PShapeCustom(String filename_, PShape shape_)
  {
    this.filename = filename_;
    this.shape = shape_;
  }
}

// ----------------------------------------------------------------
class ControlBgCurve implements CallbackListener
{
  Textlabel label;
  Button btnRemove;
  String filename;
  PShapeCustom shape;
  boolean bRemove = false;
  float y;

  ControlBgCurve()
  {
  }

  void addForCurve(String filename, PShapeCustom s)
  {
    this.filename = filename;
    this.shape = s;
    float hControl = 20;
    this.label = cp5.addTextlabel("lbl_"+filename).setPosition(5, yBgCurvesControls+5).setGroup(groupControls).setText(filename); 
    this.btnRemove = cp5.addButton("btn_"+filename).setLabel("effacer").setPosition(this.label.getPosition()[0] + 200, yBgCurvesControls).setGroup(groupControls); 
    this.btnRemove.addCallback(this); 
    y = yBgCurvesControls;
    yBgCurvesControls += hControl;
  }

  void setPositionY(float y)
  {
    this.label.setPosition(this.label.getPosition()[0], y+5);
    this.btnRemove.setPosition(this.btnRemove.getPosition()[0], y);
  }

  void remove()
  {
    this.btnRemove.removeCallback(this);
    cp5.remove("lbl_"+filename);
    cp5.remove("btn_"+filename);
    bgCurves.remove(shape);
    
  }

  public void controlEvent(CallbackEvent theEvent) 
  {
    if (theEvent.getAction()==ControlP5.ACTION_BROADCAST) 
    {
      // println("click "+this.filename);
      bRemove = true;
    }
  }
}
