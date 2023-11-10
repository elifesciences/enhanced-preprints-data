const fs = require('fs');
const path = require('path');

const SOURCE_FOLDER = './data';
const DEST_FOLDER = './data-new';
const SOURCE_FILE_NAME = 'source.txt';

function compare(source, dest) {
    let file1 =  fs.readFileSync(source, 'utf-8');
    let file2 =  fs.readFileSync(dest, 'utf-8');

    return file1 === file2;
}

async function iterateDirectory(directory) {

    let entries;
    try {
        entries = fs.readdirSync(directory);
    } catch (error) {
        console.error(`error reading ${directory}:`, error);
        return;
    }

    for (const entry of entries) {

        let fullPath = path.join(directory, entry);
        let stat = fs.lstatSync(fullPath);

        if (stat.isDirectory()) {
            await iterateDirectory(fullPath);
        } else if (entry === SOURCE_FILE_NAME) {
            const destPath = fullPath.replace(SOURCE_FOLDER, DEST_FOLDER);
            if (fs.existsSync(destPath)) {
                const isIdentical = compare(fullPath, destPath);
                if (isIdentical) {
                    console.log(`File ${fullPath} is identical to ${destPath}`);
                } else {
                    console.log(`File ${fullPath} is different from ${destPath}`);
                }
            } else {
                console.log(`Corresponding file does not exist at ${destPath}`);
            }
        }
    }
}

iterateDirectory(SOURCE_FOLDER);
