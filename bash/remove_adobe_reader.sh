#!/bin/sh

#remove_adobe_reader.sh

rm -rf "/Applications/Adobe Reader.app"
rm -rf "/Library/Internet Plug-ins/AdobePDFViewer.plugin"
rm -f "/Library/Application Support/Adobe/HelpCfg/en_US/Reader.helpcfg"

pkgutil --forget com.adobe.acrobat.reader.10.reader.app.pkg.en_US
pkgutil --forget com.adobe.acrobat.reader.10.reader.browser.pkg.en_US
pkgutil --forget com.adobe.acrobat.reader.10.reader.appsupport.pkg.en_US
pkgutil --forget com.adobe.acrobat.reader.11003.reader.app.pkg.en_US
pkgutil --forget com.adobe.acrobat.reader.11003.reader.appsupport.pkg.en_US
pkgutil --forget com.adobe.acrobat.reader.11003.reader.browser.pkg.en_US
pkgutil --forget com.adobe.acrobat.reader.11004.reader.app.pkg.en_US
pkgutil --forget com.adobe.acrobat.reader.11004.reader.appsupport.pkg.en_US
pkgutil --forget com.adobe.acrobat.reader.11004.reader.browser.pkg.en_US
pkgutil --forget com.adobe.acrobat.reader.11006.reader.app.pkg.en_US
pkgutil --forget com.adobe.acrobat.reader.11006.reader.appsupport.pkg.en_US
pkgutil --forget com.adobe.acrobat.reader.11006.reader.browser.pkg.en_US