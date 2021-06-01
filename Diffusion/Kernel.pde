public class Kernel {

  public int rows=1;
  public int cols=1;
  public int origin=0;

  public Numberbox[][] matrix;
  public ControlP5 controlContext;

  public Kernel(ControlP5 _controlContext) {
    this.matrix = new Numberbox[5][5];
    this.controlContext=_controlContext;
    this.initGUI();
    this.update();
  }

  public void initGUI() {
    controlContext.addButton("add_row")
      .setPosition(grid(0), grid(3))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("add\nrow")
      .plugTo(this, "addRow")
      ;
    controlContext.getController("add_row").getCaptionLabel().align(ControlP5.CENTER, CENTER);

    controlContext.addButton("remove_row")
      .setPosition(grid(1), grid(3))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("remove\nrow")
      .plugTo(this, "remRow")
      ;
    controlContext.getController("remove_row").getCaptionLabel().align(ControlP5.CENTER, CENTER);

    controlContext.addButton("add_column")
      .setPosition(grid(2), grid(3))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("add\ncolumn")
      .plugTo(this, "addCol")
      ;
    controlContext.getController("add_column").getCaptionLabel().align(ControlP5.CENTER, CENTER);

    controlContext.addButton("remove_column")
      .setPosition(grid(3), grid(3))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("remove\ncolumn")
      .plugTo(this, "remCol")
      ;
    controlContext.getController("remove_column").getCaptionLabel().align(ControlP5.CENTER, CENTER);

    controlContext.addButton("dec_origin")
      .setPosition(grid(5), grid(3))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("origin\n-")
      .plugTo(this, "decOrigin")
      ;
    controlContext.getController("dec_origin").getCaptionLabel().align(ControlP5.CENTER, CENTER);

    controlContext.addButton("inc_origin")
      .setPosition(grid(6), grid(3))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("origin\n+")
      .plugTo(this, "incOrigin")
      ;
    controlContext.getController("inc_origin").getCaptionLabel().align(ControlP5.CENTER, CENTER);

    for (int r = 0; r < matrix.length; r++) {
      for (int c = 0; c < matrix[0].length; c++) {
        this.matrix[r][c] = controlContext.addNumberbox("row"+r+"col"+c)
          .setPosition(grid(c), grid(r)+grid(4)-guiBufferSize)
          .setSize(guiObjectSize, guiObjectSize)
          .setColorForeground(guiForeground)
          .setColorBackground(guiBackground)
          .setColorActive(guiActive)
          .setScrollSensitivity(1.0)
          .setDecimalPrecision(0)
          .setMax(24)
          .setMin(-24)
          .setValue(0)
          .setLabel("")
          .hide()
          ;
      }
    }
  }

  public void addRow() {
    if (rows < this.matrix.length) ++rows;
    this.update();
  }

  public void remRow() {
    if (rows > 1) --rows;
    this.update();
  }

  public void addCol() {
    if (cols < this.matrix[0].length) ++cols;
    this.update();
  }

  public void remCol() {
    if (cols > origin+1) --cols;
    this.update();
  }

  public void decOrigin() {
    if ( origin > 0 ) --origin;
    this.update();
  }

  public void incOrigin() {
    if ( origin < cols-1 ) ++origin;
    this.update();
  }

  public void update() {
    for (int r = 0; r < this.matrix.length; r++) {  
      for (int c = 0; c < this.matrix[0].length; c++) {
        if (r == 0 && c < origin) {
          this.matrix[r][c].hide();
        } else if (r == 0 && c == origin) {
          this.matrix[r][c]
            .show()
            .lock()
            .setColorBackground(guiOrigin)
            .setColorForeground(guiForegroundInactive)
            .setColorValue(guiValueInactive)
            ;
        } else if (r < rows && c < cols) {
          this.matrix[r][c]
            .show()
            .unlock()
            .setColorBackground(guiBackground)
            .setColorForeground(guiForeground)
            .setColorValue(guiValue)
            ;
        } else {
          this.matrix[r][c]
            .show()
            .lock()
            .setColorBackground(guiBackgroundInactive)
            .setColorForeground(guiForegroundInactive)
            .setColorValue(guiValueInactive)
            ;
        }
      }
    }
  }

  public float[][] getKernel() {
    float[][] kernel = new float[rows][cols];
    for (int r = 0; r < kernel.length; r++) {  
      for (int c = 0; c < kernel[0].length; c++) {
        if (r == 0 && c <= origin) {
          kernel[r][c] = 0.0;
        } else { 
          kernel[r][c] = matrix[r][c].getValue();
        }
      }
    }
    return this.normalize(kernel);
  }

  public float[][] normalize(float[][] _matrix) {

    float[][] normalized = new float[rows][cols];
    float sum=0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        sum+=abs(_matrix[r][c]);
      }
    }

    if (sum != 0.0) {
      for (int r = 0; r < _matrix.length; r++) {
        for (int c = 0; c < _matrix[r].length; c++) {
          normalized[r][c] = _matrix[r][c]/sum;
        }
      }
    }
    return normalized;
  }
}
