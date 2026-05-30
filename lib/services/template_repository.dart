import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/doc_template.dart';

/// قوالب مستندات جاهزة للاستخدام مع محتوى عربي مُعبّأ مسبقاً.
class TemplateRepository {
  static List<DocTemplate> all = [
    DocTemplate(
      id: 'blank',
      name: 'مستند فارغ',
      description: 'ابدأ من صفحة بيضاء',
      icon: Icons.description_outlined,
      gradient: const [Color(0xFF8E9EAB), Color(0xFFEEF2F3)],
      delta: [
        {'insert': '\n'}
      ],
    ),
    DocTemplate(
      id: 'business_letter',
      name: 'خطاب رسمي',
      description: 'تنسيق خطاب رسمي',
      icon: Icons.mail_outline,
      gradient: const [Color(0xFF2E7CF6), Color(0xFF00C6FF)],
      delta: [
        {
          'insert': 'اسم الشركة',
          'attributes': {'bold': true, 'size': 'large'}
        },
        {'insert': '\n'},
        {'insert': '123 شارع الأعمال، المدينة، الدولة\n'},
        {'insert': '\n'},
        {'insert': 'التاريخ: '},
        {'insert': '\n\n'},
        {'insert': 'السيد/السيدة [اسم المستلم] المحترم،\n\n'},
        {
          'insert':
              'أكتب إليكم بخصوص... \n\nشكراً لكم على وقتكم واهتمامكم.\n\n'
        },
        {'insert': 'وتفضلوا بقبول فائق الاحترام،\n'},
        {
          'insert': 'اسمك',
          'attributes': {'bold': true}
        },
        {'insert': '\n'},
      ],
    ),
    DocTemplate(
      id: 'resume',
      name: 'السيرة الذاتية',
      description: 'سيرة ذاتية احترافية',
      icon: Icons.badge_outlined,
      gradient: const [Color(0xFF7C4DFF), Color(0xFFB388FF)],
      delta: [
        {
          'insert': 'الاسم الكامل',
          'attributes': {'bold': true, 'size': 'huge'}
        },
        {'insert': '\n'},
        {'insert': 'المسمى الوظيفي • email@example.com • +966 5XX\n\n'},
        {
          'insert': 'نبذة',
          'attributes': {'bold': true, 'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'ملخص مهني مختصر عن نفسك.\n\n'},
        {
          'insert': 'الخبرات',
          'attributes': {'bold': true, 'header': 2}
        },
        {'insert': '\n'},
        {
          'insert': 'الشركة — الدور الوظيفي (2020 – حتى الآن)',
          'attributes': {'bold': true}
        },
        {'insert': '\n'},
        {
          'insert': 'أبرز إنجاز أو مسؤولية',
          'attributes': {'list': 'bullet'}
        },
        {'insert': '\n\n'},
        {
          'insert': 'التعليم',
          'attributes': {'bold': true, 'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'الجامعة — الدرجة العلمية (السنة)\n'},
      ],
    ),
    DocTemplate(
      id: 'report',
      name: 'تقرير مشروع',
      description: 'تقرير منظّم',
      icon: Icons.assessment_outlined,
      gradient: const [Color(0xFFD81B8C), Color(0xFFFF6CAB)],
      delta: [
        {
          'insert': 'تقرير المشروع',
          'attributes': {'header': 1}
        },
        {'insert': '\n'},
        {
          'insert': '١. نظرة عامة',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'صف خلفية المشروع وأهدافه.\n\n'},
        {
          'insert': '٢. الأهداف',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {
          'insert': 'الهدف الأول',
          'attributes': {'list': 'ordered'}
        },
        {'insert': '\n'},
        {
          'insert': 'الهدف الثاني',
          'attributes': {'list': 'ordered'}
        },
        {'insert': '\n\n'},
        {
          'insert': '٣. الخاتمة',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'لخّص النتائج هنا.\n'},
      ],
    ),
    DocTemplate(
      id: 'meeting_notes',
      name: 'محضر اجتماع',
      description: 'جدول الأعمال والمهام',
      icon: Icons.event_note_outlined,
      gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
      delta: [
        {
          'insert': 'محضر الاجتماع',
          'attributes': {'header': 1}
        },
        {'insert': '\n'},
        {'insert': 'التاريخ: _____   الحضور: _____\n\n'},
        {
          'insert': 'جدول الأعمال',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {
          'insert': 'الموضوع الأول',
          'attributes': {'list': 'bullet'}
        },
        {'insert': '\n\n'},
        {
          'insert': 'المهام',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {
          'insert': 'المهمة — المسؤول — تاريخ الاستحقاق',
          'attributes': {'list': 'unchecked'}
        },
        {'insert': '\n'},
      ],
    ),
    DocTemplate(
      id: 'invoice',
      name: 'فاتورة',
      description: 'مستند فوترة',
      icon: Icons.receipt_long_outlined,
      gradient: const [Color(0xFFF7971E), Color(0xFFFFD200)],
      delta: [
        {
          'insert': 'فاتورة',
          'attributes': {'header': 1}
        },
        {'insert': '\n'},
        {'insert': 'رقم الفاتورة: 0001    التاريخ: _____\n\n'},
        {
          'insert': 'فاتورة إلى:',
          'attributes': {'bold': true}
        },
        {'insert': '\nاسم العميل\nعنوان العميل\n\n'},
        {
          'insert': 'الوصف        الكمية     السعر     الإجمالي',
          'attributes': {'bold': true}
        },
        {'insert': '\nالبند الأول        1       100       100\n\n'},
        {
          'insert': 'الإجمالي: 100',
          'attributes': {'bold': true, 'size': 'large'}
        },
        {'insert': '\n'},
      ],
    ),
    DocTemplate(
      id: 'essay',
      name: 'مقال أكاديمي',
      description: 'هيكل المقال',
      icon: Icons.school_outlined,
      gradient: const [Color(0xFF614385), Color(0xFF516395)],
      delta: [
        {
          'insert': 'عنوان المقال',
          'attributes': {'header': 1}
        },
        {'insert': '\n'},
        {
          'insert': 'المقدمة',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'قدّم فكرتك الرئيسية.\n\n'},
        {
          'insert': 'العرض',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'طوّر حججك بالأدلة والشواهد.\n\n'},
        {
          'insert': 'الخاتمة',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'أعد صياغة الفكرة واختتم المقال.\n'},
      ],
    ),
    DocTemplate(
      id: 'todo',
      name: 'قائمة مهام',
      description: 'قائمة تحقّق',
      icon: Icons.checklist_outlined,
      gradient: const [Color(0xFFFF512F), Color(0xFFDD2476)],
      delta: [
        {
          'insert': 'قائمة مهامي',
          'attributes': {'header': 1}
        },
        {'insert': '\n'},
        {
          'insert': 'المهمة الأولى',
          'attributes': {'list': 'unchecked'}
        },
        {'insert': '\n'},
        {
          'insert': 'المهمة الثانية',
          'attributes': {'list': 'unchecked'}
        },
        {'insert': '\n'},
        {
          'insert': 'المهمة الثالثة',
          'attributes': {'list': 'unchecked'}
        },
        {'insert': '\n'},
      ],
    ),
  ];

  static String deltaToJson(List<Map<String, dynamic>> delta) =>
      jsonEncode(delta);

  static String plainTextFromDelta(List<Map<String, dynamic>> delta) {
    final sb = StringBuffer();
    for (final op in delta) {
      final ins = op['insert'];
      if (ins is String) sb.write(ins);
    }
    return sb.toString();
  }
}
