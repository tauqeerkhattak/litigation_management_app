import 'package:flutter/material.dart';

class AppColors {
  static const Color navy = Color(0xFF0B1F3A);
  static const Color navyMid = Color(0xFF122848);
  static const Color navyLight = Color(0xFF1A3A5C);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE2C87A);
  static const Color cream = Color(0xFFF5F0E8);
  static const Color creamDark = Color(0xFFEDE6D6);
  static const Color red = Color(0xFFC0392B);
  static const Color green = Color(0xFF1A7A4A);
  static const Color text = Color(0xFF1C2B3A);
  static const Color muted = Color(0xFF6B7C93);
  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFD4C9B0);
}

// These lists are deprecated and have been replaced by enums.

enum Court {
  highCourt,
  civilCourt,
  sessionsCourt,
  antiCorruptionCourt,
  serviceTribunal,
  federalShariatCourt,
  supremeCourt,
  other,
}

extension CourtExtension on Court {
  String get displayName {
    switch (this) {
      case Court.highCourt:
        return "High Court";
      case Court.civilCourt:
        return "Civil Court";
      case Court.sessionsCourt:
        return "Sessions Court";
      case Court.antiCorruptionCourt:
        return "Anti-Corruption Court";
      case Court.serviceTribunal:
        return "Service Tribunal";
      case Court.federalShariatCourt:
        return "Federal Shariat Court";
      case Court.supremeCourt:
        return "Supreme Court";
      case Court.other:
        return "Other";
    }
  }
}

enum Bench { singleBench, divisionBench, fullBench }

extension BenchExtension on Bench {
  String get displayName {
    switch (this) {
      case Bench.singleBench:
        return "Single Bench";
      case Bench.divisionBench:
        return "Division Bench";
      case Bench.fullBench:
        return "Full Bench";
    }
  }
}

enum CaseNature {
  revenue,
  generalRecruitment,
  disabledQuota,
  generalAdministration,
  serviceMatter,
  contemptCase,
  other,
}

extension CaseNatureExtension on CaseNature {
  String get displayName {
    switch (this) {
      case CaseNature.revenue:
        return "Revenue";
      case CaseNature.generalRecruitment:
        return "General Recruitment";
      case CaseNature.disabledQuota:
        return "Disabled Quota";
      case CaseNature.generalAdministration:
        return "General Administration";
      case CaseNature.serviceMatter:
        return "Service Matter";
      case CaseNature.contemptCase:
        return "Contempt Case";
      case CaseNature.other:
        return "Other";
    }
  }
}

enum Taluka { sukkurCity, newSukkur, rohri, panoAqil, salehPat }

extension TalukaExtension on Taluka {
  String get displayName {
    switch (this) {
      case Taluka.sukkurCity:
        return "Sukkur City";
      case Taluka.newSukkur:
        return "New Sukkur";
      case Taluka.rohri:
        return "Rohri";
      case Taluka.panoAqil:
        return "Pano Aqil";
      case Taluka.salehPat:
        return "Saleh Pat";
    }
  }
}

enum Department {
  educationLiteracy,
  health,
  irrigation,
  agriculture,
  revenue,
  policeHome,
  localGovernment,
  worksServices,
  socialWelfare,
  other,
}

extension DepartmentExtension on Department {
  String get displayName {
    switch (this) {
      case Department.educationLiteracy:
        return "Education & Literacy";
      case Department.health:
        return "Health";
      case Department.irrigation:
        return "Irrigation";
      case Department.agriculture:
        return "Agriculture";
      case Department.revenue:
        return "Revenue";
      case Department.policeHome:
        return "Police / Home";
      case Department.localGovernment:
        return "Local Government";
      case Department.worksServices:
        return "Works & Services";
      case Department.socialWelfare:
        return "Social Welfare";
      case Department.other:
        return "Other";
    }
  }
}

enum CaseStatus { active, stayGranted, decided, dismissed }

extension CaseStatusExtension on CaseStatus {
  String get displayName {
    switch (this) {
      case CaseStatus.active:
        return "Active";
      case CaseStatus.stayGranted:
        return "Stay Granted";
      case CaseStatus.decided:
        return "Decided";
      case CaseStatus.dismissed:
        return "Dismissed";
    }
  }
}

enum DocumentType {
  plaint,
  parawiseComments,
  writtenStatement,
  complianceReport,
  orderSheet,
  judgement,
  other,
}

extension DocumentTypeExtension on DocumentType {
  String get displayName {
    switch (this) {
      case DocumentType.plaint:
        return "Plaint";
      case DocumentType.parawiseComments:
        return "Parawise Comments";
      case DocumentType.writtenStatement:
        return "Written Statement";
      case DocumentType.complianceReport:
        return "Compliance Report";
      case DocumentType.orderSheet:
        return "Order Sheet";
      case DocumentType.judgement:
        return "Judgement";
      case DocumentType.other:
        return "Other";
    }
  }
}

enum UserRole {
  editor, // Can create cases, hearings, and add documents
  commentor, // Cannot create cases, can create hearings and add documents
  documentor, // Cannot create cases and hearings, can only add documents
  viewer, // Only view cases, hearings, and documents
}
