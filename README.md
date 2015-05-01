## nagnagnag

All you ever do is **nag nag nag**! "Are you still interested?" "Is this still
important?" "Does anyone care?"

This is a github issues bot, meant to be run once per day or so.

Give it a token, point it at a github repo and it will go comment on issues
with no activity in the last [x] days, asking if they are still pertinent.
It will wait another [y] days before closing the issue if there has been no
activity. A specific label can exempt issues from auto-closing.
