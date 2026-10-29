# squished.

Game jam entry. Theme was "i'm just a little guy".

You're a tiny guy at the bottom of the screen and huge colorful blocks keep falling on you. Don't get squished. That's the whole game.

## Controls

- A / D or left / right arrows - move
- Space or Shift - dash (about 1/8 of the screen, 3 second cooldown)
- Enter - restart after you die

If you walk off one side of the screen you come out on the other side. The dash doesn't make you invincible, so you can still get hit in the middle of it.

The little bar under the floor shows when the dash is ready again.

## Running it

Made in Godot 4.x. Open the project folder in Godot and press F5, the main scene is `main.tscn`. There are no images or sounds, everything is drawn in code in `main.gd`.

## Notes

- Score goes up the longer you survive, and the blocks fall faster and spawn more often over time.
- Colors come from a palette I was given for the jam.
- Best score only lasts until you close the game, I didn't add saving.
- Things I'd add with more time: sound, jumping, some kind of pickups.
