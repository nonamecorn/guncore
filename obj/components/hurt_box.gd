extends Area2D

signal damaged(damage)

func hurt(amnt):
	damaged.emit(amnt)
