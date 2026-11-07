#!/bin/bash
# Build 22: upstream nx2 65e979ad with #570 (water and window flicker), #268 and #313, joined to
# this fork's history. Run from the repository root with the fork's current tip in fork_tip.
set -eux
UP=${UPSTREAM:-https://github.com/zortos293/lichii}
if [ -z "${LOCAL_ONLY:-}" ]; then
  git fetch -q "$UP" 65e979adb3b6ce3f37b1b225c30bb91a5c1b7c0b 82d48cc7eeb9c641da3f923282940c3871e58cb9 4262a993e32a984061dd277669653978ea2d5da6 09d20d291a1935a12e112eb3f9fe23e225e59bb6
fi
git checkout -q --detach 65e979adb3b6ce3f37b1b225c30bb91a5c1b7c0b
git cherry-pick -x 82d48cc7eeb9c641da3f923282940c3871e58cb9 >/dev/null
git cherry-pick -x 4262a993e32a984061dd277669653978ea2d5da6 >/dev/null
git merge -q --no-ff -m "Merge upstream PR #313 (keep Switch 2 pipelines built)" 09d20d291a1935a12e112eb3f9fe23e225e59bb6
test "$(git rev-parse 'HEAD^{tree}')" = f735205077188661be88879eba773adc1893f2be
# The token can't push workflow changes: keep the fork's .github exactly.
for f in $(git ls-tree -r --name-only HEAD .github); do
  git cat-file -e "fork_tip:$f" 2>/dev/null || git rm -q "$f"
done
git checkout fork_tip -- .github
git commit -q -m "Keep this fork's workflow files" || true
test -z "$(git diff fork_tip HEAD -- .github)"
TREE=$(git rev-parse 'HEAD^{tree}')
echo "final tree $TREE"
NEW=$(git commit-tree "$TREE" -p fork_tip -p HEAD -m "Build 22: upstream nx2 65e979ad with #570, #268 and #313")
git checkout -q --detach "$NEW"
