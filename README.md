# Site Web E-Commerce

Site web e-commerce simple construit avec Flask et SQLite.

Un login et mot de passe est créé :
  * Nom d'utilisateur : admin
  * Mot de passe : admin

---

### Installation
#### 1. Dézippez l'archive.

#### 2. Installez les dépendances.
> ```
> pip install -r requirements.txt
> ```

#### 3. Créez une base de données.
> ```
> sqlite3 e-commerce.db
> ```

#### 4. Créez les tables.
> ```
> CREATE TABLE users (
>     id INTEGER PRIMARY KEY AUTOINCREMENT,
>     username TEXT UNIQUE NOT NULL,
>     email_address TEXT UNIQUE NOT NULL,
>     password_hash TEXT NOT NULL,
>     budget INTEGER NOT NULL DEFAULT 10000
> );
>
> CREATE TABLE items (
>     id INTEGER PRIMARY KEY AUTOINCREMENT,
>     name TEXT UNIQUE NOT NULL,
>     barcode TEXT UNIQUE NOT NULL,
>     price INTEGER NOT NULL,
>     description TEXT NOT NULL,
>     owner INTEGER REFERENCES users (id)
> );
> ```

#### 5. Lancez le site web.
> ```
> python main.py
> ```

---
