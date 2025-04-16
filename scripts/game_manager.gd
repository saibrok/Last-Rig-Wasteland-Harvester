## Синглтон для хранения глобальных ссылок на ключевые объекты игры и состояния.
extends Node

## Ссылка на сцену боевой арены.
var combat_arena: Node2D = null

## Ссылка на игрока.
var player: Node2D = null

## Ссылка на Ровер.
var rover: StaticBody2D = null

## Флаг, указывающий, находится ли игра в боевой арене.
var is_in_combat_arena: bool = true
