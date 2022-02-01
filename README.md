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
Dans un premier temps, l'objectif sera donc de dockeriser l'intégralité des composants tout en gardant une communication entres les différents containers. Dans un second temps, l'objectif sera d'utiliser les _"opérateurs"_ de Kubernetes afin d'avoir un unique fichier de configuration pour tout les containers.

Enfin, si le temps le permet, un dernier objectif sera de déployer l'environnement BBDATA-API à la fois sur une architecture _on-perm_ (environnement HEIA) et _cloud_ (type Azure) et de regarder si l'on constate une différence significative de performance, de latence, etc.


Contenu
-------

Ce dépôt contient tout le code du projet nécessaire au déploiement de BBData dans les différents environnements. Il contient également les outils utilisés pour la validation et les tests de charges du projet. Pour chaque environnement, un fichier README avec les indications expliquant le déploiement de l'application est disponible.

Le dossier [docker](./docker) contient tout le code nécessaire au déploiement de BBData dans un environnement Docker.

Le dossier [kubernetes](./kubernetes) contient tout le code nécessaire au déploiement de BBData dans un environnement Kubernetes.

Le dossier [other](./other) contient le code des applications qui n'ont pas étés migrées dans un environnement Docker ou Kubenetes, mais qui ont tout de même étées utilisées durant le projet.