import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/doc_template.dart';

/// Curated, ready-to-use document templates with pre-filled Quill content.
class TemplateRepository {
  static List<DocTemplate> all = [
    DocTemplate(
      id: 'blank',
      name: 'Blank Document',
      description: 'Start from a clean page',
      icon: Icons.description_outlined,
      gradient: const [Color(0xFF8E9EAB), Color(0xFFEEF2F3)],
      delta: [
        {'insert': '\n'}
      ],
    ),
    DocTemplate(
      id: 'business_letter',
      name: 'Business Letter',
      description: 'Formal letter layout',
      icon: Icons.mail_outline,
      gradient: const [Color(0xFF2E7CF6), Color(0xFF00C6FF)],
      delta: [
        {
          'insert': 'Your Company Name',
          'attributes': {'bold': true, 'size': 'large'}
        },
        {'insert': '\n'},
        {'insert': '123 Business Street, City, Country\n'},
        {'insert': '\n'},
        {'insert': 'Date: '},
        {'insert': '\n\n'},
        {'insert': 'Dear [Recipient Name],\n\n'},
        {
          'insert':
              'I am writing to you regarding... \n\nThank you for your time and consideration.\n\n'
        },
        {'insert': 'Sincerely,\n'},
        {
          'insert': 'Your Name',
          'attributes': {'bold': true}
        },
        {'insert': '\n'},
      ],
    ),
    DocTemplate(
      id: 'resume',
      name: 'Resume / CV',
      description: 'Professional resume',
      icon: Icons.badge_outlined,
      gradient: const [Color(0xFF7C4DFF), Color(0xFFB388FF)],
      delta: [
        {
          'insert': 'FULL NAME',
          'attributes': {'bold': true, 'size': 'huge'}
        },
        {'insert': '\n'},
        {'insert': 'Job Title • email@example.com • +1 234 567\n\n'},
        {
          'insert': 'PROFILE',
          'attributes': {'bold': true, 'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'A short professional summary about yourself.\n\n'},
        {
          'insert': 'EXPERIENCE',
          'attributes': {'bold': true, 'header': 2}
        },
        {'insert': '\n'},
        {
          'insert': 'Company — Role (2020 – Present)',
          'attributes': {'bold': true}
        },
        {'insert': '\n'},
        {
          'insert': 'Key achievement or responsibility',
          'attributes': {'list': 'bullet'}
        },
        {'insert': '\n\n'},
        {
          'insert': 'EDUCATION',
          'attributes': {'bold': true, 'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'University — Degree (Year)\n'},
      ],
    ),
    DocTemplate(
      id: 'report',
      name: 'Project Report',
      description: 'Structured report',
      icon: Icons.assessment_outlined,
      gradient: const [Color(0xFFD81B8C), Color(0xFFFF6CAB)],
      delta: [
        {
          'insert': 'Project Report',
          'attributes': {'header': 1}
        },
        {'insert': '\n'},
        {
          'insert': '1. Overview',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'Describe the project background and goals.\n\n'},
        {
          'insert': '2. Objectives',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {
          'insert': 'First objective',
          'attributes': {'list': 'ordered'}
        },
        {'insert': '\n'},
        {
          'insert': 'Second objective',
          'attributes': {'list': 'ordered'}
        },
        {'insert': '\n\n'},
        {
          'insert': '3. Conclusion',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'Summarize the outcomes here.\n'},
      ],
    ),
    DocTemplate(
      id: 'meeting_notes',
      name: 'Meeting Notes',
      description: 'Agenda & action items',
      icon: Icons.event_note_outlined,
      gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
      delta: [
        {
          'insert': 'Meeting Notes',
          'attributes': {'header': 1}
        },
        {'insert': '\n'},
        {'insert': 'Date: _____   Attendees: _____\n\n'},
        {
          'insert': 'Agenda',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {
          'insert': 'Topic one',
          'attributes': {'list': 'bullet'}
        },
        {'insert': '\n\n'},
        {
          'insert': 'Action Items',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {
          'insert': 'Task — Owner — Due date',
          'attributes': {'list': 'unchecked'}
        },
        {'insert': '\n'},
      ],
    ),
    DocTemplate(
      id: 'invoice',
      name: 'Invoice',
      description: 'Billing document',
      icon: Icons.receipt_long_outlined,
      gradient: const [Color(0xFFF7971E), Color(0xFFFFD200)],
      delta: [
        {
          'insert': 'INVOICE',
          'attributes': {'header': 1}
        },
        {'insert': '\n'},
        {'insert': 'Invoice #: 0001    Date: _____\n\n'},
        {
          'insert': 'Bill To:',
          'attributes': {'bold': true}
        },
        {'insert': '\nClient Name\nClient Address\n\n'},
        {
          'insert': 'Description        Qty     Price     Total',
          'attributes': {'bold': true}
        },
        {'insert': '\nItem 1             1       \$100      \$100\n\n'},
        {
          'insert': 'Total: \$100',
          'attributes': {'bold': true, 'size': 'large'}
        },
        {'insert': '\n'},
      ],
    ),
    DocTemplate(
      id: 'essay',
      name: 'Academic Essay',
      description: 'Essay structure',
      icon: Icons.school_outlined,
      gradient: const [Color(0xFF614385), Color(0xFF516395)],
      delta: [
        {
          'insert': 'Essay Title',
          'attributes': {'header': 1}
        },
        {'insert': '\n'},
        {
          'insert': 'Introduction',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'Introduce your thesis statement.\n\n'},
        {
          'insert': 'Body',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'Develop your arguments with evidence.\n\n'},
        {
          'insert': 'Conclusion',
          'attributes': {'header': 2}
        },
        {'insert': '\n'},
        {'insert': 'Restate and conclude.\n'},
      ],
    ),
    DocTemplate(
      id: 'todo',
      name: 'To-Do List',
      description: 'Checklist layout',
      icon: Icons.checklist_outlined,
      gradient: const [Color(0xFFFF512F), Color(0xFFDD2476)],
      delta: [
        {
          'insert': 'My To-Do List',
          'attributes': {'header': 1}
        },
        {'insert': '\n'},
        {
          'insert': 'First task',
          'attributes': {'list': 'unchecked'}
        },
        {'insert': '\n'},
        {
          'insert': 'Second task',
          'attributes': {'list': 'unchecked'}
        },
        {'insert': '\n'},
        {
          'insert': 'Third task',
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
