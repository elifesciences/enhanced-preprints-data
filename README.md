## Clone repo without history

In the past we have stored all of the extracted meca files in the data folder. This makes a git clone with full history rather large. If you just want to bring down the current files:

```bash
git clone --depth 1 git@github.com:elifesciences/enhanced-preprints-data.git
```

## Add a PDF

Save the PDF to the appropriate place in the data folder.

To sync the changes from the data repo to the s3 bucket replay the steps:
- [Create a feature branch, review and merge](#create-a-feature-branch-review-and-merge)
- [Checkout master](#checkout-master)
- [Sync data folder to staging](#sync-data-folder-to-staging)
- [Sync data folder to prod](#sync-data-folder-to-prod)

## Create a feature branch, review and merge

Create a feature branch, commit your changes and push the branch.

Create a pull request at https://github.com/elifesciences/enhanced-preprints-data, review your changes and merge in, if happy.

## Checkout master

Once your PR has been merged then switch to the master branch and pull in these changes.

## Sync data folder to staging

```bash
./scripts/sync_data.sh staging
```

## Sync data folder to prod

```bash
./scripts/sync_data.sh
```

## Restore data folder from preserved pdf's

```bash
./scripts/introduce_pdfs.sh
```
