Installation
==========

### Prerequisites
* Docker
* IntelliJ IDE with Kotlin support (if you want to edit the Spring project)

### Installation

simply run `docker-compose up` on the root project folder and wait for all components to be ready. Then you can use http://localhost:8080 to interract with the BBData API.

For IntelliJ, Open the project in IntelliJ and let it work. Once finished, you should be able to simply run the app by 
launching the main class `ch.derlin.bbdata.BBDataApplication` (open it and right-click > run).


Offboarding
==========

Voici une check-list pour être sûr d'avoir tout déposé sur Gitlab avant la fin de votre projet. Si tout est coché, ça devrait être ok.

- [ ] Le fichier `README.md` contient toutes les explications nécessaire pour l'installation et le lancement de mon code
- [ ] Les PVs de toutes les séances se trouvent sur Teams
- [ ] Le cachier des charges se trouve sur Teams
- [ ] Les slides de la présentation du cahier des charges se trouve sur Teams
- [ ] Le rapport final se trouve sur Teams
- [ ] Les slides de la présentation finale du projet se trouvent sur Teams
- [ ] Une vidéo de démonstration de votre projet a été montée, envoyée à votre superviseur, et uploadée sur la [chaine Youtube de l'institut HumanTech](https://www.youtube.com/user/MISGchannel)
- [ ] J'ai complété la [fiche d'évaluation](docs/supervision-evaluation.md) de mon superviseur afin de l'aider à s'améliorer
- [ ] J'ai organisé un apéro de départ (optionnel, dépend de votre superviseur) ;)


--------------------------------------------------------------------------
K8S-BBDATA - Kubernetization of a streaming data processing platform
==========

Projet de semestre 5 - 2021/2022
---------------

- **Etudiant** : [Cédric Mujynya](https://github.com/bukibarak) - cedric.mujynya@edu.hefr.ch
- **Professeur** : [Jean Hennebert](https://github.com/henneber) - jean.hennebert@hefr.ch
- **Assistant** : [Frédéric Montet](https://github.com/fredmontet) - frederic.montet@hefr.ch
- **Assistant** : [Jonathan Rial](https://github.com/JRial95) - jonathan.rial@hefr.ch
- **Dates** : du 27.09.2021 au 09.02.2022


Contexte
--------

Le projet [BBDATA](https://icosys.ch/bbdata) est un projet développé par la HEIA-FR pour stocker des mesures de capteurs de smart buildings. En fin d'année 2019, la plateforme BBDATA à été revisitée par [Lucy Linder](https://github.com/derlin) dans [une version 2.0](https://github.com/big-building-data) utilisant les dernières technologies disponibles. 

BBDATA gère aujourd'hui plus de 2000 capteurs situés dans le batiment Blue-Factory, mais il est également utilisé dans plusieurs projets au seins de l'école.

Description
-----------

L'objectif du projet de semestre est de proposer un déployement flexible de l'API BBDATA au moyens de [Docker](https://www.docker.com/) et de [Kubernetes](https://kubernetes.io/fr/). Actuellement, une partie des composants ont déjà étés dockerisés afin de fonctionner sur une même machine, mais ne sont pas facilement configurable. 
Dans un premier temps, l'objectif sera donc de dockeriser l'intégralité des composants tout en gardant une communication entres les différents containers. Dans un second temps, l'objectif sera d'utiliser les _"opérateurs"_ de Kubernetes afin d'avoir un unique fichier de configuration pour tous les containers.

Enfin, si le temps le permet, un dernier objectif sera de déployer l'environnement BBDATA-API à la fois sur une architecture _on-perm_ (environnement HEIA) et _cloud_ (type Azure) et de regarder si l'on constate une différence significative de performance, de latence, etc.


Contenu
-------

Ce dépôt contient toute la documentation relative au projet dans le dossier [`docs/`](./docs/). Le code du projet est dans le dossier [`code/`](./code/).