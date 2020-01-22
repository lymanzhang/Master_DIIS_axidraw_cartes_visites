// --------------------------------------------------
class Grid
{
  float margin;
  float padding;
  int resx, resy;
  GridCell[] cells;
  Grid parent;
  float x, y, w, h;
  boolean bMouseOver = false;
  boolean bClicked = false;
  int index = 0;
  float wCell=0,hCell=0;
  Grid(int resx_, int resy_, float x_, float y_, float w_, float h_, float padding_)
  {
    this.resx = resx_;
    this.resy = resy_;
    this.padding = padding_;

    this.x = x_;
    this.y = y_;
    this.w = w_;
    this.h = h_;
  }

  void resetState()
  {
    bMouseOver = false;
    bClicked = false;
  }

  void setParent(Grid parent_)
  {
    this.parent = parent_;
  }

  void setIndex(int index_)
  {
    this.index = index_;
  }

  void buildSub()
  {
    this.wCell = int((this.w - (resx-1)*padding) / float(resx)) ;
    this.hCell = int((this.h - (resy-1)*padding) / float(resy)) ;

    int offset=0;
    float xCell=x, yCell=y;
    cells = new GridCell[resx*resy];
    for (int j=0; j<resy; j++)
    {
      xCell = x;
      for (int i=0; i<resx; i++)
      {
        offset = i + resx*j;
        cells[offset] = new GridCell(6, 5, xCell, yCell, wCell, hCell, 0);
        cells[offset].setIndex(offset);
        cells[offset].setParent(this);
        xCell += (wCell + padding);
      }
      yCell += (hCell + padding);
    }
  }

  void drawForMask(PGraphics pg)
  {
    if (cells != null)
    {
      for (int i=0; i<cells.length; i++)
        cells[i].drawForMask(pg);
    } else
    {
      if (bClicked)
      {
        pg.pushStyle();
        pg.fill(255);
        pg.noStroke();
        pg.rect(x, y, w, h);
        pg.popStyle();
      }
    }
  }

  void draw()
  {
    if (cells != null)
    {
      for (int i=0; i<cells.length; i++)
        cells[i].draw();
    } else
    {
      pushStyle();
      noFill();
      stroke(color(0));
      if (bClicked)
      {
        //        fill(#FFF40D);
      } else if (bMouseOver)
      {
        fill(color(222), 100);
      }
      rect(x, y, w, h);
      popStyle();
    }

    if (bClicked)
    {
      //      fill(0);
      //      ellipse(x+w/2,y+h/2,10,10);
    } else 
    if (bMouseOver)
    {
      pushStyle();
      fill(0);
      noStroke();
      pushMatrix();
      translate(x+w/2, y+h/2);
      ellipse(0, 0, 10, 10);
      textFont(hindRegular, 16);
      text(competences[index], 8, 5);
      popMatrix();
      popStyle();
    }
  }

  void handleMouseMove()
  {
    if (cells != null)
    {
      for (int i=0; i<cells.length; i++)
        cells[i].handleMouseMove();
    } else
    {
      bMouseOver = false;
      if (isMouseOver())
      {
        bMouseOver = true;
      }
    }
  }

  void handleMouseClick()
  {
    if (isMouseOver())
    {
      if (cells != null)
      {
        for (int i=0; i<cells.length; i++)
          cells[i].handleMouseClick();
      } else
      {
        bClicked = !bClicked;
        if (bClicked) addGridCellClicked( this );
        else removeGridCellClicked( this );
      }
    }
  }

  boolean isMouseOver()
  {
    return (mouseX >= this.x && mouseX < (this.x+this.w) && mouseY >= this.y && mouseY <= (this.y + this.h));
  }

  JSONObject getJSONObject()
  {
    JSONObject j = new JSONObject();
    if (cells == null)
    {
      j.setInt("parent_index", parent.index); 
      j.setInt("index", index); 
    }
    return j;
  }

}

// --------------------------------------------------
class GridCell extends Grid
{
  GridCell(int resx_, int resy_, float x_, float y_, float w_, float h_, float padding_)
  {
    super(resx_, resy_, x_, y_, w_, h_, padding_);
  }
}
