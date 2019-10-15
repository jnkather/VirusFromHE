// contains code by Pete Bankhead, Jakob Kather, Jeremias Krause and James Dolezal

import qupath.lib.images.servers.ImageServer
import qupath.lib.objects.PathObject
import qupath.lib.regions.RegionRequest
import qupath.lib.roi.PathROIToolsAwt
import qupath.lib.scripting.QPEx
import javax.imageio.ImageIO
import java.awt.Color
import java.awt.image.BufferedImage
import java.awt.geom.AffineTransform
import java.awt.image.AffineTransformOp
import java.awt.image.DataBufferByte

def saveTiles = true
def tileSize_um = 256
def tileSize_px = 512
// path must end with slash, no backslashes
def targetDir = "D:/ALLBLOCKS/TCGA-STAD-DX/BLOCKS/"

setImageType('BRIGHTFIELD_H_E'); 
setColorDeconvolutionStains('{"Name" : "H&E default", "Stain 1" : "Hematoxylin", "Values 1" : "0.65111 0.70119 0.29049 ", "Stain 2" : "Eosin", "Values 2" : "0.2159 0.8012 0.5581 ", "Background" : " 255 255 255 "}');
selectAnnotations();
runPlugin('qupath.lib.algorithms.TilerPlugin', String.format('{"tileSizeMicrons": %d,  "trimToROI": false,  "makeAnnotations": true,  "removeParentAnnotation": false}', tileSize_um));

def imageData = QPEx.getCurrentImageData()
def hierarchy = imageData.getHierarchy()
def annotations = hierarchy.getFlattenedObjectList(null).findAll {it.isAnnotation()}
def server = imageData.getServer()

def name = server.getShortServerName()
def home_dir = targetDir + name
QPEx.mkdirs(home_dir)
def path = buildFilePath(home_dir, String.format("Tile_coords_%s.txt", name))
def ann_path = buildFilePath(home_dir, String.format("%s.qptxt", name))
def tile_file = new File(path)
def ann_file = new File(ann_path)
tile_file.text = ''
ann_file.text = ''

for (obj in annotations) {
    if (obj.isAnnotation()) {
        def roi = obj.getROI()

        // Ignore empty annotations
        if (roi == null) {
            continue
        }
        // If small rectangle, assume image tile, saveTiles
        if (roi.getClass() == qupath.lib.roi.RectangleROI && roi.getBoundsWidth()<=(5*tileSize_um)) {
            def region = RegionRequest.createInstance(server.getPath(), 1.0, roi)
            String tile_name = String.format('%s_(%d,%d)',
                name,
                region.getX(),
                region.getY(),
            )
            def old_img = server.readBufferedImage(region)
            int width_old = old_img.getWidth()
            int height_old = old_img.getHeight()

            // Check if tile is mostly background
            // If >50% of pixels >240, then discard
            def gray_list = []
            for (int i=0; i < width_old; i++) {
                for (int j=0; j < height_old; j++) {
                    int gray = old_img.getRGB(i, j)& 0xFF;
                    gray_list << gray
                }
            }
            int median_px_i = (width_old * width_old) / 2
            median_px = gray_list.sort()[median_px_i]
            if (median_px > 220) { 
                print("Tile has >50% brightness >240, discarding")
                continue
            }
            // Write image tile coords to text file
            tile_file << roi.getPolygonPoints() << System.lineSeparator()
            BufferedImage img = new BufferedImage(tileSize_px, tileSize_px, old_img.getType())
            if (saveTiles) {
                // Resize tile
                AffineTransform resize = new AffineTransform()
                resize_factor = tileSize_px / width_old
                resize.scale(resize_factor, resize_factor)
                AffineTransformOp resizeOp = new AffineTransformOp(resize, AffineTransformOp.TYPE_BILINEAR)
                resizeOp.filter(old_img, img)
                w = img.getWidth()
                h = img.getHeight()
    
                def fileImage = new File(home_dir, tile_name + ".jpg")
                print("Writing image tiles for " + tile_name)
                ImageIO.write(img, "JPG", fileImage)
            }

        } else {
            print("Name: " + obj.name)
            points = roi.getPolygonPoints()
            ann_file << "Name: " + obj.name << System.lineSeparator()
            for (point in points) {
                p_x = point.getX()
                p_y = point.getY()
                coordinates = p_x + ", " + p_y
                ann_file << coordinates << System.lineSeparator()
            }
            ann_file << "end" << System.lineSeparator()
        }
    }
}
print("Finished processing all tiles")