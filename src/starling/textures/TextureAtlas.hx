package starling.textures;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.utils.Dictionary;
import starling.textures.SubTexture;
import starling.utils.ArrayUtil;

/** A texture atlas is a collection of many smaller textures in one big image. This class
 *  is used to access textures from such an atlas.
 *  
 *  <p>Using a texture atlas for your textures solves two problems:</p>
 *  
 *  <ul>
 *    <li>Whenever you switch between textures, the batching of image objects is disrupted.</li>
 *    <li>Any Stage3D texture has to have side lengths that are powers of two. Starling hides 
 *        this limitation from you, but at the cost of additional graphics memory.</li>
 *  </ul>
 *  
 *  <p>By using a texture atlas, you avoid both texture switches and the power-of-two 
 *  limitation. All textures are within one big "super-texture", and Starling takes care that 
 *  the correct part of this texture is displayed.</p>
 *  
 *  <p>There are several ways to create a texture atlas. One is to use the atlas generator 
 *  script that is bundled with Starling's sibling, the <a href="http://www.sparrow-framework.org">
 *  Sparrow framework</a>. It was only tested in Mac OS X, though. A great multi-platform 
 *  alternative is the commercial tool <a href="http://www.texturepacker.com">
 *  Texture Packer</a>.</p>
 *  
 *  <p>Whatever tool you use, Starling expects the following file format:</p>
 * 
 *  <listing>
 * 	&lt;TextureAtlas imagePath='atlas.png'&gt;
 * 	  &lt;SubTexture name='texture_1' x='0'  y='0' width='50' height='50'/&gt;
 * 	  &lt;SubTexture name='texture_2' x='50' y='0' width='20' height='30'/&gt; 
 * 	&lt;/TextureAtlas&gt;
 *  </listing>
 *  
 *  <strong>Texture Frame</strong>
 *
 *  <p>If your images have transparent areas at their edges, you can make use of the 
 *  <code>frame</code> property of the Texture class. Trim the texture by removing the 
 *  transparent edges and specify the original texture size like this:</p>
 * 
 *  <listing>
 * 	&lt;SubTexture name='trimmed' x='0' y='0' height='10' width='10'
 * 	    frameX='-10' frameY='-10' frameWidth='30' frameHeight='30'/&gt;
 *  </listing>
 *
 *  <strong>Texture Rotation</strong>
 *
 *  <p>Some atlas generators can optionally rotate individual textures to optimize the texture
 *  distribution. This is supported via the boolean attribute "rotated". If it is set to
 *  <code>true</code> for a certain subtexture, this means that the texture on the atlas
 *  has been rotated by 90 degrees, clockwise. Starling will undo that rotation by rotating
 *  it counter-clockwise.</p>
 *
 *  <p>In this case, the positional coordinates (<code>x, y, width, height</code>)
 *  are expected to point at the subtexture as it is present on the atlas (in its rotated
 *  form), while the "frame" properties must describe the texture in its upright form.</p>
 *
 */
class TextureAtlas
{
    public var texture(get, never) : BitmapData;

    private static var NAME_REGEX : EReg = new EReg('(.+?)\\d+$', "");  // find text before trailing digits  
    
    private var _atlasTexture : BitmapData;
    private var _subTextures : Map<String,SubTexture>;
    private var _subTextureNames : Array<String>;
    
    /** helper objects */
    private static var sNames : Array<String> = [];
    
    /** Create a texture atlas from a texture and atlas data. The second argument typically
     *  points to an XML file. */
    public function new(texture : BitmapData, data : Dynamic = null)
    {
        _subTextures = new Map<String,SubTexture>();
        _atlasTexture = texture;
        
        if (data != null)
        {
            parseAtlasData(data);
        }
    }
    
    /** Disposes the atlas texture. */
    public function dispose() : Void
    {
        _atlasTexture.dispose();
    }
    
