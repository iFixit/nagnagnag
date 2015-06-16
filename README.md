## nagnagnag

All you ever do is **nag nag nag**! "Are you still interested?" "Is this still
important?" "Does anyone care?"

### What it does
**Automatically comments on and closes
old github issues if no one responds.**

This is a github issues bot, meant to be run once per day or so. **

Give it a token, point it at a github repo and it will go comment on issues
with no activity in the last `[--stale-after-days]` days,
asking if they are still pertinent.
It will wait another `[--stale-after-days]` days
before closing the issue if there has been no activity.
A specific label `[--exempt-label]` can exempt issues from auto-closing.

### Usage

1. Configure your github username and api token
   (from https://github.com/settings/tokens)

        $ git config github.user github-username
        $ git config github.token sdfadsflasdfasdfa

1. Run *nagnagnag*

        sage: nagnagnag --repo=user/repo
           -r, --repo REPO                  github username/repository
               --stale-after-days DAYS      Number of days to wait after the last activity
                                            on an issue before commenting or closing.
               --dry-run                    Don't actually write anything to github, only read
               --exempt-label LABEL         Name of issue label that will prevent issues
                                            from being examined or modified by this bot.
           -h, --help                       Show this message
