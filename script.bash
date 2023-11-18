#!/usr/bin/env bash

# #############################################################################
# 変数定義
# #############################################################################

# Laravel をインストールするディレクトリ
readonly INSTALL_DIR="$1"
if [[ -z "${INSTALL_DIR}" ]]; then
    echo "Please enter the directory name to install Laravel."
    exit 1
fi

# Laravel をインストールするディレクトリの所有権を持つユーザー
readonly OWNER_USER="$2"
if [[ -z "${OWNER_USER}" ]]; then
    echo "Please enter the user who owns the directory to install Laravel."
    exit 1
fi

# Laravel にアクセスする為の URL
readonly ACCESS_URL="$3"
if [[ -z "${ACCESS_URL}" ]]; then
    echo "Please enter the URL to access Laravel."
    exit 1
fi

# Laravel-Customizedをインストールするかどうか
readonly IS_INSTALL_LATEST_LARAVEL=${4-0}

# #############################################################################
# 処理部分
# #############################################################################

# -----------------------------------------------------------------------------
# 開始メッセージの表示
# -----------------------------------------------------------------------------

echo ""
echo "--------------------------------------------------"
echo "Start Installing Laravel Application."
echo "--------------------------------------------------"
echo ""

# -----------------------------------------------------------------------------
# ダウンロード
# -----------------------------------------------------------------------------

# ダウンロードするディレクトリが存在しない場合は作成
if [ ! -d "/var/www/html/${INSTALL_DIR}" ]; then
    mkdir -p "/var/www/html/${INSTALL_DIR}"
fi

# ダウンロードするディレクトリに移動
cd "/var/www/html/${INSTALL_DIR}"

# Laravel のダウンロード
# IS_INSTALL_LATEST_LARAVEL が 0 の場合は Laravel の最新版をインストール
# IS_INSTALL_LATEST_LARAVEL が 1 の場合は Laravel-Customized をインストール
if [[ "${IS_INSTALL_LATEST_LARAVEL}" -eq 0 ]]; then
    composer create-project --prefer-dist laravel/laravel .
else
    git clone https://github.com/Takeru-Yamamoto/Laravel-Customized.git .
fi

# -----------------------------------------------------------------------------
# Laravelの設定
# -----------------------------------------------------------------------------

# Laravel のディレクトリに移動
cd "/var/www/html/${INSTALL_DIR}"

# .env.exampleのAPP_URLを変更
sed -i -e "s/APP_URL=http:\/\/localhost/APP_URL=http:\/\/${ACCESS_URL}/g" .env.example

# .env ファイルをコピー
cp .env.example .env

# vendor 配下のファイルをComposerでインストール
composer update

# Composerのオートロードを更新
composer dump-autoload

# APP_KEY を生成
php artisan key:generate

# storage 配下のファイルのシンボリックリンクを作成
php artisan storage:link

# Laravel のディレクトリで npm を実行
npm install && npm run build

# Laravel のディレクトリの所有権を変更
chown -R "${OWNER_USER}:${OWNER_USER}" "/var/www/html/${INSTALL_DIR}"

# Laravel のディレクトリのパーミッションを変更
chmod -R 755 "/var/www/html/${INSTALL_DIR}"

# Storage ディレクトリのパーミッションを変更
chmod -R 777 "/var/www/html/${INSTALL_DIR}/storage"

# -----------------------------------------------------------------------------
# Apacheの設定
# -----------------------------------------------------------------------------

# httpd.conf のバックアップ
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak

# httpd.conf の編集
sed -i -e "s/DocumentRoot \"\/var\/www\/html\"/DocumentRoot \"\/var\/www\/html\/${INSTALL_DIR}\/public\"/g" /etc/httpd/conf/httpd.conf
sed -i -e "s/<Directory \"\/var\/www\/\">/<Directory \"\/var\/www\/html\/${INSTALL_DIR}\/public\">/g" /etc/httpd/conf/httpd.conf
sed -i -e "s/AllowOverride None/AllowOverride All/g" /etc/httpd/conf/httpd.conf
sed -i -e "s/DirectoryIndex index.html/DirectoryIndex index.php index.html/g" /etc/httpd/conf/httpd.conf

# Apache の再起動
systemctl restart httpd

# -----------------------------------------------------------------------------
# 終了メッセージの表示
# -----------------------------------------------------------------------------

echo ""
echo "--------------------------------------------------"
echo "Complete Installing Laravel Application."
echo "Please make the appropriate edits and perform the migration ans seeding."
echo "--------------------------------------------------"
echo ""
