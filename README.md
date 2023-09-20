# Add a PDF

Save the PDF to the appropriate place in the data folder.

To sync the changes from the data repo to the s3 bucket replay the steps:
- [Create a feature branch, review and merge](#create-a-feature-branch-review-and-merge)
- [Checkout master](#checkout-master)
- [Sync data folder to staging](#sync-data-folder-to-staging)
- [Sync data folder to prod](#sync-data-folder-to-prod)

## Create a feature branch, review and merge

Create a feature branch, commit your changes and push the branch.

Create a pull request at https://github.com/elifesciences/enhanced-preprints-data, review your changes and merge in if happy.

## Checkout master

Once your PR has been merged then switch to the master branch and pull in these changes.

## Sync data folder to staging

```bash
./scripts/sync_data.sh staging
```

Trigger a re-import at https://staging--epp.elifesciences.org/import

Once imported ensure you can see and are happy with the manuscript at https://staging--epp.elifesciences.org

## Sync data folder to prod

```bash
./scripts/sync_data.sh
```

Trigger a re-import at https://prod--epp.elifesciences.org/import

Once imported ensure you can see and are happy with the manuscript at https://prod--epp.elifesciences.org

## Restore data folder from preserved pdf's

```bash
./scripts/introduce_pdfs.sh
```
