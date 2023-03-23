# Add a manuscript

Add the preprint doi to [manuscripts.txt](manuscripts.txt).

[manuscripts.txt](manuscripts.txt) contains a list of all the preprint doi's.

## Handle non-bioRxiv manuscript

If the preprint meca file is not hosted bioRxiv, upload it to s3://prod-elife-epp-meca.

Add an entry in [meca-lookup.txt](meca-lookup.txt) with the format:

```txt
[preprintDoi]=s3://prod-elife-epp-meca/[mecaFile]
```

## Fetch meca files

Fetch meca files for entries in [manuscripts.txt](manuscripts.txt) that don't exist in the [data](data) folder:

```bash
./scripts/fetch_meca_archives.sh
```

If you want to trigger the preparation of a manuscript which is already in the data folder then delete the manuscript folder from the data folder.

For example, if you want to trigger the preparation of [10.1101/2020.07.223354](data/10.1101/2020.07.223354) then run the following before the next step:

```bash
rm -rf ./data/10.1101/2020.07.223354
```

If you want to trigger the preparation of all manuscripts then delete the whole data folder:

```bash
rm -rf ./data
```

The meca files will be available in the `./incoming` folder.

## Extract meca files

Extract the meca archives and prepare xml and assets for the data folder.

```bash
./scripts/extract_mecas.sh
```

As part of this script an attempt will be made to introduce the pdf from s3://prod-elife-epp-pdf/data

## Create a feature branch

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

Save the PDF to the appropriate place in the data folder. PDF's must be uploaded to s3://prod-elife-epp-pdf/data to ensure that we can trash the [data](data) folder and recreate it again if needed.

You can either upload it to s3 manually in the appropriate location or you can trigger syncing all [data](data) folder PDF files with the command:

```bash
./scripts/preserve_pdfs.sh
```

Create a feature branch, commit your changes and push the branch.

Create a pull request at https://github.com/elifesciences/enhanced-preprints-data, review your changes and merge in if happy.

To sync the changes from the data repo to the s3 bucket replay the steps:
- Checkout master
- Sync data folder to staging
- Sync data folder to folder
