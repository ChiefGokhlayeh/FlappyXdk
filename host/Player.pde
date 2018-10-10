public class Player {

  public static final float DEFAULT_TICK_RATE = 1 / 9.81 / 1000; /* TODO: formula incomplete, would require pixel densitiy to be taken into account */
  public static final float DEFAULT_HITBOX_SIZE = 0.05;
  public static final int MAX_JUMP_ACCELERATION = 500; /* in ticks */
  public static final float DEFAULT_JUMP_FORCE = 4.5; /* relative to tick rate */

  private int lastTick;
  private int jumpStartTick;
  private int fallStartTick;
  private float tickRate;
  
  private boolean startedJumping;

  /* Relative position of the barrier with values ranging from -1 (left most) over 0 (center) to 1 (right most) */
  private float x;
  /* Relative position of the opening center with values ranging from -1 (bottom) over 0 (center) to 1 (top) */
  private float y;

  /* relative to window height */
  private float hitboxSize;

  private PVector velocity;
  private boolean isJumping;
  
  private Bounds bounds;
  private Collider collider;
  private ArrayList<Bounds> ghosts;

  public Player() {
    this(DEFAULT_HITBOX_SIZE, DEFAULT_TICK_RATE);
  }

  public Player(float hitboxSize, float tickRate) {
    this.hitboxSize = hitboxSize;
    this.tickRate = tickRate;
    ghosts = new ArrayList<Bounds>(5);
    reset();
  }

  private float calulcateJumpForce(int tick) {
    if (isJumping()) {
      fallStartTick = tick;
      if (startedJumping) {
        jumpStartTick = tick;
        startedJumping = false;
      }
      return min((tick - jumpStartTick) * tickRate * DEFAULT_JUMP_FORCE, tickRate * MAX_JUMP_ACCELERATION);
    } else {
      return 0;
    }
  }

  public void update(int tick, int windowWidth, int windowHeight) {
    velocity.y += -((tick - fallStartTick) * tickRate);
    velocity.y += calulcateJumpForce(tick);
    y = velocity.y;
    
    updateBounds(windowWidth, windowHeight);
    updateCollider();
    
    lastTick = tick;
  }

  public void reset() {
    velocity = new PVector(0, 0);
    lastTick = millis();
    fallStartTick = lastTick;
    jumpStartTick = lastTick;
    startedJumping = false;
    y = 1;
    x = 0;
    bounds = null;
    collider = null;
  }

  private void updateBounds(int windowWidth, int windowHeight) {
    int playerY = windowHeight - (windowHeight + round(y * windowHeight)) / 2;
    int hitboxPixels = round(hitboxSize * windowHeight);
    if (bounds != null) {
      ghosts.add(bounds);
      while (ghosts.size() > 5) {
        ghosts.remove(0);
      }
    }
    bounds = new Bounds(round((windowWidth - hitboxPixels) / 2.0), playerY, hitboxPixels, hitboxPixels);
  }
  
  private void updateCollider() {
    collider = new Collider(bounds);
  }

  public void setJumping(boolean isJumping) {
    if (this.isJumping != isJumping) {
      this.isJumping = isJumping;
      startedJumping = true;
    }
  }

  public boolean isJumping() {
    return isJumping;
  }

  public float getHitboxSize() {
    return hitboxSize;
  }
  
  public Bounds getBounds() {
    return bounds;
  }
  
  public Collider getCollider() {
    return collider;
  }
  
  public ArrayList<Bounds> getGhostsBounds() {
    return ghosts;
  }

  public class Bounds {
    private int x;
    private int y;
    private int width;
    private int height;

    private Bounds(int x, int y, int width, int height) {
      this.x = x;
      this.y = y;
      this.width = width;
      this.height = height;
    }

    public int getX() {
      return x;
    }
    public int getY() {
      return y;
    }
    public int getWidth() {
      return width;
    }
    public int getHeight() { 
      return height;
    }
  }
  
  public class Collider {
    private Bounds playerBounds;
    
    Collider(Bounds playerBounds) {
      this.playerBounds = playerBounds;
    }
    
    private boolean isXInGap(Barrier.Bounds barrierBounds) {
      int pX = playerBounds.getX();
      int pWidth = playerBounds.getWidth();
      int bCenter = barrierBounds.getCenter();
      int bHalfWidth = (barrierBounds.getWidth() / 2);
      return pX + pWidth > bCenter - bHalfWidth && pX < bCenter + bHalfWidth;
    }
    
    private boolean isYInGap(Barrier.Bounds barrierBounds) {
      int pY = playerBounds.getY();
      int pHeigth = playerBounds.getHeight();
      return pY > barrierBounds.getOpeningTop() && pY + pHeigth < barrierBounds.getOpeningBottom();
    }
    
    public boolean isCollidingWith(Barrier.Bounds barrierBounds) {
      if (isXInGap(barrierBounds)) {
        return !isYInGap(barrierBounds);
      } else {
        return false;
      }
    }
    
    public boolean isOutOfBounds(int boundWidth, int boundHeight) {
      int pX = playerBounds.getX();
      int pY = playerBounds.getY();
      return pX < 0 || pY < 0 || pX + playerBounds.getWidth() > boundWidth || pY + playerBounds.getWidth() > boundHeight;
    }
  }
}
