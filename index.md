---
layout: page
title: Hello World!
tagline: Supporting tagline
---
{% include JB/setup %}

Read [Jekyll Quick Start](http://jekyllbootstrap.com/usage/jekyll-quick-start.html)

Complete usage and documentation available at: [Jekyll Bootstrap](http://jekyllbootstrap.com)

## Latest blog posts


<div class="row">
  {% for post in site.posts limit:3 %}
  <div class="span4">
    <a href="{{ BASE_PATH }}{{ post.url }}"><h2>{{ post.title }}</h2></a>
	<hr />
	<p>{% if post.thumbnail %}
	<img src="{{ post.thumbnail }}" style="height: 280px" align="center" />
	{% else %}
	<img src="/images/nothumbnail.jpg"
  style="height: 280px" align="center" />
	{% endif %}</p>
	<p>&nbsp;</p>
	<p>
	{{ post.content | strip_html | truncatewords:20 }}
	</p>
	<p>
	<a class="btn" href="{{ BASE_PATH }}{{ post.url }}">Read more...</a>
	</p>
  </div>
  {% endfor %}
</div>


{% for post in site.posts limit:10 offset:3 %}
<hr />
<div class="row">
  <div class="span2">
    {% if post.thumbnail %}
	<img src="{{ post.thumbnail }}" align="center" />
	{% else %}
	<img src="/assets/themes/tmtxt-responsive/images/no-thumnail.jpg" align="center" />
	{% endif %}
  </div>
  <div class="span10">
    <p><a href="{{ BASE_PATH }}{{ post.url }}"><h3>{{ post.title }}</h3></a></p>
	<p>{{ post.content | strip_html | truncatewords: 150 }}
	</p>
  </div>
</div>
{% endfor %}


