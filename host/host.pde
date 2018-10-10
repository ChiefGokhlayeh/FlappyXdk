/* Colors selected via Google Color Tool https://material.io/tools/color/#!/?view.left=1&view.right=0&primary.color=607D8B&secondary.color=558B2F */

Player player;
ArrayList<Barrier> barriers;
boolean gameOver;
int tick = 0;
int highscore = 0;
int score = 0;

void setup() {
  size(1024, 720);

  player = new Player();
  barriers = new ArrayList<Barrier>();
  gameOver = false;
}

void draw() {
  background(#ffffff);

  tick = millis();

  if (checkForNewBarrier()) {
    Barrier b = new Barrier();
    b.reset(); //<>//
    barriers.add(b);
  }

  player.setJumping(mousePressed);
  player.update(tick, width, height);
  Player.Bounds playerBounds = player.getBounds();
  if (player.getCollider().isOutOfBounds(width, height)) {
    endGame();
  }

  for (Barrier b : barriers) {
    if (b.isReadyForCleanup()) {
      barriers.remove(b);
      break;
    } else {
      b.update(tick, width, height, round(player.getHitboxSize() * height));
      Barrier.Bounds bounds = b.getBounds();

      if (player.getCollider().isCollidingWith(bounds)) {
        endGame();
      }
      if (b.checkScored()) {
        score++;
      }

      drawBarrier(bounds);
    }
  }
  drawPlayerGhost(player.getGhostsBounds());
  drawPlayer(playerBounds);

  drawScore();
  if (gameOver) {
    drawEndGame();
  }
}

void drawBarrier(Barrier.Bounds bounds) {
  noStroke();
  rectMode(CORNER);
  if (!gameOver) {
    fill(#255d00);
  } else {
    fill(#9a0007);
  }
  int center = bounds.getCenter();
  int width = bounds.getWidth();
  int x = round(center - width / 2.0);
  int openingTop = bounds.getOpeningTop();
  int openingBottom = bounds.getOpeningBottom();
  rect(x, 0, width, openingTop);
  rect(x, openingBottom, width, height);
}

void drawPlayer(Player.Bounds bounds) {
  noStroke();
  ellipseMode(CORNER);
  if (!gameOver) {
    fill(#558b2f);
  } else {
    fill(#9a0007);
  }
  ellipse(bounds.getX(), bounds.getY(), bounds.getWidth(), bounds.getHeight());
}

void drawPlayerGhost(ArrayList<Player.Bounds> ghost) {
  noStroke();
  ellipseMode(CORNER);
  for (int i = ghost.size() - 1; i >= 0; i--) {
    Player.Bounds b = ghost.get(i);
    if (!gameOver) {
      fill(#558b2f, (200 / ghost.size()) * i);
    } else {
      fill(#9a0007, (200 / ghost.size()) * i);
    }
    ellipse(b.getX(), b.getY(), b.getWidth(), b.getHeight());
  }
}

void drawScore() {
  fill(#000000);
  textSize(14);
  textAlign(LEFT, TOP);
  text("Score: " + score, 0, 0);
}

void drawEndGame() {
  fill(#9a0007, 196);
  noStroke();
  rectMode(CORNER);
  rect(width/4, height/3, width/2, height/3);
  fill(255);
  textSize(64);
  textAlign(CENTER, BOTTOM);
  text("GAME OVER", width/2, height/2);
  int scoreTextSize = 48;
  textSize(scoreTextSize);
  textAlign(CENTER, TOP);
  text("Your Score: " + score, width/2, height/2);
  text("Highscore: " + highscore, width/2, height/2 + scoreTextSize);
  textSize(16);
  textAlign(CENTER, BOTTOM);
  text("Click to contine...", width/2, (height/3) * 2);
}

boolean checkForNewBarrier() {
  return barriers.size() < 1;
}

void mousePressed() {
  if (gameOver) {
    reset();
  }
}

void reset() {
  gameOver = false;
  player.reset();
  barriers.clear();
  score = 0;
  loop();
}

void endGame() {
  gameOver = true;
  if (score > highscore) {
    highscore = score;
  }
  noLoop();
}
