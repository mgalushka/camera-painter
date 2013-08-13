import processing.video.*;
import hypermedia.video.*;
import java.awt.*;
import java.util.*;

Capture video;
OpenCV opencv;
int skip = 0;
int points = 0;

ArrayList c = new ArrayList();

void setup(){
  size(640, 480);
   video = new Capture(this, width, height);
   opencv = new OpenCV(this);
    video.start();  
    // Make the pixels[] array available for direct manipulation
    loadPixels();
    opencv.allocate(video.width, video.height);                        // create the bufer
    opencv.copy(video);  
    //opencv.cascade( "C:/Program Files (x86)/OpenCV/data/haarcascades/haarcascade_frontalface_alt.xml" ); 
}

void draw() {
  if (video.available()) {
      video.read(); // Read a new video frame
      video.loadPixels(); // Make the pixels of video available
      // Difference between the current frame and the stored background
//      opencv.allocate(video.width,video.height);   //uncomment this to make it colored, but you'll have to adapt the remember function
      opencv.copy(video);
      background(0);
      opencv.read();
      opencv.flip( OpenCV.FLIP_HORIZONTAL );
      opencv.convert( OpenCV.GRAY );  //  Converts the difference image to greyscale
      opencv.blur( OpenCV.BLUR, 3 );  //  I like to blur before taking the difference image to reduce camera noise
      opencv.threshold(20);    // set black & white threshold 
      //image( opencv.image(), 0, 0 );  
      background(255);
      
      /*
      // detect anything ressembling a FRONTALFACE
      Rectangle[] faces = opencv.detect();
      
      // draw detected face area(s)
      noFill();
      stroke(255,0,0);
      for( int i=0; i<faces.length; i++ ) {
          rect( faces[i].x, faces[i].y, faces[i].width, faces[i].height ); 
      }
      */
      opencv.read();           // grab frame from camera
      
      
      // find blobs
      Blob[] blobs = opencv.blobs( 10, width*height/2, 100, true, OpenCV.MAX_VERTICES*4 );
      
      // draw blob results
      for( int i=0; i<1/*blobs.length*/; i++ ) {
          //beginShape();
          noFill();
          stroke(255,0,0);
          if(blobs != null && blobs.length > i && blobs[i] != null && blobs[i].points != null && blobs[i].points.length > 0){
            for( int j=0; j<blobs[i].points.length; j++ ) {
                //vertex( blobs[i].points[j].x, blobs[i].points[j].y );                
                
                Rectangle r = blobs[i].rectangle;
                if(c.isEmpty()){
                  c.add(new Rectangle(r.x, r.y, 0, 0));
                }
                else {
                  Rectangle last = (Rectangle) c.get(c.size() - 1);
                  if(dist(r.x, r.y, last.x, last.y) < 20 || skip > 20){
                    c.add(new Rectangle(r.x, r.y, 0, 0)); 
                    if(points > 10000){
                      c.remove(0);   
                    }
                    skip = 0;
                    points++;
                  }   
                  else{
                    skip++;
                  }
                }                
                rect( r.x, r.y, 5, 5 ); 
            }
          }
      }
          //endShape(CLOSE);
      //println(Arrays.toString(c.toArray()));
      // draw full picture
      noFill();
      stroke(255,0,0);
      //beginShape();
      if(c.size() > 1){
        for(int i=1; i<c.size(); i++){
          Rectangle f = ((Rectangle)c.get(i-1));
          Rectangle s = ((Rectangle)c.get(i));
          line(f.x, f.y, s.x, s.y);     
        }
      }
      //endShape(CLOSE);
  }
}
