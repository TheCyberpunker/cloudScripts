// https://thecyberpunker.com/ 
// test regex


const email = 'test@gmail.com' // check with test@gmail.commmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm

var validador = new RegExp("^[a-zA-Z0-9._-]{2,25}@[a-zA-Z0-9.-]{2,25}\\.[a-zA-Z]{2,25}(\\.[a-zA-Z]{2,25})?$");
        if(validador.test(email) && !email.includes("notiene") && !email.includes("NOTIENE")){
            console.log('Correo Valido')
        }
        else console.log('Correo Invalido')