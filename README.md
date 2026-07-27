# ScanDesk

Application Flutter de gestion d'inventaire par scan de QR code : chaque
matériel (ordinateur, projecteur, outil...) est identifié par un QR code
imprimable, ce qui permet de retrouver instantanément sa fiche, de changer
son état ou de l'emprunter simplement en le scannant.

## Fonctionnalités

- **Inventaire** : ajout, modification, suppression du matériel, avec un état
  (Disponible / Maintenance / Perdu / Emprunté) et une recherche/filtre par état.
- **QR codes** : génération d'un QR code par article et export en PDF prêt à
  imprimer et coller sur le matériel.
- **Scan** : la caméra lit le QR code et affiche directement la fiche de
  l'article, avec des actions contextuelles selon son état (emprunter,
  retourner, changer l'état, supprimer).
- **Emprunts** : association d'un matériel à une personne, avec date
  d'emprunt et date de retour prévue, et alerte visuelle quand un emprunt est
  en retard.
- **Personnes** : gestion des emprunteurs (ajout, suppression).
- **Tableau de bord** : vue d'ensemble (totaux par état, emprunts en retard,
  derniers articles ajoutés).
- **Stockage hors ligne + synchronisation cloud** : les données sont
  d'abord écrites en local (SQLite) puis synchronisées vers Firebase
  Firestore ; en cas d'échec (pas de réseau), l'écriture est mise en file
  d'attente locale et rejouée automatiquement au retour de la connexion.

## Stack technique

- [Flutter](https://flutter.dev) / Dart
- [Riverpod](https://riverpod.dev) pour la gestion d'état
- `sqflite` pour la base de données locale
- `firebase_core` / `cloud_firestore` pour la synchronisation cloud
- `mobile_scanner` pour la lecture des QR codes
- `qr_flutter` / `pdf` / `printing` pour la génération et l'export des QR codes

## Structure du projet

```
lib/
├── DAO/          Accès aux données (SQLite local + Firestore)
├── model/        Modèles métier (Inventaire, Personne, Emprunt)
├── service/      Synchronisation (pull Firestore, file d'attente hors ligne)
├── view/         Écrans et widgets (dashboard, listes, scan, emprunts...)
└── viewModel/    Notifiers Riverpod reliant les vues aux DAO
```

## Démarrage

```bash
flutter pub get
flutter run
```

Le projet est relié à un projet Firebase (`firebase_options.dart`,
`firestore.rules`). Pour que la synchronisation fonctionne, une base
Firestore doit être créée sur ce projet Firebase et les règles déployées :

```bash
firebase deploy --only firestore:rules
```

Sans Firebase configuré et joignable, l'application reste pleinement
fonctionnelle en local (SQLite uniquement).
