#!/bin/bash
# Replays build 21 on top of upstream nx2, then joins it to this fork's history.
# Run from the repository root with the fork's current tip in the ref fork_tip.
# PATCH_DIR holds meshpoints21.patch. LOCAL_ONLY=1 skips the fetches.
set -eux
UP=${UPSTREAM:-https://github.com/zortos293/lichii}
if [ -z "${LOCAL_ONLY:-}" ]; then
  git fetch -q "$UP" 9fa4a71fa051aa857e2d8f370aa31739a4f062c2 89f72df5528566ccb0fe42b01088d1708a832f70 b97f16454604e3fa42ab510570ff0945ec642997 63653ea59ea137f4453c9d63ad124e0508e5134d be04fb78c3e3da37fe2b9f63e2b76cd8ad4568bd 06c604c9e7d79f98601a6f78de9d4fb91eae3558 8ca6ee9e26c21cdc2658b6d03fc26e3d12497e4f
fi
git checkout -q --detach 9fa4a71fa051aa857e2d8f370aa31739a4f062c2
git merge -q --no-ff -m "Merge upstream PR #434 (64 storage buffers, rebuild compute translations without dropping pointers: OoT near foliage)" 89f72df5528566ccb0fe42b01088d1708a832f70
for c in 0df39dbcac6dee519153396e7110b3ee1b5a6d9c cc9cbc81055e80d6706ea4e3324c53d6f54e083a dad3c1d8863ad5f7682864a935633de5dbaa2b6b c0d0bfc236fb2838078431c07c3a0ca990178fec 1934647e196940282eb8152f0a2e550c18b9c95b 9f2262b7302c8aba17de7c3d4483db877072292d 2bff9ec4f3da0c2d8a9815186ea11aaabf45eca6 f43e1c0ab262715503e7f264e4afb36bbfd087ff c1b217ca25995237f010ad49cb96769121dd74ce d8d7e2e04439f7e44f7cdadec84326ea3f4e0987 75d7abc9b86768a239219b8ce6c277673a582068 268b958a62ab1ed6dc7826f881874e4a3c961407 4e85f64ac4674f51bd6c49a990982032ab15efd3 691775ae049734176273b23d364213752611a81a 404518069fdcd303bb47efb5e75974bb6fa151ab f13ea85b3975d77b450a907753feb8f2d0cca2fa c055150efead6d9ef0f45a8b8f2b84862b37d3ae 3b29edc2835491ad0d9eb32f0d8d57a727b01cc0 5c7dde1b697714180b1bc037b31def48f6d39e33 aa1f2888edf913c95f490b4d398e5515826e888b 813c1488a28ffe675030f3a4b0ea478677754862 f4976e4a69ca1b2fe150d93ecf803aacb90505fb 43a022b3de30be49efc4d3b651497b2a1cc84191 7955f6bf5e5788dcbaa7117c25dd20d7f962d6b5 6f608a13d2839fca4f11f27a2485b0666db29b62 c3475ab788e393363780b46d1edd96a8786ba698 1c0fe7742b648e943776bd85bd03b6c89766829c bcd92bf1622ee5e675eeaaedcbde08f003c19369 d5e92ca39eb063a3280d6443505e943b1b1db54d 161bcdf90f105e6488e84d88b0ebea772ef4ff68 07e6da2f624c4d415b2407d5d7c64de15fdab9b7 9c84933745e92775f66ecaed1dd693d18d13e5b0 71dcb932439a4986e007d25a04b57f75bde4ce23 8907d321bee57ed470a35de0f6e45e46cae8c8e2 b67c4b7c82c0a31cf18ab341c90d0f38c04acaa5 9d32141dee187dd1664802455531a8da9ea5a495 3854e768895cb610ee7b16e2870e0052b0df2870 5f4e2b85d1b4abec8771156ece3308fe93725d13 cabb65c3e3d294306f90304059e682e1d9209b54 06c604c9e7d79f98601a6f78de9d4fb91eae3558 fc31275785a7adf6cfa80f927cffc5ffb1dbe45b 90879c10e7102503e4679b13a7720e7ec1aff643 c3bc77b21c27b95c9849a18cd7a1cf64e691369e 8ca6ee9e26c21cdc2658b6d03fc26e3d12497e4f; do
  git cherry-pick -x "$c" >/dev/null
done
git merge -q --no-ff -m "Merge upstream PR #192 (store guarded and mesh pipelines in the Vulkan disk cache)" 63653ea59ea137f4453c9d63ad124e0508e5134d
git am -q -C2 --keep-cr "$PATCH_DIR/meshpoints21.patch"
git cherry-pick -x be04fb78c3e3da37fe2b9f63e2b76cd8ad4568bd >/dev/null
test "$(git rev-parse 'HEAD^{tree}')" = 4340e13971e87ef8a0a83e941a945b2de3c05c97
# The token can't push workflow changes: keep the fork's .github exactly.
for f in $(git ls-tree -r --name-only HEAD .github); do
  git cat-file -e "fork_tip:$f" 2>/dev/null || git rm -q "$f"
done
git checkout fork_tip -- .github
git commit -q -m "Keep this fork's workflow files (Windows only, AV1 from MSYS2 FFmpeg)" || true
test -z "$(git diff fork_tip HEAD -- .github)"
TREE=$(git rev-parse 'HEAD^{tree}')
echo "final tree $TREE"
NEW=$(git commit-tree "$TREE" -p fork_tip -p HEAD -m "Build 21: upstream nx2 9fa4a71f with #434, #267, #446 and this fork's changes")
git checkout -q --detach "$NEW"
