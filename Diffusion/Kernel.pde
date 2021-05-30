class Kernel {

  int rows;
  int cols;
  int origin;

  Numberbox[][] matrix;
  ControlP5 controlContext;

  Kernel(ControlP5 _controlContext) {
    matrix = new Numberbox[5][5];
    origin=0;
    controlContext=_controlContext;

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

    for (int r = 0; r < matrix.length; r++) {
      for (int c = 0; c < matrix[0].length; c++) {
        matrix[r][c] = controlContext.addNumberbox("row"+r+"col"+c)
          .setPosition(grid(c), grid(r)+grid(5))
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

  void addRow() {
    if (rows < matrix.length) ++rows;
  }
  void remRow() {
    if (rows > 1) --rows;
  }
  void addCol() {
    if (cols < matrix[0].length) ++cols;
  }
  void remCol() {
    if (cols > origin+1) --cols;
  }

  void update() {
    for (int r = 0; r < matrix.length; r++) {  
    for (int c = 0; c < matrix[0].length; c++) {
      if (r == 0 && c < origin) {
        matrix[r][c].hide();
      } else if (r == 0 && c == origin) {
        matrix[r][c].show().lock().setColorBackground(color(127));
      } else if (r < rows && c < cols) {
        matrix[r][c].show();
      } else {
        matrix[r][c].hide();
      }
    }
  }
  }
  
  float[][] getKernel() {
  if (rows == 0 || cols == 0) {
    println("no kernel available");
  }
  float[][] kernel = new float[rows][cols];
  println("kernel = ");
  for (int r = 0; r < kernel.length; r++) {  
    for (int c = 0; c < kernel[0].length; c++) {
      if (r == 0 && c <= origin) {
        kernel[r][c] = 0.0;
      } else { 
        kernel[r][c] = matrix[r][c].getValue();
      }
      print(kernel[r][c]);
      if (c < kernel[0].length-1) {
        print(", ");
      } else {
        println();
      }
    }
  }
  return kernel;
}

  void normalize(float[][] _matrix) {

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
  }
}
