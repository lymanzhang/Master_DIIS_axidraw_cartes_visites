# Cartes de visites Master DIIS promo 2021
Outil pour générer les motifs pour des cartes de visite.

### Préambule
L'outil a été écrit avec Processing qui est dans sa conception est antérieur à p5.js dont nous avons étudié les bases en cours au mois d'octobre et de novembre. Ayant déjà des algorithmes « prêt à l'emploi » pour l'export au format vectoriel, j'ai préféré développer avec pour des raisons d'efficacité.

Si la syntaxe est différente (notamment pour la déclaration *typée) de variables)*, la logique d'application reste néanmoins la même avec l'articulation autour des gestionnaires **setup()** et **draw()**, et des gestionnaires d'évènements qui captent en particulier les déplacements et les clicks souris / clavier. 

### Installation
* Télécharger [Processing 3.5.4](https://processing.org/download/)
* Utiliser le bouton *clone or download* pour télécharger le sketch. 
* En cliquant sur un des fichiers .pde, Processing devrait s'ouvrir avec le code qui est scindée en plusieurs onglets.
* Il est nécessaire d'installer deux librairies ([ControlP5](http://www.sojamo.de/libraries/controlP5/) pour la gestion d'interface graphique et une version modifiée de [Drop](http://www.sojamo.de/libraries/drop/) qui permet la gestion de glisser-déposer de fichiers dans l'application). Pour ce faire, il faut ouvrir le gestionnaire de librairies de Processing depuis le menu **Sketch > Importer une librairie ... > Ajouter une librairie ...**
* Dans **l'onglet Librairies**, vous pouvez taper ControlP5 et SDrop pour trouver les libraries et cliquer sur le bouton Install pour les installer. 

![ControlP5](images/install_controlP5_library.png)
![Drop](images/install_drop_library.png)

### Interface

