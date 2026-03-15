var rows = $0.tBodies[0].rows;
var t = '';

for (var i = 0; i < rows.length; i++) {
    var row = rows[i];
    var link = row.cells[0].childNodes[0].href;
    var name = row.cells[0].childNodes[0].innerText;
    var desc = row.cells[1].childNodes[0].nodeValue;
    var date = row.cells[2].childNodes[0].nodeValue;

    t += `|[RFC-${name}](https://datatracker.ietf.org/doc/html/rfc${name}})|${date}|${desc}|Docs todo|TODO|\n`
}

rfc-url/date/description/documentation/state (todo/notdo)