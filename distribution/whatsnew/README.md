# Play Store Changelogs

One directory per release, named exactly like the git tag (`v3.6.0`). Each one holds
the `whatsnew-<locale>` files that are uploaded with that release, so older
changelogs stay around instead of being overwritten.

Notes for the upcoming release are collected in `next/`. As part of the release
commit, rename it to the tag you are about to create:

    git mv distribution/whatsnew/next distribution/whatsnew/v3.7.0

The workflow uploads `distribution/whatsnew/$TAG`, so a missing or misnamed
directory fails the Play Store upload.
