---
layout: default
title: "Sheehan"
permalink: /authors/sheehan/
---

{% assign author = site.data.authors.sheehan %}
<section class="author-page">
  <header class="author-page__head">
    {% if author.avatar %}<img class="author-page__avatar" src="{{ author.avatar | relative_url }}" alt="">{% endif %}
    <div>
      <p class="section-label">Contributor</p>
      <h1>{{ author.name }}</h1>
      <p class="lede">{{ author.bio }}</p>
    </div>
  </header>

  <section class="author-page__posts">
    <p class="section-label">Posts by {{ author.name }}</p>
    <ul class="archive__list">
      {% for post in site.posts %}
        {% if post.author == "sheehan" or post.co_authors contains "sheehan" %}
          <li>
            <a href="{{ post.url | relative_url }}">
              <time>{{ post.date | date: "%Y.%m.%d" }}</time>
              <span class="archive__title">{{ post.title }}</span>
            </a>
          </li>
        {% endif %}
      {% endfor %}
    </ul>
  </section>
</section>
