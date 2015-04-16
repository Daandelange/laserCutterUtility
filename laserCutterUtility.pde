import processing.pdf.*;
import java.util.*; // Collections

PShape lines; // will hold shape data
boolean export_cropped_pdf = true; // crop and export pdf

int previewTreshold = 140; // set treshold preview zone [red] (0 = none)
float tresholdTolerance = 1.9;

// DONT change these, current treshold settings are calibrated to these
float strokeWeight = 0.5;
float zoom = 1;
float colorScale = 1000; // more precision

ArrayList<PVector> tresholdZones = new ArrayList<PVector>();

void setup() {
  // Load the shape
  lines = loadShape("level_4-splitparts_8.svg");
  //lines = loadShape("level_10-splitparts_2-01_resized.svg");
  
  size((int)(lines.width*zoom), (int)(lines.height*zoom), P2D);//P2D);
  
  // bypass conrainer children
  while(lines.getChildCount() == 1 ) lines = lines.getChild(0);
  
  smooth(8);
  strokeCap(ROUND);
  //stroke(0,50);
  noLoop();
  colorMode(RGB, colorScale);
}

void draw() {
  background(colorScale,colorScale);
  stroke(0,50);
  scale(zoom);
  strokeWeight(strokeWeight);
  // Center where we will draw all the vertices
  //translate(width/2 - lines.width/2, height/2- lines.height/2);
  
  // Iterate over the children
  int children = lines.getChildCount();
  //println(children+" - [ ");
  for (int i = 0; i < children; i++) {
    PShape child = lines.getChild(i);
    int total = child.getVertexCount();
    
    // Processing seems to strip off line information only keeping vertexes
    // so lets just hope we have a line every 2 vertexes
    for (int j = 0; j < total; j+=2) {
      if( j >= total-1) return;
      PVector v = child.getVertex(j);
      PVector v2 = child.getVertex(j+1);
      line(v.x, v.y, v2.x, v2.y);
    }
  }
  
  // hide a part of the image (handy for calculating treshold for a setting)
  if(false){
    fill(colorScale);
    ellipse(width/2, height/2, 30,30);
    noFill();
  }
  
  // scan result
  loadPixels();
  float darkest = 0;
  int numPixelsOutOfTreshold = 0;
  for (int i = 0; i < pixels.length; i++) {
     if( 255-brightness(pixels[i]) > darkest){
       darkest = 255-brightness(pixels[i]);
       numPixelsOutOfTreshold ++;
     }
  }
  
  
  if(previewTreshold > 0){
    fill(colorScale,0,0);
    for (int i = 0; i < pixels.length; i++) {
       if( 255-brightness(pixels[i]) > previewTreshold){
         //pixels[i]=color(colorScale,0,0);//map(brightness(pixels[i]), darkest, 255, 0,colorScale), 0, 0);
         ellipse( (i%width)/zoom, (floor(i/width))/zoom, 1.5,1.5 );
         tresholdZones.add( new PVector(i%width, floor(i/width)) );
       }
    }
    noFill();
    //updatePixels();
  }
  
  println("\tNumber of Lines:\t"+round(children/2));
  println("\tDarkest point:\t"+darkest);
  println("\tNumber of pixels out of treshold:\t"+numPixelsOutOfTreshold);
  println("\tPress C to export a cropped PDF");
  println("");
  
  // do some tests
  ArrayList<LaserSetting> tests = new ArrayList<LaserSetting>();
  //                          Speed  Power  Treshold  Material      Thickness  Comment
  tests.add(new LaserSetting( 95,    5,     180,      "Plexiglass", 3.0  ));// At 184 is just gotten trough it

  println("\tSpeed\tPower\tTreshold\tMaterial\t\tThickness\tStatus");
  for(int i=0; i<tests.size(); i++){
    String status = "FAILED";
    LaserSetting ls = tests.get(i);
    if(darkest < ls.treshold) status = "PASSED";
    println("\t"+ls.speed+"\t"+ls.power+"\t"+ls.treshold+"\t"+ls.material+"\t\t"+ls.thickness+"\t"+status);
  }
}

