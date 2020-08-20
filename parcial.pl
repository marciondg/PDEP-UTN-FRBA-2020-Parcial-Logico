/*
Nombre: Garozzo, Marcio
Legajo: 168061-4
*/

/* Ana tiene agua, vapor, tierra y hierro. Beto tiene lo mismo que Ana. Cata tiene fuego, tierra, agua y aire, pero no tiene vapor. 
Para construir pasto hace falta agua y tierra, para construir hierro hace falta fuego, agua y tierra, y para hacer huesos hace falta pasto y agua. 
Para hacer presión hace falta hierro y vapor (que se construye con agua y fuego).
Para hacer una play station hace falta silicio (que se construye sólo con tierra), hierro y plástico (que se construye con huesos y presión).
 */

herramienta(ana, circulo(50,3)).
herramienta(ana, cuchara(40)).
herramienta(beto, circulo(20,1)).
herramienta(beto, libro(inerte)).
herramienta(cata, libro(vida)).
herramienta(cata, circulo(100,5)).

% Los círculos alquímicos tienen diámetro en cms y cantidad de niveles.
% Las cucharas tienen una longitud en cms.
% Hay distintos tipos de libro.

%Punto 1 Modelar los jugadores y elementos y agregarlos a la base de conocimiento, utilizando los ejemplos provistos.

%jugador(Nombre,Elementos)
jugador(ana,[agua,vapor,tierra,hierro]).
jugador(beto,Elementos):-
    jugador(ana,Elementos).
jugador(cata,[fuego,tierra,agua,aire]).

%elemento(Nombre,ElementosNecesarios).
elemento(pasto,[agua,tierra]).
elemento(hierro,[fuego,agua,tierra]).
elemento(huesos,[pasto,agua]).
elemento(presion,[hierro,vapor]).
elemento(vapor,[agua,fuego]).
elemento(playStation,[silicio,hierro,plastico]).
elemento(silicio,[tierra]).
elemento(plastico,[huesos,presion]).

/* Punto 2
Saber si un jugador tieneIngredientesPara construir un elemento, que es cuando tiene en su inventario todo lo que hace falta.
Por ejemplo, ana tiene los ingredientes para el pasto, pero no para el vapor */
tieneIngredientesPara(Jugador,Elemento):-
    tieneTodoLoQueHaceFalta(Jugador,Elemento).
 
tieneTodoLoQueHaceFalta(Jugador,Elemento):-
    jugador(Jugador,Inventario),
    elemento(Elemento,_),
    forall(elementoNecesarioPara(Elemento,Necesario), member(Necesario,Inventario)).
    
elementoNecesarioPara(Elemento,Necesario):-
    elemento(Elemento,Necesarios),
    member(Necesario, Necesarios).

/* Punto 3 
Saber si un elemento estaVivo. Se sabe que el agua, el fuego y todo lo que fue construido a partir de ellos, están vivos. Debe funcionar para cualquier nivel.
Por ejemplo, la play station está viva, pero el silicio no. */
estaVivo(agua).
estaVivo(fuego).

estaVivo(Elemento):-
    elementoNecesarioPara(Elemento,Necesario),
    estaVivo(Necesario).

/* Punto 4
Conocer las personas que puedeConstruir un elemento, para lo que se necesita tener los ingredientes y además contar con una o más herramientas que sirvan para construirlo. 
Para los elementos vivos sirve el libro de la vida (y para los elementos no vivos el libro inerte). 
Además, las cucharas y círculos sirven cuando soportan la cantidad de ingredientes del elemento (las cucharas soportan tantos ingredientes como centímetros/10, 
        y los círculos alquímicos soportan tantos ingredientes como metros * cantidad de niveles).

Por ejemplo, beto puede construir el silicio (porque tiene tierra y tiene el libro inerte, que le sirve para el silicio), 
pero no puede construir la presión (porque a pesar de tener hierro y vapor, no cuenta con herramientas que le sirvan para la presión). 
Ana, por otro lado, sí puede construir silicio y presión. */
/* 
puedeConstruir(Jugador,Elemento):-
    estaVivo(Elemento),
    tieneIngredientesPara(Jugador, Elemento),
    cuentaConHerramientas(Jugador) */