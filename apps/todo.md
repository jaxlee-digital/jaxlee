---
layout: appslet
title: Todo
section: apps
permalink: /apps/todo/
description: Current list. Static — edit in the repo, push to update.
---

{% assign todo = site.data.todo %}

<p class="appslet-meta">
  <strong>Updated:</strong> {{ todo.updated | date: "%A, %B %-d, %Y" }}
</p>

{% if todo.note %}
<p class="appslet-note">{{ todo.note }}</p>
{% endif %}

{% for group in todo.groups %}
{% assign open_items = group.items | where_exp: "i", "i.done != true" %}
{% assign done_items = group.items | where: "done", true %}

<section class="todo-section">
  <h2>
    {{ group.title }}
    <span class="todo-section__count">{{ open_items | size }} open</span>
  </h2>

  {% if open_items.size > 0 %}
  <ul class="todo-list">
    {% for item in open_items %}
    <li class="todo-item">
      <span class="todo-item__title">{{ item.title }}</span>
      {% if item.due %}
      <span class="todo-item__due">due {{ item.due | date: "%b %-d" }}</span>
      {% endif %}
      {% if item.note %}
      <p class="todo-item__note">{{ item.note }}</p>
      {% endif %}
    </li>
    {% endfor %}
  </ul>
  {% else %}
  <p class="todo-section__empty">Nothing open.</p>
  {% endif %}

  {% if done_items.size > 0 %}
  <details class="todo-done">
    <summary>Done ({{ done_items | size }})</summary>
    <ul class="todo-list todo-list--done">
      {% for item in done_items %}
      <li class="todo-item todo-item--done">
        <span class="todo-item__title">{{ item.title }}</span>
      </li>
      {% endfor %}
    </ul>
  </details>
  {% endif %}
</section>
{% endfor %}
