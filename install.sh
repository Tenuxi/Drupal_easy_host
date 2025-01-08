#!/bin/bash

# Määritä projektin juurikansio
WEB_ROOT="web"

echo "Drupal-projektin automaattinen asennus käynnistyy..."

# 1. Lataa ja asennetaan Composer-projektin riippuvuudet
echo "Ladataan ja asennetaan Composer-riippuvuudet..."
composer install --ignore-platform-reqs || {
  echo "Composer-projektin luominen epäonnistui.";
  exit 1;
}

# 2. Asenna Drush kehitysriippuvuudeksi
echo "Asennetaan Drush kehitysriippuvuudeksi..."
composer require drush/drush --ignore-platform-req=ext-dom || {
  echo "Drushin asentaminen Composerilla epäonnistui.";
  exit 1;
}

# 3. Tarkista Drush-versio
if [ -f "vendor/bin/drush" ]; then
  echo "Tarkistetaan Drush-versio..."
  vendor/bin/drush --version || { echo "Drushin version tarkistus epäonnistui."; exit 1; }
else
  echo "Drushia ei löydy asennuksen jälkeen. Varmista Composerin asetukset."
  exit 1
fi

# 4. Luo tarvittavat hakemistot ja kopioi asetustiedostot
echo "Valmistellaan hakemistoja..."
mkdir -p $WEB_ROOT/sites/default/files

# Tarkistetaan, että oletusasetustiedostot ovat paikallaan ja kopioidaan ne
if [ -f "$WEB_ROOT/sites/default/default.settings.php" ]; then
  echo "Oletusasetustiedostot löytyivät, kopioidaan ne..."
  cp $WEB_ROOT/sites/default/default.settings.php $WEB_ROOT/sites/default/settings.php
else
  echo "Virhe: Oletusasetustiedostoa ei löytynyt, luodaan se..."
  cp $WEB_ROOT/sites/default/default.settings.php.dist $WEB_ROOT/sites/default/settings.php
fi

if [ -f "$WEB_ROOT/sites/default/default.services.yml" ]; then
  echo "Oletus services.yml tiedosto löytyi, kopioidaan se..."
  cp $WEB_ROOT/sites/default/default.services.yml $WEB_ROOT/sites/default/services.yml
else
  echo "Virhe: Oletus services.yml tiedostoa ei löytynyt, luodaan se..."
  cp $WEB_ROOT/sites/default/default.services.yml.dist $WEB_ROOT/sites/default/services.yml
fi

# 5. Aseta oikeudet tiedostoille
echo "Asetetaan tiedostojen oikeudet..."
chmod 777 $WEB_ROOT/sites/default/files
chmod 666 $WEB_ROOT/sites/default/settings.php
chmod 666 $WEB_ROOT/sites/default/services.yml

# 6. Päätä asennus
echo "Asennus valmis! Voit käyttää sivustoa avaamalla selaimessa:"
echo "URL: http://localhost/$WEB_ROOT"
