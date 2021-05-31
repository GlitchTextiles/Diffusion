public class ControlFrame extends PApplet {

  int w, h, x, y;
  ControlP5 cp5;
  PApplet parent;
  RadioButton dither_mode_radio;

  public ControlFrame(PApplet _parent, int _x, int _y, int _w, int _h) {
    super();   
    parent = _parent;
    w=_w;
    h=_h;
    x=_x;
    y=_y;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w, h);
  }

  public void setup() {
    surface.setSize(w, h);
    surface.setLocation(x, y);
    cp5 = new ControlP5(this);   
    frameRate(30);

    diffusionKernel = new Kernel(this.cp5);

    // row 0 controls
    cp5.addButton("open_image")
      .setPosition(grid(0), grid(0))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground) 
      .setColorActive(guiActive)
      .setLabel("OPEN")
      .plugTo(parent, "open_file")
      ;
    cp5.getController("open_image").getCaptionLabel().align(ControlP5.CENTER, CENTER);

    cp5.addButton("save_image")
      .setPosition(grid(1), grid(0))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground) 
      .setColorActive(guiActive)
      .setLabel("SAVE")
      .plugTo(parent, "save_file")
      ;
    cp5.getController("save_image").getCaptionLabel().align(ControlP5.CENTER, CENTER);

    cp5.addToggle("preview")
      .setPosition(grid(2), grid(0))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground) 
      .setColorActive(guiActive)
      .setLabel("PREVIEW")
      .plugTo(parent, "preview")
      ;
    cp5.getController("preview").getCaptionLabel().align(ControlP5.CENTER, CENTER);

    dither_mode_radio= cp5.addRadioButton("palette_mode")
      .setPosition(grid(0), grid(1))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground) 
      .setColorActive(guiActive)
      .setItemsPerRow(2)
      .setSpacingColumn(guiBufferSize)
      .addItem("BW", 0)
      .addItem("COLOR", 1)
      .plugTo(this, "setPaletteMode")
      .activate(0)
      ;
    for (Toggle t : dither_mode_radio.getItems()) {
      t.getCaptionLabel().align(ControlP5.CENTER, CENTER);
    }

    cp5.addSlider("threshold")
      .setPosition(grid(0), grid(2))
      .setSize(510, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground) 
      .setColorActive(guiActive)
      .setRange(-255, 255)
      .setDecimalPrecision(0)
      .setLabel("threshold")
      .plugTo(this, "setThreshold")
      .setValue(0)
      ;
    cp5.getController("threshold").getCaptionLabel().align(ControlP5.CENTER, CENTER);
  }

  public void draw() {
    background(backgroundColor);
    diffusionKernel.update();
  }

  void mouseReleased() {
    parent.redraw();
  }

  public void reset() {
    buffer=src.copy();
  }

  public void setPaletteMode(int _id) {
    switch(_id) {
    case 0:
      palette=bw.copy();
      break;
    case 1:
      palette=pci.copy();
      break;
    }
  }

  public void setDitherMode(int _id) {
    dither_mode = _id;
  }

  public void setThreshold(float _value) {
    threshold = color(int(_value));
  }
}


public int grid( int _pos) {
  return gridSize * _pos + gridOffset;
}
