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
jugador(cata,[fuego,tierra,agua,aire]). %Por concepto de universo cerrado, no se modela que cata no tiene vapor.

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
    jugador(Jugador,_),
    elemento(Elemento,_),
    forall(elementoNecesarioPara(Elemento,Necesario), poseeEnInventario(Jugador,Necesario)).

poseeEnInventario(Jugador,ElementoBuscado):-
    jugador(Jugador,Inventario),
    member(ElementoBuscado,Inventario).

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

puedeConstruir(Jugador,Elemento):-
    tieneIngredientesPara(Jugador, Elemento),
    cuentaConHerramientasNecesarias(Jugador,Elemento).

cuentaConHerramientasNecesarias(Jugador,Elemento):-
    estaVivo(Elemento),
    herramienta(Jugador,libro(vida)).

cuentaConHerramientasNecesarias(Jugador,Elemento):-
    elemento(Elemento,_), %Hago inversible este predicado. Me sirve para el punto 8
    not(estaVivo(Elemento)),
    herramienta(Jugador,libro(inerte)).

cuentaConHerramientasNecesarias(Jugador,Elemento):-
    elemento(Elemento,Ingredientes),
    length(Ingredientes,CantidadDeIngredientes),
    utensillosSoportanIngredientes(Jugador,CantidadDeIngredientes).

utensillosSoportanIngredientes(Jugador,CantidadDeIngredientes):-
    herramienta(Jugador,cuchara(Centimetros)),
    Capacidad is Centimetros / 10,
    Capacidad > CantidadDeIngredientes.

utensillosSoportanIngredientes(Jugador,CantidadDeIngredientes):-
    herramienta(Jugador,circulo(Diametro,Niveles)),
    Capacidad is (Diametro/100) * Niveles, %En la base el diametro esta en centimetros y el requerimiento de este punto me pide metros
    Capacidad > CantidadDeIngredientes.

/* Punto 5
Saber si alguien es todopoderoso, que es cuando tiene todos los elementos primitivos (los que no pueden construirse a partir de nada) 
y además cuenta con herramientas que sirven para construir cada elemento que no tenga.
Por ejemplo, cata es todopoderosa, pero beto no. */

esTodoPoderoso(Jugador):-
    tieneTodosLosElementosPrimitivos(Jugador),
    cuentaConHerramientasParaElementosFaltantes(Jugador).

tieneTodosLosElementosPrimitivos(Jugador):-
    jugador(Jugador,_),
    forall(elementoPrimitivo(Elemento),poseeEnInventario(Jugador,Elemento)).

cuentaConHerramientasParaElementosFaltantes(Jugador):-
    forall(elementoFaltante(Jugador,ElementoFaltante),cuentaConHerramientasNecesarias(Jugador,ElementoFaltante)). 
    %No necesito que sea inversible porque esTodoPoderoso ya lo es gracias al predicado anterior

elementoPrimitivo(Elemento):-
    elementosExistentes(Elementos),
    member(Elemento,Elementos),
    noSeConstruyeAPartirDeNada(Elemento).

%Obtengo "todos los elementos que existen." Cualquier otro que no esté en la base de conocimiento no existe -> Universo cerrado
elementosExistentes(Elementos):-
    jugador(_,Elementos). %Como parte del inventario
elementosExistentes(Elementos):-
    elemento(_,Elementos).%Como ingrediente de otro elemento
elementosExistentes(Elementos):-
    findall(Elemento,elemento(Elemento,_),Elementos). %Como elemento a construir 

%Con estas clausulas me ahorro problemas a futuro, ya que en caso de que se agregue el Elemento de Spinetta o cualquier otro nuevo en nuestra base de conocimiento
%(ya sea apareciendo en el inventario de un jugador, en los ingredientes de un elemento, o como un nuevo elemento a construir), podrá ser reconocido por el programa.

noSeConstruyeAPartirDeNada(Elemento):-
    not(elemento(Elemento,_)).

elementoFaltante(Jugador,Elemento):-
    elementosExistentes(Elementos),
    member(Elemento,Elementos),
    not(poseeEnInventario(Jugador,Elemento)).

/* Punto 6
Conocer quienGana, que es quien puede construir más cosas.
Por ejemplo, cata gana, pero beto no. */

quienGana(Jugador):-
    construyeMasQueRivales(Jugador).
    
construyeMasQueRivales(Jugador):-
    cantidadCosasAConstruir(Jugador,CantidadCosas),
    forall(rivales(Jugador,Jugador2),(cantidadCosasAConstruir(Jugador2,CantidadCosas2), CantidadCosas>CantidadCosas2)).

rivales(Jugador1,Jugador2):-
    jugador(Jugador1,_),
    jugador(Jugador2,_),
    Jugador1 \= Jugador2.

cantidadCosasAConstruir(Jugador,CantidadCosas):-
    jugador(Jugador,_),
    findall(Elemento,puedeConstruir(Jugador,Elemento),Elementos),
    length(Elementos,CantidadCosas).

/* Punto 7
Mencionar un lugar de la solución donde se haya hecho uso del concepto de universo cerrado.

    Concepto de universo cerrado: todo lo que no se afirme, es falso.
        Al modelar la base de conocimiento a partir de los requerimientos, por ejemplo, no afirmamos nada acerca de "cata no posee vapor". 
        Directamente no se modeló ese hecho.
        En el punto 5, cuando me referí a elementos existentes también tuve en cuenta el concepto. Solo existen los elementos que fueron modelados en la base. 
        Por ejemplo, el dinero no existe.
*/


/* Punto 8
Hacer una nueva versión del predicado puedeConstruir (se puede llamar puedeLlegarATener) para considerar todo lo que podría construir si va combinando todos los elementos 
que tiene (y siempre y cuando tenga alguna herramienta que le sirva para construir eso). 
Un jugador puede llegar a tener un elemento si o bien lo tiene, o bien tiene alguna herramienta que le sirva para hacerlo 
y cada ingrediente necesario para construirlo puede llegar a tenerlo a su vez.
Por ejemplo, cata podría llegar a tener una play station, pero beto no. */

puedeLlegarATener(Jugador,Elemento):-
    poseeEnInventario(Jugador,Elemento).

puedeLlegarATener(Jugador,Elemento):-
    cuentaConHerramientasNecesarias(Jugador,Elemento),
    forall(elementoNecesarioPara(Elemento,Necesario),puedeLlegarATener(Jugador,Necesario)).