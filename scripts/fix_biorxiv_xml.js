var fs = require('fs');
var pathlib = require('path');
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
    fileContent = fileContent.replace(new RegExp('<label>(.*)<\/label>[\r\n]*<title>', 'mg'), '<title>'); // <label>1</label><title> -> <title><label>1</label>

    // fix citations
    // <ext-link ext-link-type="uri" xlink:href="https://doi.org/{doi}">https://doi.org/{doi}</ext-link> -> <pub-id pub-id-type="doi">{doi}</pub-id>
    fileContent = fileContent.replace(new RegExp('<ext-link ext-link-type="uri" xlink:href="https://doi.org/(.*)">.*</ext-link>', 'mg'), '<pub-id pub-id-type="doi">$1</pub-id>'); // <label>1</label><title> -> <title><label>1</label>


    // article-specific
    const doi = `${pathlib.basename(pathlib.dirname(pathlib.dirname(path)))}/${pathlib.basename(path, '.xml')}`;

    switch (doi) {
      case '10.1101/2022.05.30.22275761':
        fileContent = fileContent.replace(new RegExp('<sec sec-type="supplementary-material">(.*)</sec>\r\n</body>', 'mgs'), '</body>'); // remove supplementary materials

        // add affiliation for Anna Kankaanp&#x00E4;&#x00E4;
        fileContent = fileContent.replace(
          new RegExp('<xref ref-type="corresp" rid="cor1">&#x002A;</xref>', 'mgs'),
          '<xref ref-type="aff" rid="a1">1</xref>'+"\n"+
          '<xref ref-type="corresp" rid="cor1">&#x002A;</xref>'
        );
        break;

      case '10.1101/2022.07.26.501569':
        fileContent = fileContent.replace(
          new RegExp('</institution>, Ecole Polytechnique F&#x00E9;d&#x00E9;rale de Lausanne', 'g'),
          ', Ecole Polytechnique F&#x00E9;d&#x00E9;rale de Lausanne</institution>'
        );
        break;
    }


    fs.writeFileSync(path, fileContent);
}

try {
  fixXml(process.argv[2]);
} catch (error) {
  console.log(error);
  process.exit(1);
}
