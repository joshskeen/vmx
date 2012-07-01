//taken from www.barbafan.de/html5video?video=tron


var r = 255;
var g = 255;
var b = 255;
var cr = r/255;
var cg = g/255;
var cb = b/255;

var matrixrange = 7.7;

var doEdgeDetectionAlgorithm = function (inputData, baseColor, grey, outputData, w, h, range) {
   
    if (range == null){range=9}
    var bytesPerRow = w * 4;
    var pixel = bytesPerRow + 4; // Start at (1,1)
    var hm1 = h - 1;
    var wm1 = w - 1;
    var d = new Date;
    for (var y = 1; y < hm1; ++y) {
        // Prepare initial cached values for current row
        var centerRow = pixel - 4;
        var priorRow = centerRow - bytesPerRow;
        var nextRow = centerRow + bytesPerRow;
        var r1 = - inputData[priorRow]   - inputData[centerRow]   - inputData[nextRow];
        var g1 = - inputData[++priorRow] - inputData[++centerRow] - inputData[++nextRow];
        var b1 = - inputData[++priorRow] - inputData[++centerRow] - inputData[++nextRow];
        var rp = inputData[priorRow += 2];
        var rc = inputData[centerRow += 2];
        var rn = inputData[nextRow += 2];
        var r2 = - rp - rc - rn;
        var gp = inputData[++priorRow];
        var gc = inputData[++centerRow];
        var gn = inputData[++nextRow];
        var g2 = - gp - gc - gn;
        var bp = inputData[++priorRow];
        var bc = inputData[++centerRow];
        var bn = inputData[++nextRow];
        var b2 = - bp - bc - bn;
        
        // Main convolution loop
        for (var x = 1; x < wm1; ++x) {
            centerRow = pixel + 4;
            priorRow = centerRow - bytesPerRow;
            nextRow = centerRow + bytesPerRow;
            var r = baseColor + r1 - rp - (rc * (range*-1)) - rn;
            var g = baseColor + g1 - gp - (gc * (range*-1)) - gn;
            var b = baseColor + b1 - bp - (bc * (range*-1)) - bn;
            r1 = r2;
            g1 = g2;
            b1 = b2;
            rp = inputData[priorRow];
            rc = inputData[centerRow];
            rn = inputData[nextRow];
            r2 = - rp - rc - rn;
            gp = inputData[++priorRow];
            gc = inputData[++centerRow];
            gn = inputData[++nextRow];
            g2 = - gp - gc - gn;
            bp = inputData[++priorRow];
            bc = inputData[++centerRow];
            bn = inputData[++nextRow];
            b2 = - bp - bc - bn;
            if( !grey ) {
                outputData[pixel] = r + r2;
                outputData[++pixel] = g + g2;
                outputData[++pixel] = b + b2;
            } else {
                factor = .3* (r+r2) + .59*(g+g2) +.11*(b+b2);
                outputData[pixel] = factor;
                outputData[++pixel] = factor;
                outputData[++pixel] = factor;
            }
            outputData[++pixel] = 100; // alpha
            ++pixel;
        }
        pixel += 8;
    }
    //alert((new Date - d) / 1000);
    return outputData;
}

function filter_matrix(inputPA, outputPA, w, h) {
                var inputData = inputPA.data;
                var outputData = outputPA.data;
                outputData =  doEdgeDetectionAlgorithm(inputData,255, 1, outputData,w,h, matrixrange);
            
    var pixel = 0;
    for (var y = 0; y < h; ++y) {
        for (var x = 0; x < w; ++x) {
            if( outputData[pixel] < 240 ) {
                outputData[pixel] = 0;
                outputData[++pixel] = 0;
                outputData[++pixel] = 0;
            } else {
                outputData[pixel] = 0;
                outputData[++pixel] = 192;
                outputData[++pixel] = 0;
            }
            outputData[++pixel] = 255;
            ++pixel;
        }
    }
                
                return outputPA;
    }

