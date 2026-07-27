module.exports = {

slug(text) {

return text
.toLowerCase()
.normalize("NFD")
.replace(/[\u0300-\u036f]/g, "")
.replace(/[^\w\s-]/g, "")
.replace(/\s+/g, "-");

},

truncate(text, size = 160){

if(!text) return "";

return text.length > size
? text.slice(0,size)+"..."
: text;

}

};