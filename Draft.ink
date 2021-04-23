+ [Entrer dans l'antichambre]
    -> Meuble

LIST seen_state = unknown, indistinct, seen, studied

VAR know_objects = (indistinct)
VAR know_secretaire = (seen)
VAR know_snowball = (unknown)
VAR know_parchemin = (unknown)

LIST tiroir_states = (tiroir_unknown), tiroir_seen, tiroir_locked, tiroir_unlocked, tiroir_open
LIST position_snowball = (stable), near_edge, fallen
LIST position_secretaire = (one), two, three, reveal_key
LIST have_key = (no_key), yes_key

=== Meuble
{know_secretaire ^ studied: Le|Un} <:secretaire>secrétaire</> <>
{know_secretaire ^ studied: a <:tiroir>un tiroir{tiroir_states ^ tiroir_open:  \ ouvert}</>. Il}
<> est face à <:me>vous</>.
{know_objects ^ seen:
    Des babioles sans importances{position_snowball hasnt fallen: et une <:snowball>boule à neige</> {position_snowball ^near_edge: sur le point de vaciller}}
  - else:
    Quelques <:indistinct_objects>objets</> 
}<> sont posés dessus.
{know_parchemin  >= seen && tiroir_states ^ tiroir_open: Le tiroir contient un <:parchemin>parchemin</>}
{position_snowball has fallen: {know_snowball > unknown: La|Une} <:snowball>boule à neige</> gît, brisée, au sol.}
{position_secretaire has reveal_key && position_snowball has fallen && have_key == no_key: Une <:goldkey>petite clé</> brille au sol.} 

{came_from(->select_snowball): <-actions_snowball(-> Meuble)}
{came_from(->select_tiroir): <-actions_tiroir(-> Meuble)}
{came_from(->select_secretaire): <-actions_secretaire(-> Meuble)}
{came_from(->select_goldkey): <-actions_goldkey(-> Meuble)}
{came_from(->select_parchemin): <-actions_parchemin(-> Meuble)}

 * [envchoice: me]
        Chic comme à votre habitude. #didascalie
        -> Meuble
 + (select_secretaire) [envchoice: secretaire]
        ~ know_secretaire += studied
        ~ tiroir_states = (tiroir_seen)
        -> Meuble
 + [envchoice: indistinct_objects]
        ~ know_objects += seen
        ~ know_snowball += 1
        -> Meuble
 + (select_snowball)[envchoice: snowball]
        -> Meuble
 + (select_goldkey)[envchoice: goldkey]
        -> Meuble
 + (select_tiroir)[envchoice: tiroir]
        -> Meuble
 + (select_parchemin)[envchoice: parchemin]
        -> Meuble
* {know_parchemin ^studied} [Dire « ါ့ကိုပို့ပေးပါ »]
    - Vous voilà téléporté à l'autre bout du monde ! Bravo !
        -> END
    
=== actions_snowball(-> then)
    + [actchoice: Regarder]
        {position_snowball==fallen:
            ->unshaken->
            La boule est irréparable. #didascalie
        -else: 
            ~ temp shaken_last = TURNS_SINCE(-> shaken_snowball)
            {shaken_last >=0 && shaken_last < 3: ->full_tempest->}
            { shaken_last >= 3 && shaken_last <= 5: ->dissipating_tempest->} 
            { shaken_last > 5: ->seen_key->} 
            { shaken_last == -1: ->unshaken->}
        }
        -> then
    + (shaken_snowball){position_snowball!=fallen}[actchoice: Secouer]
        Vous secouez l'objet #didascalie
        -> then
    + {position_snowball!=fallen}[actchoice: Jeter au sol]
        {not seen_key: -> stupid_throw ->}
        {seen_key: -> informed_throw ->} 
        -> then
        
    = full_tempest
        Vous ne voyez rien tant la tempête de neige fait rage dans la boule. #didascalie
        ->->
    = dissipating_tempest
        La tempête a l'air de se dissiper peu à peu. Attendons encore un peu. #didascalie
        ->->
    = seen_key
        Vous distinguez une petite clé emprisonnée dans la boule. #didascalie
        ->->
    = unshaken
        Un petit personnage affreux sur un traineau stylisé. #didascalie
        ->->
    = stupid_throw
        Vous n'avez aucune raison de faire ça ! #didascalie
        ->->
    = informed_throw
        Vous jetez la boule sur le sol qui se brise avec fracas. {seen_key: Vous voyez la petite clé voler}{position_secretaire < reveal_key: sous le secrétaire}. #didascalie
            ~ position_snowball = fallen
        ->->
        

    
=== actions_tiroir(->then)
    + [actchoice: Examiner]
        {tiroir_states:
            - tiroir_open:
                Vous fouillez le tiroir. #didascalie
                {know_parchemin < seen: 
                        Vous y découvrez un parchemin. #didascalie
                        ~ know_parchemin = seen
                    - else :
                        Vous n'y trouvez rien de nouveau. #didascalie
                }
            - tiroir_unlocked: 
                Le tiroir est déverouillé, peut-être faudrait-il l'ouvrir pour découvrir ce qu'il contient ? #didascalie
            - tiroir_locked: 
                Le tiroir est toujours fermé à clé. #didascalie
            - else: 
                Le tiroir a une serrure, peut-être faudrait-il tenter de l'ouvrir ? #didascalie
                ~ tiroir_states = (tiroir_seen)
        }
        -> then
    + {have_key == no_key}[actchoice: Ouvrir]
        {tiroir_states:
            - tiroir_seen: 
                Vous tentez d'ouvrir le tiroir mais il a l'air verrouillé. #didascalie
                ~ tiroir_states = (tiroir_locked)
            - tiroir_locked:
                Pas la peine d'essayer encore une fois, vous savez bien qu'il est verrouillé. #didascalie
            - tiroir_unlocked:
                Vous ouvrez le tiroir. #didascalie
                ~ tiroir_states = (tiroir_open)
                ~ know_parchemin = (indistinct)
            - tiroir_open:
                Le tiroir est déjà ouvert. #didascalie
            - else:
                Quel tiroir ? #didascalie
        }
        -> then
    + {have_key == yes_key}[actchoice: Ouvrir]
        {tiroir_states:
            - tiroir_open:
                Le tiroir est déjà ouvert. #didascalie
            - tiroir_seen:
                Vous devriez essayer de déverrouiller le tiroir d'abord. #didascalie
            - tiroir_locked:
                Vous devriez essayer de déverrouiller le tiroir d'abord. #didascalie
            - tiroir_locked:
                Vous devriez essayer de déverrouiller le tiroir d'abord. #didascalie
            -else: Vous ouvrez le tiroir. #didascalie
                ~ tiroir_states = (tiroir_open)
                ~ know_parchemin = (indistinct)
        }
        ->then
    + {have_key == yes_key}[actchoice: Déverouiller]
        {tiroir_states:
            - tiroir_open:
                Le tiroir est non seulement déverrouillé mais vous voyez bien qu'il est ouvert ! #didascalie
            - tiroir_locked:
                Vous déverouillez le tiroir avec la petite clé. #didascalie
                ~ tiroir_states = (tiroir_unlocked)
            - tiroir_unlocked:
                Le tiroir est déjà déverouillé. #didascalie
            - else:
                Vous déverouillez le tiroir avec la petite clé. #didascalie
                ~ tiroir_states = (tiroir_unlocked)
        }
        -> then

=== actions_secretaire(->then)
    + [actchoice: Pousser] Vous bougez le secrétaire #didascalie
        ~ position_secretaire = max(position_secretaire+1, LIST_MAX(position_secretaire))
        {position_snowball ^ fallen: -> Meuble}
        ~ position_snowball = max(position_snowball+1, LIST_MAX(position_snowball))
        {position_snowball ^ fallen: 
            {know_snowball > unknown: La|Une} boule à neige tombe au sol et se brise avec fracas. {actions_snowball.seen_key: Vous voyez la petite clé voler}. #didascalie
        }
        -> Meuble
    + [actchoice: Regarder dessous]
        {position_snowball hasnt fallen or have_key == yes_key or position_secretaire >= reveal_key :
            Rien qu'un paisible troupeau de moutons de poussière. #didascalie
            - else: 
            Vous voyez une petite clé mais vous ne pouvez pas l'atteindre. #didascalie
        }
        -> Meuble

=== actions_parchemin(->then)
    + [actchoice: Lire] 
        - Vous déchiffrez le parchemin #didascalie
        - Une formule magique y est inscrite #didascalie
        ~ know_parchemin = studied
        -> Meuble

=== actions_goldkey(-> then)
    + {have_key == no_key}[actchoice: Prendre]
        Vous prenez la clé #didascalie
        ~ have_key = (yes_key)
    -> then

=== function came_from(-> x) 
    ~ return TURNS_SINCE(x) == 0

=== function max(a,b) ===
	{ a < b:
		~ return b
	- else:
		~ return a
	}


