import processing.serial.*;

public class XdkController {

  private Serial serial;
  
  public XdkController(Serial serial) {
    this.serial = serial;
  }
  
  public XdkController(PApplet applet, String comPort) {
    this(new Serial(applet, comPort, 115200));
  }
  
  public void connect() {
    serial.bufferUntil('\n');
  }
}
