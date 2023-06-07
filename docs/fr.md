## Syntaxes particulières

### Actionscalies

Le tag `#actionscalie` est utilisé pour déclarer le texte correspondant aux actions du joueur qui changent l'environnement. Il n'est pas persisté au moment du jeu. Ce texte d'action est toujours affiché _au-dessus_ du texte principal.

### Didascalies

Le tag `#didascalie` est utilisé pour déclarer le texte correspondant aux actions du joueur. Il n'est pas persisté au moment du jeu. Ce texte d'action est toujours affiché _sous_ le texte principal.

### Marqueur d'environnement

Les mots des textes persistants peuvent être entouré d'un tag `<:slug_objet>Mon objet</>`. Si un choix correspondant est disponible, le lien y sera automatiquement associé.

### Types de choix

#### envchoice

Un choix écrit comme suit :
```
+ [envchoice: slug_objet]
```
sera automatiquement associé à tous les tags `<:slug_objet>` présent dans le texte persistant.

#### actchoice

Un choix écrit comme suit :

```
+ [actchoice: Regarder]
```
correspond à une action et pourra être présenté de manière différente (en l'état, il n'y a pas de distinction visuelle avec les choix classiques)

## player

Le player javascript a été complètement réécrit et se découpe en un processus à 4 étapes

1. récupérer tous les paragraphes et tous les choix
2. catégoriser les textes persistants, les didascalies, les choix environnementaux et les choix d'action
3. associer les choix à leurs tags respectifs (les choix qui n'ont pas de tag ne sont pas affichés, les tags qui n'ont pas de choix sont affichés dans lien hypertexte)
4. afficher tout ça

N'est conservée que la base de la boucle ink (`canContinue` etc.)
