---
layout: appslet
title: "Grandfather's Barbecue Sauce"
section: apps
permalink: /apps/recipes/grandfathers-bbq-sauce/
description: "A slow-simmered family barbecue sauce. Never let it boil."
recipe_slug: grandfathers-bbq-sauce
---

{% assign recipe = site.data.recipes[page.recipe_slug] %}

<p class="appslet-eyebrow"><a href="{{ '/apps/recipes/' | relative_url }}">← Recipes</a></p>

<article class="recipe">

  <header class="recipe__header">
    <h1 class="recipe__title">{{ recipe.title }}</h1>
    {% if recipe.attribution %}<p class="recipe__attribution">{{ recipe.attribution }}</p>{% endif %}
    {% if recipe.notes %}<p class="recipe__notes">{{ recipe.notes }}</p>{% endif %}
    {% if recipe.tags %}
    <ul class="recipe-tags" aria-label="Tags">
      {% for tag in recipe.tags %}<li>{{ tag }}</li>{% endfor %}
    </ul>
    {% endif %}
  </header>

  <div class="recipe__body">

    <section class="recipe__ingredients" aria-labelledby="ingredients-heading">
      <h2 id="ingredients-heading">Ingredients</h2>
      <ul>
        {% for item in recipe.ingredients %}
        <li>{{ item }}</li>
        {% endfor %}
      </ul>
    </section>

    <section class="recipe__instructions" aria-labelledby="instructions-heading">
      <h2 id="instructions-heading">Instructions</h2>
      <ol>
        {% for s in recipe.instructions %}
        <li>{{ s.text }}</li>
        {% endfor %}
      </ol>
    </section>

  </div>

  {% if recipe.image %}
  <figure class="recipe__original">
    <img src="{{ recipe.image | relative_url }}" alt="{{ recipe.image_alt }}" loading="lazy">
    {% if recipe.image_caption %}<figcaption>{{ recipe.image_caption }}</figcaption>{% endif %}
  </figure>
  {% endif %}

</article>
