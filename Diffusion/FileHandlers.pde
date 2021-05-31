public void open_file() {
  selectInput("Select a file to process: ", "inputSelection");
}

public void inputSelection(File input) {
  if (input == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + input.getAbsolutePath());
    src = loadImage(input.getAbsolutePath());
    buffer = src.copy();
    surface.setSize(src.width, src.height);
  }
  redraw();
}

public void save_file() {
  if (buffer != null) {
    selectOutput("Specify file location and format to save to:", "outputSelection");
  } else {
    println("No image loaded. Click OPEN and select one.");
  }
}

public void outputSelection(File output) {
  if (output == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + output.getAbsolutePath());
    outputPath = output.getAbsolutePath();
    if (split(outputPath, '.').length==1) {
      outputPath+=".png";
    }
    buffer.save(outputPath);
  }
}
