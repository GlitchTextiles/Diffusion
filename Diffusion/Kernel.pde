class Kernel {

  int rows=6;
  int cols=6;
  int origin;

  float[][] matrix;
  float[][] normalized;

  Group group;
  ControlP5 controlContext;

  Kernel(int _rows, int _cols, ControlP5 _controlContext) {
    rows=_rows;
    cols=_cols;
    matrix = new float[rows][cols];
    origin=0;
    controlContext=_controlContext;
    group = controlContext.addGroup("kernel");

    controlContext.addButton("add_row")
      .setPosition(grid(0), grid(4))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("add\nrow")
      .plugTo(this, "addRow")
      ;
    controlContext.getController("add_row").getCaptionLabel().align(ControlP5.CENTER, CENTER);

    controlContext.addButton("remove_row")
      .setPosition(grid(1), grid(4))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("remove\nrow")
      .plugTo(this, "remRow")
      ;
    controlContext.getController("remove_row").getCaptionLabel().align(ControlP5.CENTER, CENTER);

    controlContext.addButton("add_column")
      .setPosition(grid(2), grid(4))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("add\nrow")
      .plugTo(this, "addCol")
      ;
    controlContext.getController("add_column").getCaptionLabel().align(ControlP5.CENTER, CENTER);

    controlContext.addButton("remove_column")
      .setPosition(grid(3), grid(4))
      .setSize(guiObjectSize, guiObjectSize)
      .setColorForeground(guiForeground)
      .setColorBackground(guiBackground)
      .setColorActive(guiActive)
      .setLabel("remove\ncolumn")
      .plugTo(this, "remCol")
      ;
    controlContext.getController("remove_column").getCaptionLabel().align(ControlP5.CENTER, CENTER);
  }

  void addRow() {
  }
  void remRow() {
  }
  void addCol() {
  }
  void remCol() {
  }

  void update() {
    controlContext.remove("kernel");
    group = controlContext.addGroup("kernel");
    for (int r = 0; r < matrix.length; r++) {
      for (int c = 0; c < matrix[0].length; c++) {
        controlContext.addNumberbox("kernel"+r+c)
          .setPosition(grid(c), grid(r)+grid(5))
          .setSize(guiObjectSize, guiObjectSize)
          .setColorForeground(guiForeground)
          .setColorBackground(guiBackground)
          .setColorActive(guiActive)
          .setScrollSensitivity(1)
          .setDecimalPrecision(0)
          .moveTo(group)
          ;
      }
    }
  }

  void normalize(float[][] _matrix) {

    this.normalized = new float[_matrix.length][_matrix[0].length];
    float sum=0;

    for (int r = 0; r < _matrix.length; r++) {
      for (int c = 0; c < _matrix[0].length; c++) {

        sum+=abs(_matrix[r][c]);
      }
    }
    if (sum != 0.0) {
      for (int r = 0; r < _matrix.length; r++) {
        for (int c = 0; c < _matrix[r].length; c++) {
          this.normalized[r][c] = _matrix[r][c]/sum;
        }
      }
    }
  }
}
