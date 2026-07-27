module.exports = function(data){

const items = [

{
name:"Início",
url:"/"
}

];

if(data.genre){

items.push({

name:data.genre,

url:"/generos/"+data.genre

});

}

if(data.title){

items.push({

name:data.title,

url:data.page.url

});

}

return items;

}