public class Gradient {
  private ArrayList<AlphaHandle> AlphaHandles;
  private ArrayList<ColorHandle> ColorHandles;

  public Gradient() {
    this.AlphaHandles = new ArrayList<AlphaHandle>();
    this.ColorHandles = new ArrayList<ColorHandle>();
    this.initHandles();
  }

  public void initHandles() {
    AlphaHandles.add(new AlphaHandle(0, 0));
    AlphaHandles.add(new AlphaHandle(0, 255));
    int qtyColorHandles = int(random(2, 5));
    for (int i = 0; i < qtyColorHandles; i++ ) {
      ColorHandles.add(new ColorHandle(color(int(random(256)), int(random(256)), int(random(256))), random(1)));
    }
    this.SortColorHandles();
    this.SortAlphaHandles();
  }

  public void getARGB(float _i) {
  }

  public int getColor(float _i) {
    color c = color(0);
    for (int i = 0; i < this.ColorHandles.size()-1; i++) {
      ColorHandle h1 = ColorHandles.get(i);
      ColorHandle h2 = ColorHandles.get(i+1); 
      float start = h1.getLocation();
      float end = h2.getLocation();

      if (i == 0 && _i <= h1.location) {
        c = h1.getColor();
        break;
      }
      if (i+1 == this.ColorHandles.size()-1 && _i >= h2.location) {
        c = h2.getColor();
        break;
      }
      if (start == end) {
        c = h1.getColor();
        break;
      }
      float distance = end - start;
      if (_i >= start && _i <= end) {
        c = lerpColor(h1.getColor(), h2.getColor(), (_i-start)/distance);
        break;
      }
    }
    return c;
  }

  public void getAlpha(float _i) {
  }

  public void SortColorHandles() {
    Collections.sort(ColorHandles, new SortByLocation());
  }

  public void SortAlphaHandles() {
    Collections.sort(AlphaHandles, new SortByLocation());
  }
}


public class AlphaHandle extends Handle {

  private int alpha;

  public AlphaHandle(int _value, float _location) {
    this.alpha = min(max(_value, 0), 255);
    this.location = min(max(_location, 0), 1);
  }

  public int getAlpha() {
    return this.alpha;
  }

  public void setAlpha(int _value) {
    this.alpha = min(max(_value, 0), 255);
  }
}

public class ColorHandle extends Handle {

  private color c;

  public ColorHandle(color _c, float _location) {
    this.c=_c;
    this.location = min(max(_location, 0), 1);
  }

  public ColorHandle(int _r, int _g, int _b, float _location) {
    this.setColor(_r, _g, _b);
    this.location = min(max(_location, 0), 1);
  }

  public int getColor() {
    return this.c;
  }

  public int getR() {
    return this.c >> 16 & 0xFF;
  }

  public int getG() {
    return this.c >> 8 & 0xFF;
  }

  public int getB() {
    return this.c & 0xFF;
  }

  public void setColor(color _c) {
    this.c = _c;
  }

  public void setColor(int _r, int _g, int _b) {
    this.c = color(_r, _g, _b);
  }
}

public  class Handle {
  protected float location;

  public float getLocation() {
    return this.location;
  }

  public void setLocation(float _value) {
    this.location = min(max(_value, 0), 1);
  }
}


public class SortByLocation implements Comparator<Handle> {
  @Override
    public int compare(Handle h1, Handle h2) {
    return int((1000*h1.getLocation()) - (1000*h2.getLocation()));
  }
}
