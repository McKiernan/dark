part of Dark;

class Texture {
  static List<Texture> all = new List<Texture>();
  
  static void loadAll() {
    all.forEach((texture)=>texture.load());
  }

  String url;
  Texture(this.url) {
    all.add(this);
  }
  
  GL.Texture texture;
  
  load() {
    ImageElement img = new ImageElement();
    texture = gl.createTexture();
    img.onLoad.listen((e) {
      gl.bindTexture(GL.TEXTURE_2D,  texture);
      gl.texImage2DImage(GL.TEXTURE_2D,  0,  GL.RGBA,  GL.RGBA,  GL.UNSIGNED_BYTE, img);
      gl.texParameteri(GL.TEXTURE_2D,  GL.TEXTURE_MIN_FILTER, GL.NEAREST);
      gl.texParameteri(GL.TEXTURE_2D,  GL.TEXTURE_MAG_FILTER, GL.NEAREST);
    }, onError: (e) => print(e));
    img.src = url;
  }
}

class ImageAtlas {
  GL.Texture texture;

  int width, height;
  ImageAtlasCell cell;
  
  ImageAtlas(this.width, this.height) {
    cell = new ImageAtlasCell(0, 0, width, height);
  }
  
  bool insert(var image) {
    return cell.insert(image);
  }
  
  void render() {
    texture = gl.createTexture();
    
    Uint8List result = new Uint8List(width*height*4);
    cell.render(this, result);
    gl.bindTexture(GL.TEXTURE_2D, texture);
    gl.texImage2DTyped(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, result);
    gl.texParameteri(GL.TEXTURE_2D,  GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    gl.texParameteri(GL.TEXTURE_2D,  GL.TEXTURE_MAG_FILTER, GL.NEAREST);
    
    addSpriteMap(texture);
  }
}

class ImageAtlasCell {
  int x, y;
  int width, height;
  
  var content;
  ImageAtlasCell child0, child1;
  
  ImageAtlasCell(this.x, this.y, this.width, this.height) {
  }
  
  bool insert(var image) {
    if (content==null) {
      if (image.width<=width && image.height<=height) {
        content = image;
        int remainingWidth = width-image.width;
        int remainingHeight = height-image.height;
        if (remainingWidth>remainingHeight) {
          if (remainingWidth>0) {
            child0 = new ImageAtlasCell(x+image.width+1, y, remainingWidth-1, height);
          }
          if (remainingHeight>0) {
            child1 = new ImageAtlasCell(x, y+image.height+1, image.width, remainingHeight-1);
          }
        } else {
          if (remainingHeight>0) {
            child0 = new ImageAtlasCell(x, y+image.height+1, width, remainingHeight-1);
          }
          if (remainingWidth>0) {
            child1 = new ImageAtlasCell(x+image.width+1, y, remainingWidth-1, image.height);
          }
        }
        return true;
      }
      return false;
    }
    
    if (child1!=null && child1.insert(image)) return true;
    if (child0!=null && child0.insert(image)) return true;
    
    return false;
  }

  void render(ImageAtlas imageAtlas, Uint8List pixels) {
    if (content!=null) content.render(imageAtlas, pixels, x, y);
    if (child0!=null) child0.render(imageAtlas, pixels);
    if (child1!=null) child1.render(imageAtlas, pixels);
  }
}