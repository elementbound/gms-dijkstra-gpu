# Dijkstra on GPU
A simplified proof-of-concept implementation. 

A popular approach is to use a grid and feed that to the algorithm as a graph. Grids fit really well into textures, 
and given the algorithm, it is not too difficult to do it in a pixel shader. 

Each pixel's distance from the destination is stored in a texture which is fed to the pixel shader. 
The pixel shader, for each open* pixel, finds the neighboring pixel with the lowest value ( distance from destination ). 
This search excludes neighbors occupied by walls. 

Once each pixel has its value, navigation is easy. Starting from the source, move to the neighbor with the lowest value. 
When a local minimum is reached, it's either at the goal, or at a place where further pathing is not possible 
( i. e. the goal is not reachable from there ). 

## Limitations ##
The source includes proper functions for packing and unpacking large values to colors. However, for visualisation, only 
the red channel is used for now. This limits the maximum distance to 254.

Currently, the shader only works for 4 neighbors. Attempts were made to work with 8 neighbors, no success so far. 
Other possibilities weren't tested yet. It would be cool to do one with 3 neighbors. 

## Usage ##
Controls are displayed while running the app, but I'll include them here, too. 

Once started, you can draw walls with the left mouse button. To erase, use the right mouse button.

Once done, position the mouse over the destination and press Q. The pathing surface will be gradually 
filled with distances. This will probably be fast, and spectacular. 

When the filling is done, press W. The app will find a path from the mouse to the destination. 

You can save your map anytime with S. Load with L. Two sample maps are included with 
the repository - maze.png and walls.png. The maze was generated with GIMP.

## Promises ##
None :P This is something I spend a single afternoon with and rarely if ever look back. However, the code could 
use some obvious improvements, so who knows. *However, you are free to work on it, too.* I'd be glad to be 
notified if so :) 

## License ##
See the file named LICENSE. The source is under the MIT license. 
