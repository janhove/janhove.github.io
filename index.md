---
layout: page
title: Blog
---
{% include JB/setup %}

<p>I blog about statistics and research design with an audience consisting of researchers in bilingualism, multilingualism, and applied linguistics in mind.</p>

<p><a href="blogfeed.xml"><img src="/figs/feed.png" alt="Feed"/>&nbsp;Subscribe to new blog posts.</a></p>

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
    <p><small>{{ post.date | date: "%-d %B %Y" }}</small></p>
    
{{ post.content | split:'<!--more-->' | first }}

<p>
	<a class="btn" href="{{ BASE_PATH }}{{ post.url }}">Read more...</a>
	</p>
</div>
</div>

{% endfor %}
