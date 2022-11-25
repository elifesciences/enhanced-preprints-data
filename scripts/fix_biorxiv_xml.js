var fs = require('fs');
var pathlib = require('path');
const { exit } = require('process');

function fixXml(path) {
    // load the html file
    var fileContent = fs.readFileSync(path, 'utf8');

    // replace more complex patterns

    // <label>1</label><title> -> <title><label>1</label>
    fileContent = fileContent.replace(new RegExp('<label>(.*)</label>[\r\n]*<title>', 'mg'), '<title><label>$1</label> ');

    // <title>ALL CAPS INTRO</title> -> <title>All caps intro</title>
    fileContent = fileContent.replace(
      new RegExp('<title>([A-Z\\s]+)</title>', 'g'),
      (match, title) => {
        const exceptions = ['LTPA'];
        if (exceptions.includes(title)) {
          return match;
        }
        return `<title>${title.charAt(0).toUpperCase() + title.slice(1).toLowerCase()}</title>`;
      },
    );

    // fix citations
    // <ext-link ext-link-type="uri" xlink:href="https://doi.org/{doi}">https://doi.org/{doi}</ext-link> -> <pub-id pub-id-type="doi">{doi}</pub-id>
    fileContent = fileContent.replace(new RegExp('<ext-link ext-link-type="uri" xlink:href="https://doi.org/(.*)">.*</ext-link>', 'mg'), '<pub-id pub-id-type="doi">$1</pub-id>'); // <label>1</label><title> -> <title><label>1</label>


    // article-specific
    const doi = `${pathlib.basename(pathlib.dirname(pathlib.dirname(path)))}/${pathlib.basename(path, '.xml')}`;

    switch (doi) {
      case '10.1101/2022.05.30.22275761':
        fileContent = fileContent.replace(new RegExp('<sec sec-type="supplementary-material">(.*)</sec>\r\n</body>', 'mgs'), '</body>'); // remove supplementary materials
        fileContent = fileContent.replace(new RegExp('<sec sec-type="data-availability">(.*?)</sec>', 'mgs'), ''); // remove duplicate data-availability

        // add affiliation for Anna Kankaanp&#x00E4;&#x00E4;
        fileContent = fileContent.replace(
          new RegExp('<xref ref-type="corresp" rid="cor1">&#x002A;</xref>', 'mgs'),
          '<xref ref-type="aff" rid="a1">1</xref>'+"\n"+
          '<xref ref-type="corresp" rid="cor1">&#x002A;</xref>'
        );
        break;

      case '10.1101/2021.11.12.468444':
          fileContent = fileContent.replace(new RegExp('<sec sec-type="supplementary-material">(.*)</sec>\r\n</body>', 'mgs'), '</body>'); // remove supplementary materials

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
