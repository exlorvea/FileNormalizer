# FileNormalizer

**FileNormalizer** est un script PowerShell permettant de normaliser automatiquement les noms de fichiers afin d'améliorer leur compatibilité entre Windows, Linux, macOS et les environnements web.

Il fonctionne sans dépendance externe, avec Windows PowerShell 5.1 et PowerShell 7.

## Fonctionnalités

- Suppression des accents et translittération de certains caractères.
- Conversion des noms en minuscules (`snake_case`).
- Remplacement des espaces, `%20` et `+` par des underscores (`_`).
- Conservation des tirets simples (`-`).
- Nettoyage des caractères spéciaux.
- Réduction des séparateurs répétés.
- Prévention des collisions avec suffixes `_001`, `_002`, etc.
- Protection contre les noms réservés de Windows.
- Prévisualisation avant modification.
- Traitement récursif facultatif des sous-dossiers.
- Journal CSV des renommages effectués.

## Exemples

| Avant | Après |
|---|---|
| `Mon Super Fichier.JPG` | `mon_super_fichier.jpg` |
| `P13-01.PNG` | `p13-01.png` |
| `Photo%20de+Vacances.jpg` | `photo_de_vacances.jpg` |
| `Été 2026.pdf` | `ete_2026.pdf` |
| `Mon---Fichier.png` | `mon-fichier.png` |
| `Rapport (Final).PDF` | `rapport_final.pdf` |
| `CON.txt` | `_con.txt` |

## Installation

1. Télécharger `FileNormalizer.ps1`.
2. Enregistrer le script dans le dossier de votre choix.
3. Ouvrir PowerShell.

Aucun logiciel supplémentaire n'est nécessaire.

Si l'exécution des scripts est bloquée, il est possible de l'autoriser temporairement pour la session PowerShell actuelle :

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Cette commande n'affecte pas la politique d'exécution permanente du système. Elle doit uniquement être utilisée pour des scripts dont le contenu a été vérifié.

## Utilisation

### Prévisualiser les modifications

```powershell
.\FileNormalizer.ps1 -Path "C:\MesFichiers"
```

Cette commande affiche les renommages prévus sans modifier les fichiers.

### Appliquer les modifications

```powershell
.\FileNormalizer.ps1 -Path "C:\MesFichiers" -Apply
```

### Traiter les sous-dossiers

```powershell
.\FileNormalizer.ps1 -Path "C:\MesFichiers" -Recurse -Apply
```

Les fichiers contenus dans les sous-dossiers seront traités, mais les dossiers eux-mêmes ne seront pas renommés.

## Paramètres

| Paramètre | Description |
|---|---|
| `-Path` | Dossier à traiter. Par défaut : dossier courant. |
| `-Recurse` | Inclut les fichiers des sous-dossiers. |
| `-Apply` | Applique les renommages. Sans ce paramètre, seul un aperçu est affiché. |

## Sécurité

FileNormalizer ne supprime pas volontairement de fichiers et ne modifie pas leur contenu.

Les renommages ne sont appliqués qu'avec le paramètre `-Apply`.

Les collisions sont traitées par l'ajout de suffixes numériques. Un journal CSV est généré dans le dossier temporaire de Windows lors des modifications.

**Il est recommandé de tester le script sur une copie de ses fichiers avant toute utilisation importante.**

## Limitations

- Les dossiers ne sont pas renommés.
- Les extensions sont normalisées en minuscules, sans conversion du format réel.
- La translittération de certains alphabets non latins n'est pas prise en charge.
- Le journal CSV ne constitue pas un mécanisme automatique d'annulation.
- Certains cas particuliers de collisions et de longueur de chemin peuvent nécessiter une intervention manuelle.

## Compatibilité

- Windows PowerShell 5.1
- PowerShell 7
- Windows 10 et 11

Les noms produits visent une bonne compatibilité avec les systèmes Linux, macOS et les serveurs web.

## Version

**1.2.0**

- Conservation des tirets simples.
- Normalisation des tirets multiples.
- Nettoyage des noms en minuscules.
- Prévisualisation et journalisation des modifications.

## Licence

Licence à définir avant publication.