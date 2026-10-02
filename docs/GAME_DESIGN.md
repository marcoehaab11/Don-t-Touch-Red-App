# Game Design

## Rules

Red orbs are safe and must be tapped before their timer runs out. Blue and yellow orbs are dangerous and should be left alone. Tapping a dangerous orb or missing a red orb costs one of three lives. The run ends at zero lives. The game can be paused and resumed.

## Scoring and progression

Each red tap scores `10 × min(5, 1 + floor(combo / 5))`. A mistake resets the combo. Every 15 seconds, spawn intervals and orb lifetimes shrink to fixed lower bounds. Red orbs occur with 70% probability. At game over, the player receives `floor(score / 10)` coins. Best score and ten local run scores persist.

## Power-ups, coins, and shop

Shield absorbs the next damaging event. Slow stretches orb lifetime and spawn interval for eight seconds. The player starts with one of each; additional uses cost 35 and 30 coins. The shop sells four visual variants of the red orb. Every variant remains visibly red. Prices and balance values live in `scripts/game_config.gd`.

## Missions and daily challenge

One-time missions reward 50 red taps, ten games, and a 15 combo. Daily challenge rewards 30 red taps and resets according to the device's local date. Claiming rewards is manual. Device date changes can affect the daily reset; no server time is used.

## Achievements and statistics

Achievements unlock after a first game, 100 red taps, a 20 combo, and a 500-point run. Statistics include games, score totals, taps, best combo, and time played. The leaderboard is local to the device; its data model is kept separate in `AppState` for a future online provider.
