---
layout: page
title: Homepage
---
{% include JB/setup %}

<!-- <div style="float: right">
   <img src="/figs/foto.JPG" alt="Photo" title="Photo"/>
</div> -->

I teach and do research at the Department of Multilingualism at the University of Fribourg.
I blog about statistical issues and research design in applied linguistics and multilingualism research.



<p><a href="blogfeed.xml"><img src="/figs/feed.png" alt="Feed"/>&nbsp;Subscribe to new blog posts.</a></p>
<p><a href="paperfeed.xml"><img src="/figs/feed.png" alt="Feed"/>&nbsp;Subscribe to new academic publications.</a></p>

## Latest blog posts

<div class="row">
  {% for post in site.posts limit:0 %}
   <div class="span4">
    <a href="{{ BASE_PATH }}{{ post.url }}"><h3>{{ post.title }}</h3></a>
	<hr />
	<p>{% if post.thumbnail %}
	<img src="{{ post.thumbnail }}" style="height: 280px" align="center" />
	{% else %}
	
	{% endif %}</p>
	<p>&nbsp;</p>

	{{ post.content | split:'<!--more-->' | first }}
	 
	<p>
	<a class="btn" href="{{ BASE_PATH }}{{ post.url }}">Read more...</a>
	</p>
  </div>
  {% endfor %}
</div>


{% for post in site.posts limit:10 offset:0 %}


<hr />
<div class="row">
<div class="span12">
    <p><a href="{{ BASE_PATH }}{{ post.url }}"><h3>{{ post.title }}</h3></a></p>
{{ post.content | split:'<!--more-->' | first }}

<p>
	<a class="btn" href="{{ BASE_PATH }}{{ post.url }}">Read more...</a>
	</p>
</div>
</div>

{% endfor %}

<!--<hr />
<div class="row">
  <div class="span2">
    {% if post.thumbnail %}
	<img src="{{ post.thumbnail }}" align="center" />
	{% else %}
	<img src="/assets/themes/tmtxt-responsive/images/no-thumnail.jpg" align="center" />
	{% endif %}
  </div>
</div>-->