void keyPressed(){
 /*
 for(int i=0; i<10;i++){
   if( Character.toString(key).equals((String)(""+i))==true ){
     int setting = parseInt(Character.toString(key));
     strokeWeight = ((float)(setting)) / 20.0;
     //strokeWeight(lineWeight);
     redraw();
   }
 }*/
 // trim file to artboard ?
 if(export_cropped_pdf == true && key == 'c'){
    // record to file
    println("\tCropping File Contents...");
    beginRecord(PDF, "CROPPED_PDF_OUTPUT.pdf");
    
    stroke(0,50);
    scale(zoom);
    strokeWeight(strokeWeight);
    // Center where we will draw all the vertices
    //translate(width/2 - lines.width/2, height/2- lines.height/2);
    
    // Iterate over the children
    int children = lines.getChildCount();
    for (int i = 0; i < children; i++) {
      PShape child = lines.getChild(i);
      int total = child.getVertexCount();

      // Processing seems to strip off line information only keeping vertexes
      // so lets just hope we have a line every 2 vertexes
      for (int j = 0; j < total; j+=2) {
        if( j >= total-1) break;
        PVector v = child.getVertex(j);
        PVector v2 = child.getVertex(j+1);
        
        // restrict to canvas
        if(v.x<0){
          v = intersect(0,0,0,height,v.x, v.y, v2.x, v2.y, false);
          if(v==NO_INTERSECT) continue;
        }
        if(v2.x<0){
          v2 = intersect(0,0,0,height,v.x, v.y, v2.x, v2.y, false);
          if(v2==NO_INTERSECT) continue;
        }
        if(v.x>width){
          v = intersect(width,0,width,height,v.x, v.y, v2.x, v2.y, false);
          if(v==NO_INTERSECT) continue;
        }
        if(v2.x>width){
          v2 = intersect(width,0,width,height,v.x, v.y, v2.x, v2.y, false);
          if(v2==NO_INTERSECT) continue;
        }
        if(v.y<0){
          v = intersect(0,0,width,0,v.x, v.y, v2.x, v2.y, false);
          if(v==NO_INTERSECT) continue;
        }
        if(v2.y<0){
          v2 = intersect(0,0,width,0,v.x, v.y, v2.x, v2.y, false);
          if(v2==NO_INTERSECT) continue;
        }
        if(v.y>height){
          v = intersect(0,height,width,height,v.x, v.y, v2.x, v2.y, false);
          if(v==NO_INTERSECT) continue;
        }
        if(v2.y>height){
          v2 = intersect(0,height,width,height,v.x, v.y, v2.x, v2.y, false);
          if(v2==NO_INTERSECT) continue;
        }
        //println("\t Done Cropping Line "+round(i)+"! ");
        
        // dont draw lines on masks ?
        ArrayList<PVector> tooClose = new ArrayList<PVector>();
        for(int iii = 0; iii<tresholdZones.size(); iii++){
          PVector tz = tresholdZones.get(iii);
          PVector closestPoint = getPointOnLine(v.x, v.y, v2.x, v2.y, tz.x, tz.y);
          
          // too close = cut in pieces
          if( tz.dist(closestPoint) < tresholdTolerance*2 ) tooClose.add(closestPoint);
        }
        
        // now we know all points on the line that we dont want, now cut the lines!
        if(tooClose.size()>0){
          ArrayList<ArrayList<PVector> > lineBlobs = new ArrayList<ArrayList<PVector> >();
          
          for(int ii = 0; ii<tooClose.size(); ii++){
            //println("\t Found "+ tooClose.size() +" points on this line ("+i+") that are too close...");
            PVector p = tooClose.get(ii);
            ArrayList<PVector> blob = new ArrayList<PVector>();
            blob.add( p.get() );
            //boolean touchingAnotherOne=false;
            int iii = tooClose.size()-1;
            
            // build blobs from point segments
            while( iii>=0 ){
              if(iii==ii){ iii--; continue; } // skip self
              if(iii<0) break;
              if(tooClose.size()==1) break; // no more points to check
              
              PVector pp = tooClose.get(iii);
              
              // loop current blob contents to check if pp is too close or not
              for(int b=0; b<blob.size(); b++) if( p.dist(pp) < tresholdTolerance*2 ){
                // point is now in blob, we dont need it anymore here
                blob.add( pp.get() );
                tooClose.remove(iii);
                
                //if( v.dist(pp) < v2.dist(pp) ) split1 = pp.get();
                //else split2 = pp.get();
                // build blob of touching ones
                // then in each blob, put lines in-between by choosing the closest points from the blob points
                iii=tooClose.size()-1; // restart loop from beginning
                break;
              }
              iii--;
              
              //println(iii, "Blob Size: "+blob.size(), "tooClose Size: "+tooClose.size());
            }
            
            // find edges of blob
            if(blob.size()>0){
              //println(blob);
              PVector p1=blob.get(0), p2=blob.get(0);
              // keep closest points to line segment points
              for(int bb=0; bb<blob.size(); bb++){
                if( blob.get(bb).dist(v) < p1.dist(v) ) p1=blob.get(bb);
                if( blob.get(bb).dist(v2) < p2.dist(v2) ) p2=blob.get(bb);
              }
              //println(blob.size());
              blob = new ArrayList<PVector>();
              p1.z=0;
              p2.z=0;
              blob.add(p1);
              blob.add(p2);
              
              /*fill(colorScale, 0, 0);
              noStroke();
              ellipse(blob.get(0).x, blob.get(0).y, 5, 5);
              noFill();*/
            }
            
            // save blob
            lineBlobs.add( blob );
          }
          
          noFill();
          // now draw segmented line
          //println("Line "+i+" has "+lineBlobs.size()+" blobs.");
          PVector prevPoint = v.get();
          while(lineBlobs.size()>0){
            float dist = v.dist(v2);
            int nextIndex = 0;
            
            // find closest blob to prevPoint (the next one)
            for(int b=0; b<lineBlobs.size(); b++){
              ArrayList<PVector> blob = lineBlobs.get(b);
              if(blob.size()<1) break;
              
              // get next blob close to v
              if(dist > blob.get(0).dist(v) ){
                dist = blob.get(0).dist(v);
                nextIndex = b;
              } 
            }
            
            ArrayList<PVector> blob = lineBlobs.get(nextIndex);
            //println(blob);
            lineBlobs.remove(nextIndex);
            
            /*for(int n=0; n<blob.size(); n++){
              fill(0,0,colorScale);
              noStroke();
              ellipse(blob.get(n).x, blob.get(n).y, 5, 5);
              noFill();
            }*/
            
            // draw if not too close to line segment
            if(blob.get(0).dist(prevPoint) > tresholdTolerance*2 ){
              stroke(0,colorScale,0);
              PVector diff = (blob.get(0).get());
              diff.sub(prevPoint);
              diff.normalize();
              
              float distt = blob.get(0).dist(prevPoint);
              //println(distt, blob.get(0), prevPoint);
              
              
              line(prevPoint.x, prevPoint.y, (prevPoint.x+diff.x*(distt-tresholdTolerance)), (prevPoint.y+diff.y*(distt-tresholdTolerance)));
              //prevPoint = (prevPoint+diff*(distt+tresholdTolerance));
              //fill(0,0,colorScale);
              //noStroke();
              //ellipse(blob.get(0).x, blob.get(0).y, 5, 5);
              //println(blob.get(0));
              
              diff.mult(distt+tresholdTolerance);
              prevPoint.add( diff );
            }
          }
        }
        
        // draw line for output
        else{
          stroke(0);
          line(v.x, v.y, v2.x, v2.y);
        }
      }
    }
    
    // close file
    endRecord();
    println("Done!");
 }
 
 //println("notfound: "+ Character.toString(key)+" ≠ "+(String)(""+2));
}

class LaserSetting {
  public int speed, power, treshold;
  public String material = "None";
  public float thickness = 0.0;
  
  LaserSetting(int _speed, int _power, int _treshold, String _material, float _thickness){
    speed = _speed;
    power = _power;
    treshold = _treshold;
    material = _material;
    thickness = _thickness;
  }
}

