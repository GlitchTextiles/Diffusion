//resources
// https://en.wikipedia.org/wiki/Dither
// https://web.archive.org/web/20190316064436/http://www.efg2.com/Lab/Library/ImageProcessing/DHALF.TXT
// https://tannerhelland.com/2012/12/28/dithering-eleven-algorithms-source-code.html
// inspiration
// http://danieltemkin.com/DitherStudies/

import controlP5.*;
import java.util.*;

String inputPath;
String outputPath;

boolean preview, resample, evenX, evenY;

PImage src;
PImage buffer;
PGraphics banner;

color threshold;

//these are used by the GUI and associated objects
int guiObjectSize = 40;
int guiObjectWidth = 600;
int guiBufferSize = 10;
int gridSize = guiObjectSize + guiBufferSize;
int gridOffset = guiBufferSize;

color backgroundColor = color(15);
color guiGroupBackground = color(30);
color guiBackground = color(60);
color guiForeground = color(120);
color guiActive=color(150);
color guiOrigin=color(127);

int controlFrame_w = 530;
int controlFrame_h = grid(9);
int controlFrame_x = 0;
int controlFrame_y = 0;

int screen_x = controlFrame_w;
int screen_y = 0;
int screen_w = 600;
int screen_h = 320;

ControlFrame GUI;
Kernel diffusionKernel;
Palette pci, bw, palette;
PaletteList palettes;

void setup() {
  size(10, 10);
  surface.setSize(screen_w, screen_h);
  surface.setLocation(screen_x, screen_y);
  pci = new Palette("Pure Country Weavers", loadStrings(dataPath("")+"/palette/palette.txt"));
  bw = new Palette("Black and White").add(color(0)).add(color(255));
  GUI = new ControlFrame(this, controlFrame_x, controlFrame_y, controlFrame_w, controlFrame_h);
  banner=generateBanner();
  background(backgroundColor);
  noSmooth();
  noLoop();
}

void draw() {
  background(backgroundColor);
  if (buffer != null && palettes.get() != null) {
    if (preview) { 
      buffer = dither(src.copy(), palettes.get());
      if (resample) resample(buffer);
      image(buffer, 0, 0);
    } else {
      image(src, 0, 0);
    }
  } else {
    image(banner, 0, 0);
  }
}

PImage resample(PImage _image) {
  _image.loadPixels();
  println("_image.width: "+_image.width+", _image.height: "+_image.height);
  PImage half = createImage(_image.width/2, _image.height/2, RGB);
  println("half.width: "+half.width+", half.height: "+half.height);
  for (int y = 0; y < half.height; y++) {
    for (int x = 0; x < half.width; x++) {
      if (evenX && evenY) half.pixels[x+half.width*y] = _image.pixels[(2*x)+_image.width*(2*y)];
      if (!evenX && evenY) half.pixels[x+half.width*y] = _image.pixels[(2*x+1)+_image.width*(2*y)];
      if (evenX && !evenY) half.pixels[x+half.width*y] = _image.pixels[(2*x)+_image.width*(2*y+1)];
      if (!evenX && !evenY) half.pixels[x+half.width*y] = _image.pixels[(2*x+1)+_image.width*(2*y+1)];
    }
  }
  for (int y = 0; y < half.height*2; y++) {
    for (int x = 0; x < half.width*2; x++) {
      _image.pixels[(x)+_image.width*(y)] = half.pixels[(x/2)+half.width*(y/2)];
    }
  }
  _image.updatePixels();
  return _image;
}

PImage dither(PImage _image, Palette _palette) {

  // 1. sample pixel
  // 2. select candidate from palette
  // 3. write candidate to image
  // 4. calculate and propagate error

  _image.loadPixels();

  color candidate=color(0);
  float[][] kernel = diffusionKernel.getKernel();
  int start=diffusionKernel.origin;

  for (int y = 0; y < _image.height; y++) {
    for (int x = 0; x < _image.width; x++) {

      int pxCoord = x+_image.width*y;
      color px = _image.pixels[pxCoord]+threshold;
      candidate = _palette.rgbClosest(px).getColor();
      _image.pixels[pxCoord]=candidate;

      for (int i = 0; i < kernel.length; i++) {
        if (i+y < _image.height) {
          float[] kernel_row = kernel[i];
          for (int j = 0; j < kernel_row.length; j++) {
            if ((j+x-start) < _image.width) {               
              float kernel_value = kernel_row[j];
              if (kernel_value != 0) {

                int px2Coord = (x+j-start)+_image.width*(y+i);
                color px2 = _image.pixels[px2Coord];

                float errorR = kernel_value * ((px >> 16 & 0xFF) - (candidate >> 16 & 0xFF));
                float errorG = kernel_value * ((px >> 8 & 0xFF) - (candidate >> 8 & 0xFF));
                float errorB = kernel_value * ((px >> 0 & 0xFF) - (candidate >> 0 & 0xFF));

                int r = int(constrain((px2 >> 16 & 0xFF) + errorR, 0, 255));
                int g = int(constrain((px2 >> 8 & 0xFF) + errorG, 0, 255));
                int b = int(constrain((px2 >> 0 & 0xFF) + errorB, 0, 255));

                _image.pixels[px2Coord] = 0xFF << 24 | r << 16 | g << 8 | b;
              }
            }
          }
        }
      }
    }
  }
  _image.updatePixels();
  return _image;
}
