# L'Énigme — Fiche Technique

## 1. Structure du Projet

```
01-enigme/
├── backend/              # API de gestion
│   ├── server.js         # Serveur Express.js
│   ├── package.json      # Dépendances
│   └── db.json           # Base de données simulée
├── web/                  # Frontend
│   └── index.html        # Application React (Babel standalone)
├── mobile/               # Application mobile
│   └── lib/main.dart     # App Flutter
└── docs/                 # Documentation
```

## 2. Spécifications Fonctionnelles

### 2.1 Backend — API REST

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| /api/health | GET | Vérification de l'état du service |
| /api/stats | GET | Statistiques (produits, commandes, CA) |
| /api/products | GET | Liste des produits |
| /api/products/:id | GET | Détail d'un produit |
| /api/orders | GET | Liste des commandes |
| /api/orders | POST | Création d'une commande |
| /api/orders/:id | GET | Détail d'une commande |
| /api/categories | GET | Liste des catégories |

### 2.2 Web — Fonctionnalités

**Catalogue**
- Grille de produits avec filtres (catégorie, prix, note)
- Fiches produits détaillées (photos, description, avis)
- Panier d'achat avec gestion des quantités
- Processus de commande en 2 étapes

**Commande**
- Formulaire de livraison anonyme
- Choix du mode de livraison (standard, express, Click & Collect)
- Récapitulatif avant validation
- Suivi de commande

**Espace Client**
- Historique des commandes
- Statut des commandes
- Gestion du profil

### 2.3 Mobile — Fonctionnalités

- Navigation bottom bar (Accueil, Catalogue, Panier, Profil)
- Catalogue produits avec recherche
- Panier modal
- Checkout formulaire
- Notifications push (commandes, promotions)

## 3. Exigences Non-Fonctionnelles

| Exigence | Spécification |
|----------|---------------|
| Performance | Temps de réponse API < 200ms |
| Disponibilité | 99.5% uptime |
| Sécurité | HTTPS, validation des entrées, protection CSRF |
| Compatibilité | iOS 12+, Android 8+, Chrome, Firefox, Safari |
| Accessibilité | WCAG 2.1 AA |

## 4. Données Simulées

### Produits (8 produits)
- Bougie Massage Premium — 15 000 XAF
- Huile de Massage Bio — 12 000 XAF
- Kit Découverte Intimité — 25 000 XAF
- Vibrateur Silencieux — 35 000 XAF
- Lingerie Premium — 20 000 XAF
- Jeu de Rôle Couple — 18 000 XAF
- Accessoire Massage — 22 000 XAF
- Coffret Cadeau — 45 000 XAF

### Commandes (simulées)
- 15 commandes avec statuts variés
- CA total : 69 500 XAF
- Panier moyen : 23 167 XAF

## 5. Planning de Développement

| Phase | Durée | Livrables |
|-------|-------|-----------|
| Phase 1 — MVP | 4 semaines | Backend + Web basique |
| Phase 2 — Mobile | 3 semaines | App Flutter |
| Phase 3 — Features | 3 semaines | Click & Collect, fidélité |
| Phase 4 — Lancement | 2 semaines | Tests, déploiement |

## 6. Équipe Nécessaire

| Rôle | Nombre | Responsabilités |
|------|--------|-----------------|
| Chef de projet | 1 | Coordination, planning |
| Développeur Backend | 1 | API, base de données |
| Développeur Frontend | 1 | Web, UI/UX |
| Développeur Mobile | 1 | App Flutter |
| Designer | 1 | Maquettes, identité visuelle |

## 7. Risques et Mitigations

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Retard livraison | Moyenne | Élevé | Planning tampon, fournisseurs de secours |
| Problèmes paiement | Faible | Élevé | Intégration Mobile Money, support 24/7 |
| Concurrence | Moyenne | Moyen | Différenciation par la qualité et le service |
| Réglementation | Faible | Élevé | Veille juridique, conformité |

## 8. Budget Détaillé

| Poste | Coût (XAF) | Détail |
|-------|-----------|--------|
| Développement backend | 500 000 | API, base de données |
| Développement web | 400 000 | Frontend React |
| Développement mobile | 400 000 | App Flutter |
| Design | 200 000 | Maquettes, UI/UX |
| Stock initial | 2 000 000 | Produits, emballages |
| Marketing | 1 000 000 | Réseaux sociaux, influenceurs |
| Logistique | 500 000 | Livraison, points relais |
| **Total** | **5 000 000** | |

## 9. KPIs de Suivi

| KPI | Objectif | Fréquence |
|-----|----------|-----------|
| Taux de conversion | 3%+ | Hebdomadaire |
| Panier moyen | 25 000 XAF | Hebdomadaire |
| Taux de rétention | 30%+ | Mensuel |
| NPS | 50+ | Mensuel |
| CA mensuel | 2 000 000+ XAF | Mensuel |
