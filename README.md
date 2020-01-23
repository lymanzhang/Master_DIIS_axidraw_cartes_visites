# Cartes de visites Master DIIS promo 2021
Outil pour générer les motifs pour des cartes de visite.

![Outil](images/interface.png)


### Préambule
L'outil a été écrit avec Processing qui est dans sa conception est antérieur à p5.js dont nous avons étudié les bases en cours au mois d'octobre et de novembre. Ayant déjà des algorithmes « prêt à l'emploi » pour l'export au format vectoriel, j'ai préféré développer avec pour des raisons d'efficacité.

Si la syntaxe est différente (notamment pour la déclaration *typée) de variables)*, la logique d'application reste néanmoins la même avec l'articulation autour des gestionnaires **setup()** et **draw()**, et des gestionnaires d'évènements qui captent en particulier les déplacements et les clicks souris / clavier. 

### Installation
* Télécharger [Processing 3.5.4](https://processing.org/download/)
* Utiliser le bouton *clone or download* pour télécharger le sketch. 
* En cliquant sur un des fichiers .pde, Processing devrait s'ouvrir avec le code qui est scindée en plusieurs onglets.
* Il est nécessaire d'installer deux librairies ([ControlP5](http://www.sojamo.de/libraries/controlP5/) pour la gestion d'interface graphique et une version modifiée de [Drop](http://www.sojamo.de/libraries/drop/) qui permet la gestion de glisser-déposer de fichiers dans l'application). Pour ce faire, il faut ouvrir le gestionnaire de librairies de Processing depuis le menu **Sketch > Importer une librairie ... > Ajouter une librairie ...**
* Dans **l'onglet Librairies**, vous pouvez taper ControlP5 et SDrop pour trouver les libraries et cliquer sur le bouton Install pour les installer. 

<img src="images/install_controlP5_library.png" width="450px" />
<img src="images/install_drop_library.png" width="450px" />

### Outil
L'outil dispose de deux modes : 
* **un mode d'édition** qui permet de modifier les points / compétences de chaque carte.
* **un mode simulation / courbe** qui permet de visualiser différents types de courbes reliant les points. Il y a trois types de courbes : 
  * **mode boids** qui « lance » [un agent autonome](https://fr.wikipedia.org/wiki/Boids) qui va aller de point en point avec une certaine vitesse / accélération , produisant un rendu avec des boucles.
  * **mode lignes**, chaque point est relié au suivant avec un segment simple.
  * **mode lignes 2**, chaque point est relié au suivant avec un segment simple ou une courbe de [Bézier](https://processing.org/reference/bezier_.html).

#### Menu


#### Export / Sauvegarde
