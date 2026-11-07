# StageMap — Guide de déploiement (2 étapes, 5 min)

## Étape 1 : Créer un OAuth Client ID Google (2 min)

1. Va sur https://console.cloud.google.com/apis/credentials
2. Si tu n'as pas de projet : clique "Créer un projet" → nomme-le `stagemap` → créer
3. Active l'API Gmail : menu ≡ → "APIs & Services" → "Library" → cherche "Gmail API" → clique → "Enable"
4. Menu ≡ → "APIs & Services" → "OAuth consent screen"
   - User Type : **External** → Create
   - App name : `StageMap`
   - User support email : ton mail
   - Developer contact : ton mail
   - Save and continue → Scopes → Save and continue → Test users : ajoute **ton mail Gmail** → Save and continue
5. Menu ≡ → "APIs & Services" → "Credentials" → "+ Create credentials" → "OAuth client ID"
   - Application type : **Web application**
   - Name : `StageMap Web`
   - **Authorized JavaScript origins** : ajoute d'abord `http://localhost:8000` (pour tester en local), puis plus tard ton URL Vercel (ex : `https://stagemap.vercel.app`)
   - Create
6. Copie le **Client ID** (format : `xxxx-xxxx.apps.googleusercontent.com`)
7. Dans `index.html`, cherche la ligne :
   ```js
   const GOOGLE_CLIENT_ID = window.STAGEMAP_CLIENT_ID || "REMPLACE_PAR_TON_CLIENT_ID.apps.googleusercontent.com";
   ```
   Remplace `REMPLACE_PAR_TON_CLIENT_ID.apps.googleusercontent.com` par ton Client ID.

## Étape 2 : Déployer sur Vercel (1 min, sans Git)

1. Va sur https://vercel.com/new
2. Si pas de compte : sign-up avec ton mail Google
3. En bas de la page tu as "Deploy a template" — ignore
4. Plus simple encore : va sur https://vercel.com/new/clone
5. OU utilise **la méthode drag & drop** :
   - Installe le CLI : https://vercel.com/download (il existe aussi un installer Windows)
   - OU uploade via https://vercel.com/new → "Import" → scroll jusqu'à "Deploy without Git" (si visible)

**Alternative encore plus simple — Netlify Drop (0 compte requis pour tester) :**
1. Va sur https://app.netlify.com/drop
2. Drag & drop le dossier `stagemap/` entier
3. Tu récupères une URL style `random-name.netlify.app` instantanément
4. Retourne dans Google Cloud (étape 1.5) et ajoute cette URL aux "Authorized JavaScript origins"
5. Recharge ton site Netlify → le login Google marche

## Test en local (recommandé avant de déployer)

Dans le dossier `stagemap/`, lance (PowerShell) :
```powershell
python -m http.server 8000
```
Puis ouvre http://localhost:8000. Le site est fonctionnel, tu peux déjà :
- Te connecter avec Gmail
- Parcourir les entreprises
- Envoyer un vrai mail à une entreprise depuis ton Gmail
- Voir les réponses (le site poll ton Gmail toutes les 60s et filtre les mails des entreprises contactées)

## À propos des 2000 entreprises

Le fichier contient **~80 entreprises FR réelles** avec leurs adresses recrutement publiques. Pour atteindre 2000, il faut une base de données sourcée (scraping de pages carrières, LinkedIn, APEC…) — je n'invente jamais d'adresses mail.

**Pour en ajouter** : ouvre `index.html`, trouve `const COMPANIES = [`, ajoute des entrées au format :
```js
{n:"Nom entreprise", m:"recrutement@entreprise.com", c:"Secteur", v:"Ville"},
```

## Sécurité

- Les tokens Gmail sont temporaires (1h) et stockés en mémoire uniquement
- Les conversations sont en `localStorage` (par navigateur)
- Les scopes demandés : `gmail.send` + `gmail.readonly` (pour filtrer les réponses d'entreprises contactées uniquement)
