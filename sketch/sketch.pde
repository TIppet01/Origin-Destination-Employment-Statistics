import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.mapdisplay.shaders.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.utils.*;

UnfoldingMap map;
Table tripTable;

ArrayList<Location> origins = new ArrayList();
ArrayList<Location> destinations = new ArrayList();

boolean noise = false;

void setup() {

  size(1000, 1000, P3D);
  map = new UnfoldingMap(this);
  Location nyc = new Location(40.700, -73.9);
  int zoom = 11;
  map.zoomAndPanTo(zoom, nyc);
  MapUtils.createDefaultEventDispatcher(this, map);
  tripTable = loadTable("../NYC_sample_100000.csv", "header");
  println(str(tripTable.getRowCount()) + " records loaded...");

  // load data
  for (TableRow row : tripTable.rows()){
    float originLat = row.getFloat("origin_lat");
    float originLon = row.getFloat("origin_lon");
    float destLat = row.getFloat("dest_lat");
    float destLon = row.getFloat("dest_lon");
    String originCounty = row.getString("origin_county");
    Location originLoc = new Location(originLat, originLon);
    Location destLoc = new Location(destLat, destLon);
    origins.add(originLoc);
    destinations.add(destLoc);
  }
  
  
}

void draw() {
  
  map.draw();
  noStroke();
  fill(0,120);
  rect(0,0,width,height);
  
  stroke(255);
  strokeWeight(.5);
  
  for (int i=0; i<tripTable.getRowCount(); i++) {

    Location originLoc = origins.get(i);
    Location destLoc = destinations.get(i);
    
    ScreenPosition originPos = map.getScreenPosition(originLoc);
    ScreenPosition destPos = map.getScreenPosition(destLoc);
    
    float distance = dist(originPos.x, originPos.y, mouseX, mouseY);
    
    if (distance < 25) {
    
       if (noise) {
        noiseyLine(originPos.x, originPos.y,
                  destPos.x, destPos.y, 
                  color(0, 0, 200), color(225, 205, 25), 60);
       }
      
       else {
       
         pushStyle();
         noStroke();
         gradientLine(originPos.x, originPos.y, destPos.x, destPos.y, color(0, 0, 200), color(225, 205, 25));
         popStyle();
       }
    }
    noFill();
    stroke(0);
    strokeWeight(1);
    ellipse(mouseX, mouseY, 50, 50);
  }
  
  //saveFrame("frames/#####.png");
  
 
  
}

void mouseMoved() {
  redraw();
}

// https://forum.processing.org/two/discussion/5620/how-to-draw-a-gradient-colored-line
void noiseyLine(float x_s, float y_s, float x_e, float y_e, int col_s, int col_e, int steps) {
  float[] xs = new float[steps];
  float[] ys = new float[steps];
  color[] cs = new color[steps];
  for (int i=0; i<steps; i++) {
    float amt = (float) i / steps;
    xs[i] = lerp(x_s, x_e, amt) + amt * (noise(frameCount * 0.01 + amt) * 200 - 100);
    ys[i] = lerp(y_s, y_e, amt) + amt * (noise(2 + frameCount * 0.01 + amt) * 200 - 100);
    cs[i] = lerpColor(col_s, col_e, amt);
  }
  for (int i=0; i<steps-1; i++) {
    stroke(cs[i]);
    strokeWeight(2);
    line(xs[i], ys[i], xs[i+1], ys[i+1]);
  }
}

void gradientLine(float x1, float y1, float x2, float y2, color a, color b) {
  float deltaX = x2-x1;
  float deltaY = y2-y1;
  float tStep = 1.0/dist(x1, y1, x2, y2);
  for (float t = 0.0; t < 1.0; t += tStep) {
    fill(lerpColor(a, b, t));
    ellipse(x1+t*deltaX,  y1+t*deltaY, 3, 3);
  }
}