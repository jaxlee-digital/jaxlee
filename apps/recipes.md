---
layout: appslet
title: Recipes
section: apps
permalink: /apps/recipes/
description: Family recipes, collected and kept.
---

{% assign recipes = site.data.recipe_index %}

<ul class="recipe-index">
  {% for r in recipes %}
  <li class="recipe-index__item">
    <a href="{{ '/apps/recipes/' | append: r.slug | append: '/' | relative_url }}">
      <h2>{{ r.title }}</h2>
      {% if r.tags %}
      <ul class="recipe-tags" aria-label="Tags">
        {% for tag in r.tags %}<li>{{ tag }}</li>{% endfor %}
      </ul>
      {% endif %}
    </a>
  </li>
  {% endfor %}
</ul>
