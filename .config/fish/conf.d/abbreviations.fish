abbr -a -- vim nvim

abbr --add code code-insiders
abbr --add tf terraform
abbr --add terrafrom terraform
abbr --add python python3
abbr --add vim nvim
abbr --add ta tmuxifier attach
abbr --add tas tmuxifier attach-session
abbr --add tl tmuxifier list
abbr --add tls tmuxifier load-session
abbr --add tn tmuxifier new
abbr --add tns tmuxifier new-session
abbr --add ts tmuxifier start
abbr --add tss tmuxifier start-session

abbr --add  g git

abbr --add  ga git add
abbr --add  gaa git add --all
abbr --add  gb git branch
abbr --add  gcmsg! git commit -v
abbr --add  gc! git commit -v --amend
abbr --add  gcb git checkout -b
abbr --add  gcf git config --list
abbr --add  gcm git checkout master
abbr --add  gc git commit -m
abbr --add  gco git checkout
abbr --add  gcp git cherry-pick

abbr --add  gd git diff
abbr --add  gdca git diff --cached
abbr --add  gdct git describe --tags `git rev-list --tags --max-count 1`
abbr --add  gdt git diff-tree --no-commit-id --name-only -r
abbr --add  gdw git diff --word-diff

abbr --add  gf git fetch
abbr --add  gfa git fetch --all --prune
abbr --add  gfo git fetch origin

# abbr --add  ggpull git pull origin $(git_current_branch)

# abbr --add  ggpush git push origin $(git_current_branch)
# abbr --add  ggsup git branch --set-upstream-to origin/$(git_current_branch)
# abbr --add  gpsup git push --set-upstream-to origin/$(git_current_branch)


abbr --add  gl git pull
abbr --add  glg git log --stat
abbr --add  glgp git log --stat -p
abbr --add  glgg git log --graph
abbr --add  glgga git log --graph --decorate --all
abbr --add  glgm git log --graph --max-count 10
abbr --add  glo git log --oneline --decorate
# abbr --add  glol "git log --graph --pretty format:%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset --abbrev-commit"
# abbr --add  glola "git log --graph --pretty format:%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset --abbrev-commit --all"
abbr --add  glog git log --oneline --decorate --graph
abbr --add  gloga git log --oneline --decorate --graph --all
# abbr --add  glp "_git_log_prettily"

abbr --add  gm git merge
abbr --add  gmom git merge origin/master
abbr --add  gmum git merge upstream/master

abbr --add  gp git push
abbr --add  gpd git push --dry-run
# abbr --add  gpoat git push origin --all & git push origin --tags
abbr --add  gpu git push upstream
abbr --add  gpv git push -v
# abbr --add  gprune gitPruneBranch() { git fetch --prune && for branch in `git branch -vv | grep ": gone]" | awk "{print $1}"`; do git branch -D $branch; done }; gitPruneBranch

abbr --add  gr git remote
abbr --add  gra git remote add
abbr --add  grb git rebase
abbr --add  grba git rebase --abort
abbr --add  grbc git rebase --continue
abbr --add  grbi git rebase -i
abbr --add  grbm git rebase master
abbr --add  grbs git rebase --skip
abbr --add  grh git reset HEAD
abbr --add  grhh git reset HEAD --hard
abbr --add  grmv git remote rename
abbr --add  grrm git remote remove
abbr --add  grset git remote set-url
# abbr --add  grt cd $(git rev-parse --show-toplevel || echo ".")
abbr --add  gru git reset --
abbr --add  grup git remote update
abbr --add  grv git remote -v

abbr --add  gsb git status -sb
abbr --add  gsd git svn dcommit
abbr --add  gsi git submodule init
abbr --add  gsps git show --pretty short --show-signature
abbr --add  gsr git svn rebase
abbr --add  gss git status -s
abbr --add  gst git status
abbr --add  gsta git stash save
abbr --add  gstaa git stash apply
abbr --add  gstd git stash drop
abbr --add  gstl git stash list
abbr --add  gstp git stash pop
abbr --add  gsts git stash show --text
abbr --add  gsu git submodule update

abbr --add  gts git tag -s
abbr --add  gtv git tag | sort -V

abbr --add  gunignore git update-index --no-assume-unchanged
# abbr --add  gunwip git log -n 1 | grep -q -c "\-\-wip\-\-" & git reset HEAD~1
abbr --add  gup git pull --rebase
abbr --add  gupv git pull --rebase -v
abbr --add  glum git pull upstream master

abbr --add  gwch git whatchanged -p --abbrev-commit --pretty medium
# abbr --add  gwip git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit -m "--wip--"