function filter_to_bw_outline(inputPA, outputPA, w, h) {
                var inputData = inputPA.data;
                var outputData = outputPA.data;
                outputData =  doEdgeDetectionAlgorithm(inputData,255, 1, outputData,w,h, 8);
            
    var pixel = 0;
    for (var y = 0; y < h; ++y) {
        for (var x = 0; x < w; ++x) {
            if( outputData[pixel] < 240 ) {
                outputData[pixel] = 0;
                outputData[++pixel] = 0;
                outputData[++pixel] = 0;
            } else {
                outputData[pixel] = 255;
                outputData[++pixel] = 255;
                outputData[++pixel] = 255;
            }
            outputData[++pixel] = 255;
            ++pixel;
        }
    }        
    return outputPA;
}



function filter_invert(inputPA, outputPA, w, h)
{
				
				var inputData = inputPA.data;
				var outputData = outputPA.data;
				/*var cr = r/255;
				var cg = g/255;
				var cb = b/255;*/
				
					for (var y = 1; y < h-1; y += 1) {
        			for (var x = 1; x < w-1; x += 1) {
            		var pixel = (y*w + x)*4;
            		/*for (var c = 0; c < 3; c += 1) {         
                	outputData[pixel+c] = 255 - inputData[pixel+c];
            		}*/
            			outputData[pixel] = Math.round((255 - inputData[pixel]) * cr);
            			outputData[pixel+1] = Math.round((255 -inputData[pixel+1]) * cg);
            			outputData[pixel+2] = Math.round((255 - inputData[pixel+2]) * cb);
            		    outputData[pixel+ 3] = inputData[pixel+ 3];
        			}   
    				}
    			
    			return outputPA;
}

function filter_to_black_white(inputPA, outputPA, w, h)
    {
                //var A = $.inim.canvasIoFactory(canvas);
                //var ctx = A[0];
                var inputData = inputPA.data;
                var outputData = outputPA.data;
                //var w = input.width;
                //var h = input.height;
                
                for (var y = 0; y < h; y += 1)
                {
                    for (var x = 0; x < w; x += 1)
                    {
                        var pixel = (y*w + x)*4;
                        var factor = ((inputData[pixel] *.3 + inputData[pixel+1]*.59 + inputData[pixel+2]*.11) );
                        outputData[pixel] = factor * 1;
                        outputData[pixel+1] = factor * 1;
                        outputData[pixel+2] = factor * 1;
                        outputData[pixel+ 3] = inputData[pixel+ 3];
                    }      
                }
                
            return outputPA;
    }


function filter_sepia(inputPA, outputPA, w, h)
    {
                //var A = $.inim.canvasIoFactory(canvas);
                //var ctx = A[0];
                var inputData = inputPA.data;
                var outputData = outputPA.data;
                //var w = input.width;
                //var h = input.height;
                var sr; var sg; var sb;
                var rr; var rg; var rb;
                for (var y = 0; y < h; y += 1)
                {
                    for (var x = 0; x < w; x += 1)
                    {
                        var pixel = (y*w + x)*4;
                      sr = inputData[pixel];
                      sg = inputData[pixel+1];
                      sb = inputData[pixel+2];
                     rr = (sr * 0.393 + sg * 0.769 + sb * 0.189);
                      rg = (sr * 0.349 + sg * 0.686 + sb * 0.168);
                      rb = (sr * 0.272 + sg * 0.534 + sb * 0.131);
                     if (rr < 0) rr = 0; if (rr > 255) rr = 255;
                            if (rg < 0) rg = 0; if (rg > 255) rg = 255;
                            if (rb < 0) rb = 0; if (rb > 255) rb = 255;
                        outputData[pixel] = Math.round(rr*cr);
                        outputData[pixel+1] = Math.round(rg*cg);
                        outputData[pixel+2] = Math.round(rb*cb);
                        outputData[pixel+ 3] = inputData[pixel+3];
                        /*  var pixel = (y*w + x)*4;
                        var factor = ((inputData[pixel] *.3 + inputData[pixel+1]*.59 + inputData[pixel+2]*.11) );
                        outputData[pixel] = factor * 1;
                        outputData[pixel+1] = factor * 1;
                        outputData[pixel+2] = factor * 1;
                        outputData[pixel+ 3] = inputData[pixel+ 3];*/
                    }      
                }
                
            return outputPA;
    }