---
layout: appslet
title: Meals
section: apps
permalink: /apps/meals/
description: This week's dinners and Jaxon's breakfasts.
---

{% assign meals = site.data.meals %}

<p class="appslet-meta">
  <strong>Week of:</strong> {{ meals.week_of | date: "%A, %B %-d, %Y" }}
</p>

{% if meals.note %}
<p class="appslet-note">{{ meals.note }}</p>
{% endif %}

<section class="meals-section">
  <h2>Dinners</h2>
  <div class="meals-grid">
    {% for d in meals.dinners %}
    <article class="meal-card">
      <header class="meal-card__header">
        <h3>{{ d.title }}</h3>
        {% if d.time %}<span class="meal-card__time">{{ d.time }}</span>{% endif %}
      </header>

      {% if d.ingredients %}
      <details class="meal-card__details">
        <summary>Ingredients</summary>
        <ul>
          {% for i in d.ingredients %}<li>{{ i }}</li>{% endfor %}
        </ul>
      </details>
      {% endif %}

      {% if d.method %}
      <p class="meal-card__method"><strong>Method:</strong> {{ d.method }}</p>
      {% endif %}

      {% if d.leftover_lunch %}
      <p class="meal-card__lunch"><strong>Leftover lunch:</strong> {{ d.leftover_lunch }}</p>
      {% endif %}

      {% if d.kid_mod %}
      <p class="meal-card__kid"><strong>Kid mod:</strong> {{ d.kid_mod }}</p>
      {% endif %}
    </article>
    {% endfor %}
  </div>
</section>

{% if meals.jaxon_breakfasts %}
<section class="meals-section">
  <h2>Jaxon breakfasts <span class="meals-section__sub">(dairy-light)</span></h2>
  <ul class="breakfast-list">
    {% for b in meals.jaxon_breakfasts %}
    <li>
      <strong>{{ b.title }}.</strong> {{ b.note }}
    </li>
    {% endfor %}
  </ul>
</section>
{% endif %}
