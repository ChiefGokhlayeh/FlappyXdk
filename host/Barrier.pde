public class Barrier {

  public static final float DEFAULT_TICK_RATE = 0.001;
  public static final float DEFAULT_EDGE = 0.05;
  
  private int lastTick;
  private float tickRate;
  
  /* A multiple of the players hitbox size */
  private float openingSize;

  /* Relative position of the barrier with values ranging from -1 (left most) over 0 (center) to 1 (right most) */
  private float openingX;
  /* Relative position of the opening center with values ranging from -1 (bottom) over 0 (center) to 1 (top) */
  private float openingY;

  private Bounds bounds;

  public Barrier() {
    this(DEFAULT_TICK_RATE);
  }
  
  public Barrier(float tickRate) {
    this(random(-1, 1), random(2, 4), tickRate);
  }

  public Barrier(float openingY, float openingSize, float tickRate) {
    this.openingY = openingY;
    this.openingSize = openingSize;
    this.tickRate = tickRate;
    reset();
  }
  
  public Barrier(float openingY, float openingSize) {
    this(openingY, openingSize, DEFAULT_TICK_RATE);
  }

  public void update(int tick, int windowWidth, int windowHeight, int hitboxSize) {
    openingX -= (tick - lastTick) * tickRate;
    updateBounds(windowWidth, windowHeight, hitboxSize);    
    lastTick = tick;
  }

  public void reset() {
    openingX = 1;
    lastTick = millis();
    bounds = null;
  }
  
  public boolean isReadyForCleanup() {
    return openingX < -1;
  }
  
  private boolean isScored;
  public boolean checkScored() {
    if (!isScored && openingX < 0) {
      isScored = true;
      return true;
    } else {
      return false;
    }
  }
  
  private void updateBounds(int windowWidth, int windowHeight, int hitboxSize) {
    int barrierWidth = hitboxSize / 2;
    int barrierCenter = (windowWidth + round(openingX * windowWidth)) / 2;
    
    int edge = round(windowHeight * DEFAULT_EDGE);
    
    int halfGap = round((hitboxSize * openingSize) / 2.0);
    int gapCenter = round((windowHeight + openingY * windowHeight) / 2.0);
    int openingTop = gapCenter - halfGap;
    int openingBottom = gapCenter + halfGap;
    if (openingTop < edge) {
      openingBottom += abs(openingTop) + edge;
      openingTop = edge;
    } else if (openingBottom > windowHeight - edge) {
      openingTop -= openingBottom - (windowHeight - edge);
      openingBottom = windowHeight - edge;
    }
    bounds = new Bounds(barrierCenter, barrierWidth, openingTop, openingBottom);
  }
  
  public Bounds getBounds() {
    return bounds;
  }

  public class Bounds {
    private int center;
    private int width;
    private int openingTop;
    private int openingBottom;

    private Bounds(int center, int width, int openingTop, int openingBottom) {
      this.center = center;
      this.width = width;
      this.openingTop = openingTop;
      this.openingBottom = openingBottom;
    }

    public int getWidth() {
      return width;
    }
    public int getCenter() { 
      return center;
    }
    public int getOpeningTop() { 
      return openingTop;
    }
    public int getOpeningBottom() { 
      return openingBottom;
    }
  }
}
