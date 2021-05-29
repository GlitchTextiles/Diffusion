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
}

public void save_file() {
  selectOutput("Specify file location and format to save to:", "outputSelection");
}

public void outputSelection(File output) {
  if (output == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + output.getAbsolutePath());
    outputPath = output.getAbsolutePath();
    if(split(outputPath,'.').length<2){
      outputPath.concat(".png");
    }
    buffer.save(outputPath);
  }
}
