//====================================================================================
// Swatches Class

public class Swatches {

  public ArrayList<Swatch> swatches;

  public Swatches() {
    this.swatches = new ArrayList<Swatch>();
  }

  public Swatches(String[] hexes) {
    this.swatches = new ArrayList<Swatch>();
    for (String hex : hexes) {
      this.add(new Swatch(hex));
    }
  }

  public ArrayList<Swatch> randomize() {
    Collections.shuffle(this.swatches);
    return this.swatches;
  }

  public Swatches copy() {
    Swatches swatches_copy = new Swatches();
    for (Swatch s : this.swatches) {
      swatches_copy.add(s);
    }
    return swatches_copy;
  }


  public void replaceSwatches(ArrayList<Swatch> swatches) {
    this.swatches=swatches;
  }

  public void add(color c) {
    this.swatches.add(new Swatch(c));
  }

  public void add(String hex) {
    this.swatches.add(new Swatch(hex));
  }

  public void add(Swatch swatch) {
    this.swatches.add(swatch);
  }

  public int size() {
    return this.swatches.size();
  }

  public Swatch get(int swatch) {
    if (swatch >=0 && swatch < this.swatches.size()) {
      return this.swatches.get(swatch);
    } else {
      return new Swatch();
    }
  }

  public void remove(String hex) {
    boolean removed = false;
    for (Swatch s : this.swatches) {
      if (s.hex.equals(hex)) {
        this.swatches.remove(s);
        return;
      }
    }
    if (!removed) {
      println("Swatch " + hex+ " not found.");
    }
  }

  public Swatch rand() {
    return this.swatches.get(int(random(0, this.swatches.size())));
  }

  public Swatch closest(color c) {
    Swatch candidate = new Swatch();
    for (Swatch s : this.swatches) {
      if (s.avgDist(c) < candidate.avgDist(c)) {
        candidate = s;
      }
    }
    return candidate;
  }

  public Swatch closest(Swatch swatch) {
    Swatch candidate = new Swatch();
    for (Swatch s : this.swatches) {
      if (s.avgDist(swatch) <= candidate.avgDist(swatch)) {
        candidate = s;
      }
    }
    return candidate;
  }

  public Swatch rgbClosest(color c) {
    Swatch candidate = new Swatch();
    for (Swatch s : this.swatches) {
      if (s.rgbDist(c) <= candidate.rgbDist(c)) {
        candidate = s;
      }
    }
    return candidate;
  }

  public Swatch rgbClosest(Swatch swatch) {
    Swatch candidate = new Swatch();
    for (Swatch s : this.swatches) {
      if (s.rgbDist(swatch) <= candidate.rgbDist(swatch)) {
        candidate = s;
      }
    }
    return candidate;
  }

  public Swatch hsbClosest(color c) {
    Swatch candidate = new Swatch();
    for (Swatch s : this.swatches) {
      if (s.hsbDist(c) <= candidate.hsbDist(c)) {
        candidate = s;
      }
    }
    return candidate;
  }

  public Swatch hsbClosest(Swatch swatch) {
    Swatch candidate = new Swatch();
    for (Swatch s : this.swatches) {
      if (s.hsbDist(swatch) <= candidate.hsbDist(swatch)) {
        candidate = s;
      }
    }
    return candidate;
  }

  public ArrayList<Swatch> getAllSwatches() {
    return this.swatches;
  }
}

//====================================================================================
// Swatch Class

class Swatch {
  color c = 0;
  float h = 0.0;
  float s = 0.0;
  float b = 0.0;
  String hex = hex(this.c);
  PVector rgbVect = new PVector();
  PVector hsbVect = new PVector();
  float hWeight = 2;
  float sWeight = 1;
  float bWeight = 1.5;

  Swatch() {
  }

  Swatch(String hex) {
    this.hex = hex;
    this.c = unhex(hex);
    this.h = hue(this.c);
    this.s = saturation(this.c);
    this.b = brightness(this.c);
    this.rgbVect = new PVector( c >> 16 & 0xff, c >> 8 & 0xff, c >> 0 & 0xff);
    this.hsbVect = new PVector(hWeight*hue(c), sWeight*saturation(c), bWeight*brightness(c));
  }

  Swatch(int c) {
    this.hex = hex(c);
    this.c = c;
    this.h = hue(this.c);
    this.s = saturation(this.c);
    this.b = brightness(this.c);
    this.rgbVect = new PVector( c >> 16 & 0xff, c >> 8 & 0xff, c >> 0 & 0xff);
    this.hsbVect = new PVector(hWeight*hue(c), sWeight*saturation(c), bWeight*brightness(c));
  }

  float rgbDist(color c) {
    int r = c >> 16 & 0xff;
    int g = c >> 8 & 0xff;
    int b = c >> 0 & 0xff;
    return PVector.dist(this.rgbVect, new PVector(r, g, b));
  }

  float rgbDist(Swatch s) {
    return PVector.dist(this.rgbVect, s.rgbVect);
  }

  float hsbDist(color c) {
    return PVector.dist(this.hsbVect, new PVector(hWeight*hue(c), sWeight*saturation(c), bWeight*brightness(c)));
  }

  float hsbDist(Swatch s) {
    return PVector.dist(this.hsbVect, s.hsbVect);
  }

  float avgDist(color c) {
    return (this.rgbDist(c) + this.hsbDist(c))/2;
  }

  float avgDist(Swatch s) {
    return (this.rgbDist(s) + this.hsbDist(s))/2;
  }

  color getColor() {
    return this.c;
  }

  float getHue() {
    return this.h;
  }

  float getSaturation() {
    return this.s;
  }

  float getBrightness() {
    return this.b;
  }
}
