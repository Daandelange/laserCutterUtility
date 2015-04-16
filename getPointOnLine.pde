PVector getPointOnLine( float x1, float y1, float x2, float y2, float x, float y ){
    float dx = x2 - x1; 
    float dy = y2 - y1; 
    float d = sqrt( dx*dx + dy*dy ); 
    float ca = dx/d; // cosine
    float sa = dy/d; // sine
    
    float mx = (-x1+x)*ca + (-y1+y)*sa;
    
    PVector result = new PVector();
    
    if( mx <= 0 ){
      result.x = x1; 
      result.y = y1; 
    }
    else if( mx >= d ){
      result.x = x2; 
      result.y = y2; 
    }
    else{
      result.x = x1 + mx*ca; 
      result.y = y1 + mx*sa; 
    }
    
    float dx2 = x - result.x; 
    float dy2 = y - result.y; 
    result.z = sqrt( dx2*dx2 + dy2*dy2 ); 
    
    return result;   
  }
