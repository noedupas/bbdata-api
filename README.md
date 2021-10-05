Suivi du projet
==========

Premier jour
------------

- [X] Télécharger ce template, créer un nouveau dépôt Git pour votre projet (p.ex. "tb-super-website"), et pusher le tout sur Gitlab (info: si vous avez un compte "externe", vous n'avez pas les permissions nécessaires pour créer un dépôt, dans ce cas c'est votre superviseur qui le fera à votre place).
- [X] Editer ce README et supprimer la première partie (cocher ces deux premières étapes en mettant un "x" entre les crochets, comme ça: [x])
- [X] Faire une séance d'introduction avec votre superviseur
- [X] Remplir les méta-données du projet ci-dessous (Voir [Nom du projet](#nom-du-projet))
- [X] Donner les accès à mon dépôt Gitlab à mon/mes superviseur/s (dans le panneau à gauche `Settings/Members`)


**Ressources :** Si vous n'êtes pas à l'aise avec Git, Docker ou d'autres outils, des tutoriels se trouvent sur le dépôt [jacky.casas/basic-tutorials](https://gitlab.forge.hefr.ch/jacky.casas/basic-tutorials), jettez-y un oeil.


Première semaine
----------------

- [X] Installer les logiciels requis sur votre ordinateur
- [ ] Prendre en main les différentes technologies liées au projet
- [ ] Rédiger le **cahier des charges** du projet (template disponible [ici](/docs/templates/CahierDesCharges-Template.docx))
- [X] Prévoir une séance hebdomadaire avec votre superviseur. Après chaque séance, vous devrez **rédiger un PV** et le mettre dans le dépôt du projet `/docs/PVs/`. Un [template LaTeX](/docs/PVs/template/pv.tex) et un [template Word](/docs/PVs/template/PV-Template.docx) se trouvent dans le même dossier)
- [X] Mettre son code dans le dossier `code/` et renseigner dans le fichier `code/README.md` la façon d'installer et de lancer votre code (tout doit y figurer pour qu'une personne lambda puisse installer votre logiciel depuis zéro)

Une séance de présentation du cahier des charges sera organisée aux environs de la 2e semaine par votre superviseur (encore une fois, un [template](/docs/templates/Presentation-Template.pptx) existe).

Une présentation finale sera également organisée en temps voulu.

Voilà, vous êtes "onboardés" ! :)

--------------------------------------------------------------------------
Offboarding
===========

Voici une check-list pour être sûr d'avoir tout déposé sur Gitlab avant la fin de votre projet. Si tout est coché, ça devrait être ok.

- [ ] Tout le code se trouve dans le dossier `code/`
- [ ] Le fichier `code/README.md` contient toutes les explications nécessaire pour l'installation et le lancement de mon code
- [ ] Les PVs de toutes les séances se trouvent dans le dossier `docs/PVs/`
- [ ] Le cachier des charges se trouve dans le dossier `docs/`
- [ ] Les slides de la présentation du cahier des charges se trouve dans le dossier `docs/`
- [ ] Le rapport final se trouve dans le dossier `docs/`
- [ ] Les slides de la présentation finale du projet se trouvent dans le dossier `docs/`
- [ ] Une vidéo de démonstration de votre projet a été montée, envoyée à votre superviseur, et uploadée sur la [chaine Youtube de l'institut HumanTech](https://www.youtube.com/user/MISGchannel)
- [ ] J'ai complété la [fiche d'évaluation](docs/supervision-evaluation.md) de mon superviseur afin de l'aider à s'améliorer
- [ ] J'ai organisé un apéro de départ (optionnel, dépend de votre superviseur) ;)


--------------------------------------------------------------------------
K8S-BBDATA - Kubernetization of a streaming data processing platform
=============

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