    /** Parses the data that's passed as second argument to the constructor.
     *  Override this method to add support for additional file formats. */
    private function parseAtlasData(data : Dynamic) : Void
    {
        //if (Std.is(data, FastXML))
        //{
            //parseAtlasXml(try cast(data, FastXML) catch(e:Dynamic) null);
        //}
        //else
        //{
            //throw new ArgumentError("TextureAtlas only supports XML data");
        //}
    }
	
    /** Retrieves a SubTexture by name. Returns <code>null</code> if it is not found. */
    public function getTexture(name : String) : BitmapData
    {
		return _subTextures[name];
    }
    
    /** Returns all textures that start with a certain string, sorted alphabetically
     *  (especially useful for "MovieClip"). */
    public function getTextures(prefix : String = "", out : Array<BitmapData> = null) : Array<BitmapData>
    {
        if (out == null)
        {
            out = [];
        }
        
        for (name/* AS3HX WARNING could not determine type for var: name exp: ECall(EIdent(getNames),[EIdent(prefix),EIdent(sNames)]) type: null */ in getNames(prefix, sNames))
        {
            out[out.length] = getTexture(name);
        }  // avoid 'push'  
        
		sNames = [];
        return out;
    }
    
    /** Returns all texture names that start with a certain string, sorted alphabetically. */
    public function getNames(prefix : String = "", out : Array<String> = null) : Array<String>
    {
        var name : String;
        if (out == null)
        {
            out = [];
        }
        
        if (_subTextureNames == null) {
        
			// optimization: store sorted list of texture names
            
            _subTextureNames = [];
            for (name in _subTextures.keys())
            {
                _subTextureNames[_subTextureNames.length] = name;
            }
            
			_subTextureNames.sort(ArrayUtil.CASEINSENSITIVE);
        }
        
        for (name in _subTextureNames)
        {
            if (name.indexOf(prefix) == 0)
            {
                out[out.length] = name;
            }
        }
        
        return out;
    }
    
    /** Returns the region rectangle associated with a specific name, or <code>null</code>
     *  if no region with that name has been registered. */
    public function getRegion(name : String) : Rectangle
    {
        var subTexture : SubTexture = _subTextures[name];
        return (subTexture != null) ? subTexture.region : null;
    }
    
    /** Returns the frame rectangle of a specific region, or <code>null</code> if that region 
     *  has no frame. */
    public function getFrame(name : String) : Rectangle
    {
		trace ("getFrame: TODO");
		return null;
		//var subTexture : SubTexture = _subTextures[name];
        //return subTexture != null ? subTexture.frame : null;
    }
    
    /** If true, the specified region in the atlas is rotated by 90 degrees (clockwise). The
     *  SubTexture is thus rotated counter-clockwise to cancel out that transformation. */
    public function getRotation(name : String) : Bool
    {
        var subTexture : SubTexture = _subTextures[name];
        return subTexture != null ? subTexture.rotated : false;
    }
    
    /** Adds a named region for a SubTexture (described by rectangle with coordinates in
     *  points) with an optional frame. */
    public function addRegion(name : String, region : Rectangle, frame : Rectangle = null,
            rotated : Bool = false) : Void
    {
		addSubTexture(name, new SubTexture(_atlasTexture, region, false, frame, rotated));
    }
    
    /** Adds a named region for an instance of SubTexture or an instance of its sub-classes.*/
    public function addSubTexture(name : String, subTexture : SubTexture) : Void
    {
		//TODO :
		//if (subTexture.root != _atlasTexture.root)
        //{
            //throw new ArgumentError("SubTexture's root must be atlas texture.");
        //}

        _subTextures[name]=subTexture;
        _subTextureNames = null;
    }
    
    /** Removes a region with a certain name. */
    public function removeRegion(name : String) : Void
    {
        var subTexture : SubTexture = _subTextures[name];
        if (subTexture != null)
        {
            subTexture.dispose();
        }
		_subTextures[name]=null;
        _subTextureNames = null;
    }
    
    /** The base texture that makes up the atlas. */
    private function get_texture() : BitmapData
    {
        return _atlasTexture;
    }
}

