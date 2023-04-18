# Add a manuscript

Add the preprint doi to [manuscripts.txt](manuscripts.txt).

[manuscripts.txt](manuscripts.txt) contains a list of all the preprint doi's.

For the first version of a manuscript:

```txt
[msid]: [preprintDoi]
```

For multiple versions of a manuscript (for bioRxiv the `preprintDoi` will be duplicated - this is expected):

```txt
[msid]: [preprintDoi for v1],[preprintDoi for v2]
```

Example with duplicated `preprintDoi`:

```txt
85111: 10.1101/2022.11.08.515698,10.1101/2022.11.08.515698
```

## Handle non-bioRxiv manuscript

If the preprint meca file is not hosted bioRxiv, upload it to s3://prod-elife-epp-meca.

Add an entry in [meca-lookup.txt](meca-lookup.txt) with the format:

```txt
[preprintDoi]=s3://prod-elife-epp-meca/[mecaFile]
```

If there is more than one version of the manuscript the `preprintDoi` may not be enough (could be the same for all versions). Append the version as follows:

```txt
10.1101/2022.11.08.515698[2]=s3://transfers-elife/biorxiv_Current_Content/March_2023/21_Mar_23_Batch_1557/e7c056c2-6c16-1014-98e5-b5f7d8af8b03.meca
```

## Fetch meca files

Fetch meca files for entries in [manuscripts.txt](manuscripts.txt) that don't exist in the [data](data) folder:

```bash
./scripts/fetch_meca_archives.sh
```

If you want to trigger the preparation of a manuscript which is already in the data folder then delete the manuscript folder from the data folder.

For example, if you want to trigger the preparation of [85111/v1](data/85111/v1) then run the following before the next step:

```bash
rm -rf ./data/85111/v1
```

If you want to trigger the preparation of all manuscripts then delete the whole data folder:

```bash
rm -rf ./data
```

The meca files will be available in the `./incoming` folder.

In order to organise the extracted meca's, we have prefixed the msid, version and date to the filename. The date is extracted from the s3 source directory if found in the format `01_Jan_23`.

An example:

```bash
$ ls ./incoming
52299-1--30-May-22--06908fc3-73df-1014-bb56-a21daa237ef0.meca  85921-1--00-Unk-00--2200020-meca.zip
```

## Extract meca files

Extract the meca archives and prepare xml and assets for the data folder.

```bash
./scripts/extract_mecas.sh
```

As part of this script an attempt will be made to introduce the pdf from s3://prod-elife-epp-pdf/data

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

## Add a PDF

Save the PDF to the appropriate place in the data folder.

To sync the changes from the data repo to the s3 bucket replay the steps:
- [Create a feature branch, review and merge](#create-a-feature-branch-review-and-merge)
- [Checkout master](#checkout-master)
- [Sync data folder to staging](#sync-data-folder-to-staging)
- [Sync data folder to prod](#sync-data-folder-to-prod)
