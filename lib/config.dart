import 'dart:async';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

class Config {
  static String appId = "";
  static String appName = "";
  static String appStoreLink = "";

  // Method to load the configuration from the XML file
  static Future<void> loadConfig() async {
    // Load the XML from assets
    final String xmlString = await rootBundle.loadString('assets/config.xml');
    final XmlDocument xmlDocument = XmlDocument.parse(xmlString);

    // Parse values from the XML
    appId = xmlDocument.findAllElements('id').first.innerText;
    appName = xmlDocument.findAllElements('name').first.innerText;
    appStoreLink = xmlDocument.findAllElements('link').first.innerText;
  }
}
