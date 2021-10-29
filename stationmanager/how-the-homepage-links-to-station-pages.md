# How the home page map links to a station page

Upon loading the homepage.  Django receives a request for **/**, searches `urls.py`, finds `url(r'^$', map, name='map')`, searches `views.py` for `map`, and renders `map.html`.

To render `map.html` it:

1) Creates the sidebar from `dynatree.html` - see [`dynatree` docs](https://www.patentscore-engine.com/pp/static/dynatree/doc/dynatree-doc.html)

`dynatree.html` defines an event listener which returns the URL **station/#id** when a station is double clicked on the sidebar. 

When the homepage is loaded  `<div id="tree">` inherits the `dynatree` object thanks to `dynatree.js` which is imported in the HTML head.  This enables defining an interactive sidebar by initialised the `dynatree` object with key-value pairs (or in `JS` a map).  Initialisation is performed like `$(function(){$("#tree").dynatree({API_NAME: VALUE})};` where the map keys match the API defined in the `dynatree` docs (`$(function(){...}` is standard `jQuery` for [running functions when the document has loaded](https://www.w3schools.com/jquery/jquery_syntax.asp)).

The key `initAjax` specifies an asynchronous HTTP request to a URL to be made on first load.  The URL is defined by `{url: main_tree_url, data: getTreeData()}` where `main_tree_url` links to a `Django` view (`main_tree_json` from `views.py`) and `data` defines the data to be passed to this view.  On first load only countries appear on the sidebar.  This is because `getTreeData()` returns `{owner_name: $('#select-owner-mrp').is(':checked') ? 'mrp' : ''}` so `main_tree_json` is passed `MRP` as the owner and so searches and returns all stations meeting this criteria.  It links all countries to projects, all projects to stations, and all stations to ids and returns this map of key-value pairs as a JSON.

To see the stations in each country the user must click the `+` icon to expand countries to projects and again for stations.  When a country or region `+` icon is clicked the `dynatree` event listener `onLazyRead` is called.  This behaves exactly the same as `initAjax`.  It calls `node.AppendAjax` with the similar arguments `{url: list_stations_dynatree_url, data: {project_name: node.data.title}}` where again `list_stations_dynatree_url` links to a `Django` view (`list_stations_dynatree` from `views.py`).  This time around the `node` has a `data.title` object since this was defined during `initAjax`.  

When the stations are visible on the sidebar and double clicked the `onDblClick` event is called which in turn calls `window.open(station_detail_url + '/' + node.data.id, name="_blank")`.

2) Creates a map from `map.html` by calling `map_initialize` defined in `stationmap.js.html` which is imported in the HTML head. 

`stationmap.js.html` defines an event listener which returns the URL **station/#id** when a station marker is double clicked.

On first load `map_initialize` calls `draw_map_stations_all` in `map.html`. `map_initialise` calls `draw_map_stations_all` (defined in `stationmap.js.html`) which loads the station data by calling a `Django` view (`list_map_stations` from `views.py`).  It then passes it as an argument to `setMarkers`.  The function `setMarkers` plots all markers on a map `<div>` element and links each marker to an `google.maps` event listener: `google.maps.event.addListener(markers[i], 'dblclick', function(innerKey){...}` which calls `station.url` on local object `station` to return the URL **station/#id** when a station marker is double clicked.
