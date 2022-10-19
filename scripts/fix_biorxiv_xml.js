var fs = require('fs');
const { exit } = require('process');

function fixXml(path) {
    // load the html file
    var fileContent = fs.readFileSync(path, 'utf8');

    // replace simple strings
    fileContent = fileContent.replace(new RegExp('<string-name', 'g'), '<name'); // string-name -> name
    fileContent = fileContent.replace(new RegExp('</string-name', 'g'), '</name'); // string-name -> name
    fileContent = fileContent.replace(new RegExp('<table-wrap', 'g'), '<fig'); // # table-wrap -> fig
    fileContent = fileContent.replace(new RegExp('</table-wrap>', 'g'), '</fig>'); // # table-wrap -> fig

    // replace more complex patterns

    // <label>1</label><title> -> <title><label>1</label>
    fileContent = fileContent.replace(new RegExp('<label>(.*)<\/label>[\r\n]*<title>', 'mg'), '<title>');

    // <title>ALL CAPS INTRO</title> -> <title>All caps intro</title>
    fileContent = fileContent.replace(
      new RegExp('<title>([A-Z\s]+)</title>', 'g'),
      (match, title) => `<title>${title.charAt(0).toUpperCase() + title.slice(1).toLowerCase()}</title>`,
    );

    fs.writeFileSync(path, fileContent);
}

try {
  fixXml(process.argv[2]);
} catch (error) {
  console.log(error);
  process.exit(1);
}
