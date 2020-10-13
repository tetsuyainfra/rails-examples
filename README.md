# rails でいろいろ試すときのテンプレート的なコード集

# 使い方

```
cp .env-original .env
# パスワードなどを変えてみたければ
vi .env

# run database
docker-compose up -d

# Adminer http://localhost:28080
# PostgreSQL localhost:25432
# MySQL localhost:3306

```

# ライセンスについての懸念点

ソースコードの一部に GPL2.0 のソフトウェアを含みます。  
具体的には`adminer/plugins/auto-login.php`  
Adminer のプラグインとして独立したソフトウェアと考えられるので多分大丈夫だと思いますが、
何かあれば Adminer のプラグインとして取り込まれるまでオートログインの設定は消えます。
