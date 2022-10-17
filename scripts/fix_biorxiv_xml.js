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
    fileContent = fileContent.replace(new RegExp('<label>(.*)<\/label>[\r\n]*<title>', 'mg'), '<title><label>$1</label> '); // <label>1</label><title> -> <title><label>1</label>

    fs.writeFileSync(path, fileContent);
}

try {
  fixXml(process.argv[2]);
} catch (error) {
  console.log(error);
  process.exit(1);
}
