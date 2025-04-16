## Синглтон для хранения глобальных ссылок на ключевые объекты игры.
extends Node

## Ссылка на сцену боевой арены.
var combat_arena: Node2D = null

## Ссылка на игрока.
var player: Node2D = null

## Ссылка на Ровер.
var rover: StaticBody2D = null