//Author : MechatronicBeing
//Licence : Creative Commons CC0 Public Domain Dedication
//WARNING : Markdown Parser in development !
  
//Get the mdFile name to read (stored as a attribute to div)
var mdFile = document.getElementById("divMD").getAttribute('data-mdFile');

//Call the readFile function
readFile(mdFile);

//Read the file with a XMLHttpRequest()
//Work only with a file server, local not working
function readFile(file)
{
  var rawFile = new XMLHttpRequest();
  rawFile.open("GET", file, true);
  rawFile.responseType = "text";
  rawFile.onreadystatechange = function ()
  {
    if(rawFile.readyState == XMLHttpRequest.DONE)
    {
      convertMDtoHTML(rawFile.responseText);
    }
  }
  rawFile.send(null);
}

function readLocalFile() {
  var file = document.getElementById('inputMdFile').files[0];
  var reader = new FileReader();
  reader.onload = function() {
    convertMDtoHTML(reader.result);
  };
  reader.readAsText(file);
};

function convertMDtoHTML(mdText) {
  s = parse(mdText);
  document.getElementById("divMD").innerHTML = s;
}


function parse(text) {
  //g :  Global replace + i : insensitive + m : multi-line
	const html = text
    //TODO : tables, adding ol/ul tags for lists 
    //AND TESTING (mainly : multi-lines syntax like paragraphs, codes, tables, lists...)
  
    //HEADERS
    .replace(/^###### (.*)$/gim, '<h6>$1</h6>')                           //Header 6 : ###### title
    .replace(/^##### (.*)$/gim, '<h5>$1</h5>')                            //Header 5 : ##### title
    .replace(/^#### (.*)$/gim, '<h4>$1</h4>')                             //Header 4 : #### title
    .replace(/^### (.*)$/gim, '<h3>$1</h3>')                              //Header 3 : ### title
		.replace(/^## (.*)$/gim, '<h2>$1</h2>')                               //Header 2 : ## title
		.replace(/^# (.*)$/gim, '<h1>$1</h1>')                                //Header 1 : # title
		.replace(/^(.+)\n===+$/gim, '<h1>$1</h1>')                            //Alternate Header 1  : title \n ===
    .replace(/^(.+)\n---+$/gim, '<h2>$1</h2>')                            //Alternate Header 2  : title \n ---
    
    //HORIZONTAL RULES
    .replace(/^---+$/gim, '<hr>')                                      //Horizontal Rule : ---
    .replace(/^\*\*\*+$/gim, '<hr>')                                   //Horizontal Rule : ***
    .replace(/^___+$/gim, '<hr>')                                      //Horizontal Rule : ___
    
    //SPECIALS
    .replace(/^\`\`\`\s?(.+)\n([^\`]+)\`\`\`$/gim, '<pre class="sourceCode $1"><code class="sourceCode $1">$2</code></pre>')                                                    //highlights : ```text```
    .replace(/\`([^\`]+)\`/gim, '<code>$1</code>')                           //`code`
    .replace(/^\s+>\s+(.+)/gim, '<blockquote>$1</blockquote>')                //blockquote : > text
    
    //PARAGRAPHS
    .replace(/^(.+)\n\n/gim, '<p>$1</p>\n\n')                            //paragraph : blank line
    .replace(/  $/gim, '<br>')                                            //Linebreak (2 spaces before endline)
    
    //EMPHASIS
    .replace(/ ___([^_]+)___ /gim, ' <em><strong>$1</strong></em> ')         //Bold+Italic : ' ___text___ ' (spaced)
    .replace(/\*\*\*([^\*]+)\*\*\*/gim, '<em><strong>$1</strong></em>')      //Bold+Italic : ***text***
		.replace(/\*\*([^\*]+)\*\*/gim, '<strong>$1</strong>')                   //Bold : **text*
    .replace(/ __([^_]+)__ /gim, ' <strong>$1</strong> ')                    //Bold : ' __text_ ' (spaced)
		.replace(/\*([^\*]+)\*/gim, '<em>$1</em>')                               //Italic : *text*
    .replace(/ _([^_]+)_ /gim, ' <em>$1</em> ')                              //Italic : ' _text_ ' (spaced)
    .replace(/~~([^~]+)~~/gim, '<s>$1</s>')                                  //Strikethrough : ~~text~~
    
    //URL + EMAIL
    .replace(/\shttp([^\s]+)\s/gim, ' <a href="http$1">http$1</a> ')         //Link : ' url ' (spaced)
    .replace(/\s([^@]+)@([^\.]+).([^\s]+)\s/gim, ' <a href="mailto:$1@$2.$3">$1@$2.$3</a> ') //Link : ' email ' (spaced)
    .replace(/<http([^>]+)>/gim, '<a href="http$1">http$1</a>')              //Link : <url>
    .replace(/<([^@]+)@([^\.]+).([^>]+)>/gim, '<a href="mailto:$1@$2.$3">$1@$2.$3</a>') //Link : <email>
    
    //IMAGES
    .replace(/!\[\]\(([^)]+)\)/gim, '<img src="$1" />')                                  //Image : ![](url)
    .replace(/!\[\]\(([^\s]+)\s"([^"]+)"\)/gim, '<img src="$1" alt="$2" />')             //Image : ![](url "AltText")
    .replace(/!\[([^\]]+)\]\(([^)]+)\)/gim,'<img src="$2" title="$1" />')                //Image : ![Title](url)
    .replace(/!\[([^\]]+)\]\(([^\s]+)\s"([^"]+)"\)/gim,'<img src="$2" title="$1" alt="$3"/>') //Image : ![Title](url "AltText")
    
    //ANCHORS
    .replace(/\[([^\]]+)\]\(#([^)]+)\)/gim, '<a name="$2">$1</a>')                       //Named Anchor [Titre](#id)
    .replace(/\[([^\]]+)\]\[([^\]]+)\]/gim, '<a name="#$2">$1</a>')                      //Footnote : [Title][id]
    .replace(/^\[([^\]]+)\]:/gim, '<a name="$1" />')                                     //Named Anchor [id]:

    //"MARKDOWN" LINKS -> "HTML" LINKS
    .replace(/\[([^\]]+)\]\(([^\.]+)\.md\s"([^"]+)"\)/gim, '<a href="$2.html" title="$3">$1</a>') //Link : [Title](url.md "text")
    .replace(/\[([^\]]+)\]\(([^\.]+)\.md\)/gim, '<a href="$2.html">$1</a>')                        //Link : [Title](url.md)
    
    //LINKS
    .replace(/\[([^\]]+)\]\(([^\s]+)\s"([^"]+)"\)/gim, '<a href="$2" title="$3">$1</a>') //Link : [Title](url "text")
    .replace(/\[([^\]]+)\]\(([^)]+)\)/gim, '<a href="$2">$1</a>')                        //Link : [Title](url)
    .replace(/\[([^\]]+)\]/gim, '<a href="#$1">$1</a>')                                  //Link : [Title+id]
    
    //TABLES 
    //TODO
    //.replace(/([^\n]+)\|/gim, '<table>|')            //table starting  
    //.replace(/\|([^\n]+)/gim, '|</table>')           //table ending  
    //.replace(/\|([^\|]+)\|/gim, '<td>$1</td>')       //table element   

    //LISTS
    //.replace(/((\n\d+\. .+)+)/gim, '<ol>$1</ol>')          //Ordered list : ('[0-9]. text')
    //.replace(/((\n(\-|\+|\*) .+)+)/gim, '<ul>$1</ul>')     //Unordered list : ('[- or + or *] text')
    .replace(/^\s+\d+\. (.+)$/gim, '<li>$1</li>')         //Ordered item : '[0-9]. text'
    .replace(/^\s+(\-|\+|\*) (.+)$/gim, '<li>$1</li>');   //Unordered item : '[- or + or *] text'
  console.log(html);
  return html;
}