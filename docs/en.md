## Specific syntax

### Actionscalies

The `#actionscalie` tag is used to declare text corresponding to player actions that change the environment. This text is not persisted during game. This action text is always displayed _above_ the main text.

### Didascalies

The `#didascalie` tag is used to declare text that narrate player actions. This text is not persisted during game. This action text is always displayed _below_ the main text.

### Environment marker

The words of the persisting text can be marked with a tag of the form `<:slug_objet>Mon objet</>`. If a choice matches the tag/slug, a link will be associated to it.

### Choice types

#### envchoice

A choice writtent like that :
```
+ [envchoice: slug_objet]
```
will automatically be associated to all the tags of the form `<:slug_objet>` present in the persisting text.

#### actchoice

A choice writtent like that :

```
+ [actchoice: Regarder]
```
corresponds to a possible action by the player and can be styled differently. As of now, they are just displayed below the main text, like classical choices in ink.

## player

The javascript player is rewritten and behaves following 4 steps :

1. retrieve all paragraphs and all choices
2. categorise the paragraphs into the "persisting", "didascalies" and "actionscalies", and choices between "environmental" and "action"
3. match choices to their tag (choices that don't have tags are not displayed. Tags that do no have choices are displayed as plain text)
4. display all this

Only the main ink loop (`canContinue` etc.) is preserved.
