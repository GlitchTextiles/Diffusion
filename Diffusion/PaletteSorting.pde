//====================================================================================
// sortPalette

public void sortPalette(Swatches palette, int mode) {
  switch(mode) {
  case 0:
    Collections.sort(palette.swatches, new SwatchSortColor());
    break;
  case 1:
    Collections.sort(palette.swatches, new SwatchSortHue());
    break;
  case 2:
    Collections.sort(palette.swatches, new SwatchSortSaturation());
    break;
  case 3:
    Collections.sort(palette.swatches, new SwatchSortBrightness());
    break;
  case 4:
    Collections.sort(palette.swatches, new SwatchSortBrightSat());
    break;
  case 5:
    Collections.sort(palette.swatches, new SwatchSortSatBright());
    break;
  case 6:
    palette=randomized.copy();
    break;
  }
}

//====================================================================================
// Comparators

public class SwatchSortColor implements Comparator<Swatch> {
  @Override
  public int compare(Swatch s1, Swatch s2) {
    return s2.getColor() - s1.getColor();
  }
}

public class SwatchSortHue implements Comparator<Swatch> {
  @Override
  public int compare(Swatch s1, Swatch s2) {
    return int(100*s1.getHue() - 100*s2.getHue());
  }
}

public class SwatchSortSaturation implements Comparator<Swatch> {
  @Override
  public int compare(Swatch s1, Swatch s2) {
    return int(100*s1.getSaturation() - 100*s2.getSaturation());
  }
}

public class SwatchSortBrightness implements Comparator<Swatch> {
  @Override
  public int compare(Swatch s1, Swatch s2) {
    return int(100*s2.getBrightness() - 100*s1.getBrightness());
  }
}

public class SwatchSortBrightSat implements Comparator<Swatch> {
  @Override
  public int compare(Swatch s1, Swatch s2) {
    return int(100*(s2.getBrightness()-s2.getSaturation()) - 100*(s1.getBrightness()-s1.getSaturation()));
  }
}

public class SwatchSortSatBright implements Comparator<Swatch> {
  @Override
  public int compare(Swatch s1, Swatch s2) {
    return int(100*(s2.getSaturation()+s2.getBrightness()) - 100*(s1.getSaturation()+s1.getBrightness()));
  }
}
