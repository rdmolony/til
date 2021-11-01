# How the navbar links to the pages

The navbar is created using [`bootstrap css`](https://getbootstrap.com/) to style a `<ul>` elements within a `<nav>` element into a quality navigation bar.

`Django` views are called to link to specific pages.

For example, the navbar links to the LIDAR page by referencing the associated view via `Django` templating `{% url 'lidar_report'%}` which returns a URL when called: 

```html
<nav class="navbar navbar-default">
    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
        <ul class="nav navbar-nav">
            ...
            <li class="dropdown">
                <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false">Reports<span class="caret"></span></a>
                <ul class="dropdown-menu" role="menu">
                    ...
                    <li><a href="{% url 'lidar_report'%}">LiDAR</a></li>
                </ul>
            </li>
        </ul>
    </div>
</nav>
```