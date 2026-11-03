# المهمة التأسيسية الأولى: إنشاء خارطة التنفيذ الرئيسية النهائية لمشروع معمل ياسين
# YASIN WORKSHOP — MASTER IMPLEMENTATION ROADMAP R3
# STATUS: AUTHORITATIVE ROADMAP CANDIDATE
# PROJECT: NEW / INDEPENDENT / FROM SCRATCH

══════════════════════════════════════════════════════════════
[MISSION]
══════════════════════════════════════════════════════════════

إنشاء المرجع التنفيذي الرئيسي والدائم لمشروع «معمل ياسين» من الصفر وحتى
القبول والتشغيل والتسليم النهائي.

هذه النسخة R3 تحل محل نسخ الخارطة السابقة R1 وR2 عند حفظها واعتمادها.

لا تبقِ R1 أو R2 كمصدر تنفيذ موازٍ يسبب تضاربًا.
إذا كانت هناك نسخ سابقة موجودة فعليًا، لا تحذفها حذفًا خطيرًا أو واسعًا،
بل تعامل معها وفق سياسة الوثائق والمحفوظات المعتمدة، مع جعل R3 المرجع النشط.

يجب أن تحدد الخارطة:

- هوية المشروع.
- مصادر الحقيقة.
- قواعد السلطة بين الوثائق.
- حدود المرحلة الأولى.
- الأعمال المستقبلية.
- قرارات المالك المعلقة.
- مراحل التنفيذ.
- التبعيات.
- الشاشات المطلوبة.
- Backend.
- Flutter.
- قاعدة البيانات.
- الأمن.
- الأداء.
- التزامن.
- منع التكرار.
- سجل المراجعة.
- المحرك المالي التشغيلي.
- الرسائل.
- المهام الخلفية.
- النسخ والاستعادة.
- النشر والترقية والتراجع.
- الاختبارات أثناء التنفيذ.
- اختبارات القبول.
- الاختبار الشامل.
- التشغيل والمراقبة.
- التسليم النهائي.
- سجل المهام.
- معايير قبول وإغلاق كل مهمة.
- دليل التحقق المطلوب.

هذه المهمة الحالية توثيقية تأسيسية فقط.

الاستثناء الوحيد من قاعدة «لا تبدأ التنفيذ» في هذا الأمر هو إنشاء أو تحديث
وثائق الإدارة المركزية المصرح بها صراحة في نهاية هذا الأمر.

لا تبدأ بسبب هذا الأمر:
- Flutter.
- Backend.
- Microsoft SQL Server database setup for this project stage.
- قاعدة بيانات.
- Server Setup.
- Docker.
- Redis.
- Celery.
- Nginx.
- WhatsApp Integration.
- أي ميزة أعمال.

المسار الرسمي لمصدر المشروع على جهاز التطوير الحالي:

D:\YASIN_WORKSHOP

الملف الرئيسي المطلوب:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_MASTER_ROADMAP.md

ولا تدّعِ إنشاء أي ملف أو قراءته أو التحقق منه إلا إذا حدث ذلك فعليًا.

══════════════════════════════════════════════════════════════
[1] هوية المشروع
══════════════════════════════════════════════════════════════

PROJECT NAME:
معمل ياسين

TECHNICAL NAME:
YASIN_WORKSHOP

CURRENT DEVELOPMENT SOURCE PATH:
D:\YASIN_WORKSHOP

المشروع مستقل تمامًا عن LUMAR وعن أي مشروع آخر.

يُبنى من الصفر.

يستخدم قاعدة بيانات جديدة مستقلة.

لا تنقل:
- Business Rules.
- Database.
- Tables.
- Migrations.
- Source Code.
- Secrets.
- Accounts.
- Runtime Data.

من مشروع سابق إلا بتفويض صريح من مالك معمل ياسين.

يمكن الاستفادة من الخبرات والمبادئ الهندسية العامة فقط عندما تكون مناسبة لهذا
المشروع ولا تنقل عقد أعمال خاصًا بمشروع آخر.

المرحلة الأولى تنشئ نظامًا عربيًا متكاملًا لإدارة:

1. العملاء.
2. الأكوات.
3. دفعات الأكوات.
4. متابعة حالة الأكوات.
5. التسليم الجزئي والكامل.
6. أسعار العملاء الشهرية.
7. سحوبات العملاء.
8. حسابات العملاء الشهرية.
9. الموظفين.
10. موظفي أجر القطعة.
11. موظفي الراتب الأساسي.
12. شروط أجور ورواتب الموظفين الشهرية.
13. الإنتاج اليومي.
14. مصروف الموظفين.
15. الأيام غير المسجلة.
16. الإجازة بالمعنى التشغيلي المعتمد فقط.
17. قيد تعديل إنتاج ومصروف الموظف 24 ساعة.
18. حساب الموظف الشهري.
19. التسويات.
20. الذمم.
21. الاستردادات.
22. الموردين.
23. المواد.
24. وحدات القياس.
25. فواتير الشراء.
26. دفعات المورد.
27. تخصيص الدفعات.
28. حساب المورد.
29. الرسائل.
30. الكشوف الأسبوعية والشهرية.
31. المستخدمين.
32. الأدوار والصلاحيات.
33. سجل المراجعة.
34. المرفقات.
35. النسخ الاحتياطية.
36. الاستعادة.
37. مراقبة الخدمات.
38. الوصول الآمن من الأجهزة المعتمدة.

══════════════════════════════════════════════════════════════
[2] مصادر الحقيقة وترتيب السلطة
══════════════════════════════════════════════════════════════

SOURCE-1 — BUSINESS REQUIREMENTS
قواعد الأعمال والمتطلبات الرسمية.

المسار:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_BUSINESS_REQUIREMENTS.md

وظيفته:
تحديد ما الذي يجب أن يفعله النظام وقواعد الأعمال المعتمدة.

SOURCE-2 — PERMANENT DEVELOPMENT POLICY
السياسة الهندسية الدائمة.

المسار:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_PERMANENT_DEVELOPMENT_POLICY.md

وظيفتها:
تحديد كيف يتم التطوير، والأمان، والواجهة، والأداء، والتنقل، والاختبار،
وحماية المشروع والجهاز والبيانات.

SOURCE-3 — MASTER ROADMAP
خارطة التنفيذ الرئيسية.

المسار:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_MASTER_ROADMAP.md

وظيفتها:
تحديد ترتيب التنفيذ والتبعيات وحالة العمل المطلوبة.

SOURCE-4 — TASK REGISTER
سجل المهام التنفيذي الفعلي.

المسار:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_TASK_REGISTER.md

وظيفته:
متابعة الحالة الحقيقية لكل مهمة معرفّة في الخارطة.

SOURCE-5 — DECISION LOG
سجل قرارات المالك وتغييرات النطاق.

المسار:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_DECISION_LOG.md

ترتيب السلطة:

قواعد الأعمال
→ BUSINESS REQUIREMENTS

قرارات الأعمال الأحدث المعتمدة
→ DECISION LOG ثم تُرحل للوثيقة الرسمية المتأثرة

القواعد الهندسية
→ PERMANENT DEVELOPMENT POLICY

تسلسل التنفيذ
→ MASTER ROADMAP

حالة التنفيذ الفعلية
→ TASK REGISTER

إذا ظهر تعارض:

1. لا يخترع المنفذ الحل.
2. لا يغير قاعدة الأعمال عبر تعديل الخارطة.
3. يسجل التعارض.
4. يحدد الوثائق المتعارضة.
5. يحدد البنود المتأثرة.
6. يحدد الأثر التقني والبياني.
7. إذا كان التعارض تجاريًا يرفعه للمالك.
8. يسجل القرار المعتمد.
9. تحدث الوثائق الرسمية المتأثرة.
10. لا تترك مصدرين متعارضين على أنهما صالحان معًا.

══════════════════════════════════════════════════════════════
[3] الوثائق المركزية الثابتة
══════════════════════════════════════════════════════════════

المسارات المركزية المعتمدة:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_BUSINESS_REQUIREMENTS.md

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_PERMANENT_DEVELOPMENT_POLICY.md

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_MASTER_ROADMAP.md

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_TASK_REGISTER.md

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_DECISION_LOG.md

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_CORRECTION_IMPACT_MATRIX.md

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_REQUIREMENTS_TEST_MATRIX.md

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_ARCHITECTURE_DECISIONS.md

لا تنشئ ملفات أخرى تكرر وظيفة أحد هذه المراجع دون سبب مثبت.

ARCHITECTURE DECISIONS
يسجل القرارات التقنية والمعمارية فقط.

لا يجوز أن يستخدم ARCHITECTURE DECISIONS لتجاوز قرار أعمال يحتاج موافقة المالك.

══════════════════════════════════════════════════════════════
[4] سجل القرارات وتغييرات النطاق
══════════════════════════════════════════════════════════════

كل قرار رسمي دائم يأخذ معرفًا ثابتًا:

DEC-001
DEC-002
...

كل سجل يحتوي:

DECISION_ID=
DATE=
OWNER=
TYPE=
REASON=
AFFECTED_RULES=
AFFECTED_TASKS=
DATABASE_IMPACT=
BACKEND_IMPACT=
FLUTTER_IMPACT=
MESSAGING_IMPACT=
TEST_IMPACT=
DATA_MIGRATION_IMPACT=
SCOPE_IMPACT=
STATUS=

أنواع القرارات:

TECHNICAL DECISION
قرار تقني لا يغير قواعد الأعمال.

BUSINESS DECISION
قرار أعمال يحتاج اعتماد المالك.

SCOPE CHANGE
إضافة أو إزالة نطاق.

لا يجوز تصنيف تغيير أعمال على أنه قرار تقني للتحايل على موافقة المالك.

══════════════════════════════════════════════════════════════
[5] سجل المهام التنفيذي الحقيقي
══════════════════════════════════════════════════════════════

الخارطة ليست قائمة وصفية فقط.

كل بند تنفيذي مرقم في هذه الخارطة يجب أن يتحول إلى سجل حقيقي في:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_TASK_REGISTER.md

ولا يلزم تكرار الشرح المطول من الخارطة.
يشار إلى البند الأصلي بواسطة ROADMAP_REF.

لكل مهمة:

TASK_ID=
ROADMAP_REF=
TITLE=
STATUS=
DEPENDENCIES=
OWNER_DECISION_REQUIRED=
ACCEPTANCE_CRITERIA=
VERIFICATION_EVIDENCE=
BLOCKED_REASON=
UNBLOCK_REQUIREMENT=
LAST_UPDATED=
NOTES=

الحالات:

NOT STARTED
IN PROGRESS
BLOCKED
VERIFIED
CLOSED
REOPENED

الحالة الأولية لكل المهام غير المنفذة:

NOT STARTED

VERIFIED:
تم التنفيذ وتوفرت أدلة التحقق المطلوبة.

CLOSED:
استوفت المهمة عقدها ومعيار قبولها ولا يوجد مانع معروف داخل نطاقها.

BLOCKED:
يوجد مانع محدد يمنع الاستمرار.
يجب كتابة BLOCKED_REASON وUNBLOCK_REQUIREMENT.

REOPENED:
ظهر Regression (تراجع/كسر) مثبت أو دليل جديد ينقض إغلاق المهمة.

لا تغلق مهمة لمجرد كتابة الكود.

══════════════════════════════════════════════════════════════
[6] قاعدة الاختبار المصاحب لكل تنفيذ
══════════════════════════════════════════════════════════════

الاختبار لا يؤجل لنهاية المشروع.

كل مهمة بناء، بحسب طبيعتها، يجب أن تشمل أثناء تنفيذها:

1. اختبار قاعدة الأعمال المتأثرة.
2. اختبار Database Constraints.
3. Unit Tests.
4. Service Tests.
5. API Tests.
6. Authorization Tests.
7. Transaction Tests.
8. Idempotency Tests.
9. Concurrency Tests عند انطباقها.
10. Flutter Widget/Integration Tests عند انطباقها.
11. Live Verification عند الحاجة.

المراحل النهائية للاختبار لا تستبدل الاختبارات المصاحبة.

هي للتحقق التجميعي النهائي بعد نجاح المكونات منفردة.

══════════════════════════════════════════════════════════════
[7] عقد دورة الوحدة من البداية للنهاية
══════════════════════════════════════════════════════════════

أي وحدة أعمال لا تعتبر مكتملة بنجاح Backend وحده.

عند انطباق المكونات، دورة التنفيذ هي:

DATABASE
→ BACKEND DOMAIN/SERVICE
→ API
→ FLUTTER
→ PERMISSIONS
→ AUDIT
→ FINANCIAL EFFECT
→ MESSAGING
→ TESTS
→ LIVE VERIFICATION

نجاح API وحده لا يغلق شاشة أعمال مطلوبة.

نجاح Flutter شكليًا لا يغلق Backend غير صحيح.

══════════════════════════════════════════════════════════════
[8] حدود المرحلة الأولى
══════════════════════════════════════════════════════

IN SCOPE:

- العملاء.
- الأكوات.
- التسليم.
- الأسعار الشهرية.
- السحوبات.
- الحسابات.
- الموظفون.
- أجر القطعة.
- الراتب.
- الإنتاج اليومي.
- المصروف.
- مهلة 24 ساعة.
- التسويات.
- الذمم.
- الاسترداد.
- الموردون.
- المواد.
- الوحدات.
- الفواتير.
- الدفعات.
- التخصيصات.
- الرسائل.
- الكشوف.
- الصلاحيات.
- Audit.
- المرفقات.
- النسخ والاستعادة.
- الوصول الآمن.

OUT OF SCOPE:

- Inventory.
- Material Consumption.
- Manufacturing Cost.
- Attendance.
- Absence Deduction.
- Taxes.
- Rent.
- Electricity.
- Maintenance.
- Comprehensive Accounting.
- Profit & Loss شامل.

FUTURE:

- ربط الموظف بالكوت.
- Barcode.
- QR.
- Scanner.
- Production Stage Tracking.
- Offline First إذا تم اعتماده مستقبلًا.

══════════════════════════════════════════════════════════════
[9] بوابات قرارات المالك
══════════════════════════════════════════════════════════════

ممنوع افتراض القرارات التالية.

OWNER-DECISION-001 — أهداف Flutter

يحدد المالك:
- Web؟
- Windows؟
- Android؟
- أكثر من هدف؟

ذكر الوصول بالهاتف لا يساوي تلقائيًا قرار بناء Android أصلي.

OWNER-DECISION-002 — نظام تشغيل سيرفر الإنتاج

يحدد:
Ubuntu Server LTS
أو Windows Server
أو بديل معتمد.

D:\YASIN_WORKSHOP مسار المصدر الحالي ولا يفرض نظام تشغيل الإنتاج.

OWNER-DECISION-003 — وحدة إنتاج موظف القطعة

هل:
سجل واحد لكل Employee + WorkDate

أم:
عدة سجلات يجمعها النظام؟

ثابت في الحالتين:
الإنتاج عدد فقط ولا يرتبط بالعميل أو الكوت.

OWNER-DECISION-004 — وقت إثبات الراتب الشهري

يحدد متى يصبح راتب الشهر مستحقًا ماليًا وقابلًا للمقاصة والاسترداد.

ممنوع افتراض:
- استحقاق يومي.
- خصم غياب.
- احتساب جزء شهر.

OWNER-DECISION-005 — توريث شروط الموظف

يحسم:
- أول شهر.
- الأشهر المتخطاة.
- التوقف ثم العودة.
- أثر تصحيح سعر شهر سابق على الشهور التي سبق أن ورثت منه.

OWNER-DECISION-006 — سعر العميل المفقود

A:
منع حفظ دفعة الأكوات حتى يوجد السعر.

أو:

B:
السماح بالتسجيل التشغيلي مع عدم اعتبار القيمة المالية مؤكدة حتى التسعير.

لا يرث العميل السعر السابق تلقائيًا.

OWNER-DECISION-007 — شكل التقارير وإعادة الإصدار

- PDF؟
- Print؟
- Download؟
- أكثر من شكل؟
- هل النسخة المصححة ترسل تلقائيًا أم بعد اعتماد؟

OWNER-DECISION-008 — تصحيحات العملاء والموردين

يحسم عقد:
- تعديل اسم صاحب الكوت.
- تعديل Page Number.
- تعديل Entry Date.
- تصحيح Customer Withdrawal.
- تصحيح Supplier Invoice.
- تصحيح Supplier Payment.
- الإلغاء.
- الرسائل التصحيحية المطلوبة.

OWNER-DECISION-009 — دفعة المورد غير المخصصة

هل:
- تبقى Supplier Advance؟
- توزع بالأقدم؟
- قاعدة أخرى؟

OWNER-DECISION-010 — ترتيب تغطية عدة ذمم

يحدد قبل تفعيل الاسترداد التلقائي.

OWNER-DECISION-011 — RPO / RTO

RPO:
أقصى فقد بيانات مقبول.

RTO:
المدة المستهدفة لإعادة الخدمة.

OWNER-DECISION-012 — معايير الأداء

تحدد وفق حجم الاستخدام المتوقع قبل Performance Acceptance.

OWNER-DECISION-013 — تاريخ دفعة الأكوات

يُحسم:

هل لجميع أكوات الدفعة Entry Date واحد موروث من Coat Batch؟

أم يسمح لكل Coat بتاريخ مستقل؟

توصية التصميم غير الملزمة:
تاريخ واحد للدفعة وجميع أكواتها، وأي أكوات بتاريخ آخر تدخل دفعة أخرى.

لا تصبح هذه التوصية قاعدة أعمال حتى يعتمدها المالك.

OWNER-DECISION-014 — سياسة الكشف الصفري والرسائل الفائتة

يحدد:
- هل يرسل الكشف الصفري؟
- ماذا يحدث لكشف فات موعده بسبب توقف السيرفر؟
- هل يعاد إصداره تلقائيًا؟
- هل يحتاج اعتمادًا؟

OWNER-DECISION-015 — مدة مراقبة ما بعد Go-Live

لا تفترض مدة الآن.
تحدد بالاتفاق مع المالك قبل بدء التشغيل.

══════════════════════════════════════════════════════════════
PHASE 1 — تثبيت العقود والمراجع
══════════════════════════════════════════════════════════════

1.1 تثبيت BUSINESS REQUIREMENTS.

1.2 تثبيت PERMANENT DEVELOPMENT POLICY.

1.3 تثبيت MASTER ROADMAP R3.

1.4 إنشاء TASK REGISTER.

1.5 إنشاء DECISION LOG.

1.6 تحديد ملفات المصفوفات المركزية.

1.7 استخراج Business Rules.

1.8 منح كل قاعدة معرف BR-ID.

1.9 إنشاء REQUIREMENTS TEST MATRIX.

1.10 ربط كل Business Rule باختبار قبول.

1.11 تثبيت المصطلحات.

1.12 تثبيت التواريخ.

1.13 تثبيت Year + Month.

1.14 تثبيت Money Decimal Policy.

1.15 تثبيت Cancellation/No-Hard-Delete contract.

1.16 تثبيت Idempotency contract.

1.17 تثبيت Concurrency contract.

1.18 تثبيت Correction/Reversal contract.

1.19 حصر OWNER DECISIONS.

1.20 حجب الجزء المتأثر فقط، وليس المشروع كله، عند وجود قرار غير محسوم.

ACCEPTANCE:
لا توجد قاعدة أعمال مطلوبة للمرحلة التالية تم اختراعها أو افتراضها.

══════════════════════════════════════════════════════════════
PHASE 2 — المعمارية وأهداف التشغيل
══════════════════════════════════════════════════════

2.1 حسم Flutter targets اللازمة للبدء.

2.2 حسم بيئة Server المطلوبة قبل الجزء المتأثر.

2.3 اعتماد Backend architecture.

المرشح:
Django + API.

Database Engine Selected:
Microsoft SQL Server.

2.4 Microsoft SQL Server.

2.5 Flutter.

2.6 Background jobs:
Celery/Redis أو بديل أنسب مثبت.

2.7 Reverse Proxy:
Nginx أو المناسب للبيئة.

2.8 Deployment architecture.

2.9 WhatsApp architecture.

2.10 فصل Source عن Runtime Data.

2.11 Development Environment.

2.12 Test Environment.

2.13 Production design.

2.14 Secrets strategy.

2.15 Logging strategy.

2.16 Monitoring strategy.

2.17 Deployment strategy.

2.18 Upgrade strategy.

2.19 Rollback strategy.

2.20 Architecture Decision Records.

══════════════════════════════════════════════════════════════
PHASE 3 — تصميم قاعدة البيانات
══════════════════════════════════════════════════════

تصميم ERD أولًا.

الجداول الأساسية المتوقعة:

app_settings

users
roles
permissions
user_roles
role_permissions

customers
customer_month_prices
coat_batches
coats
coat_status_events
customer_withdrawals

employees
employee_month_terms
employee_daily_status
employee_production_entries
employee_cash_entries
employee_settlements
employee_settlement_allocations
employee_debts
employee_debt_recoveries

suppliers
units
materials
purchase_invoices
purchase_invoice_lines
supplier_payments
supplier_payment_allocations

financial_postings

audit_log

message_templates
message_outbox
message_attempts
report_dispatches

attachments
backup_runs

وأي جداول تقنية يثبت التصميم حاجتها.

3.1 PK.

3.2 FK.

3.3 Unique constraints.

3.4 Check constraints.

3.5 Indexes.

3.6 Decimal precision.

3.7 operation_date.

3.8 created_at.

3.9 updated_at.

3.10 created_by.

3.11 updated_by.

3.12 first_saved_at.

3.13 Cancellation metadata.

3.14 Revision/version.

3.15 Idempotency records.

3.16 Document numbers.

3.17 لا أسماء كمفاتيح رسمية.

3.18 Page Number ليس Coat ID.

3.19 Orphan prevention.

3.20 Balances مشتقة من مصادرها وليس إدخالًا يدويًا نهائيًا.

3.21 Migration strategy.

3.22 Constraint tests.

3.23 تصميم Concurrency المناسب.

3.24 مراجعة ERD قبل التنفيذ.

══════════════════════════════════════════════════════════════
PHASE 4 — تأسيس بيئة التطوير وBackend وقواعد الاختبار
══════════════════════════════════════════════════════

هذه مرحلة مضافة إلزاميًا قبل الخدمات المشتركة.

4.1 إنشاء Backend project الرسمي بعد اعتماد التقنية.

4.2 إنشاء Development configuration.

4.3 إنشاء Test configuration.

4.4 إعداد Microsoft SQL Server Development database.

4.5 إعداد Microsoft SQL Server Test database منفصلة.

4.6 إعداد Database connection بصورة آمنة.

4.7 إنشاء Migration foundation.

4.8 تشغيل أول Migration تأسيسية عند اعتماد التصميم.

4.9 تهيئة Test framework.

4.10 تهيئة API test infrastructure.

4.11 تهيئة Database integration test infrastructure.

4.12 تهيئة Environment variables.

4.13 منع Production secrets من بيئة التطوير.

4.14 Health bootstrap.

4.15 إثبات Backend startup.

4.16 إثبات Test database isolation.

4.17 توثيق أوامر البناء والاختبار الرسمية.

ACCEPTANCE:
Backend قابل للبناء والتشغيل واختبار قاعدة مستقلة دون لمس Production.

══════════════════════════════════════════════════════════════
PHASE 5 — الأساسات المشتركة
══════════════════════════════════════════════════════

5.1 Authentication.

5.2 Authorization.

5.3 Users/Roles/Permissions.

5.4 Server Clock.

5.5 Timezone.

5.6 Year-Month.

5.7 Money.

5.8 Transaction Management.

5.9 Idempotency.

5.10 Optimistic Concurrency.

5.11 Version Conflict.

5.12 Locking للعمليات الحرجة.

5.13 Audit Foundation.

5.14 Financial Posting Foundation.

5.15 Reversal/Correction Foundation.

5.16 Messaging Outbox Foundation.

5.17 Background Jobs Foundation.

5.18 Durable jobs/history.

5.19 Attachment Foundation.

5.20 Error Handling.

5.21 Logging.

5.22 Observability.

5.23 Health Checks.

5.24 API conventions.

5.25 Numbering foundation.

5.26 Transaction rollback tests.

5.27 Concurrency base tests.

5.28 Authorization base tests.

5.29 Idempotency base tests.

ممنوع بناء نسخة مؤقتة من Audit أو Financial Posting أو Outbox
ثم استبدالها بعد بناء وحدات الأعمال.

══════════════════════════════════════════════════════════════
PHASE 6 — المحرك المالي التشغيلي
══════════════════════════════════════════════════════

ليس نظام محاسبة شاملًا.

أنواع الحركات المطلوبة تشمل حسب العقود النهائية:

Customer Work Accrual
Customer Withdrawal
Employee Piece Earning
Employee Salary Entitlement
Employee Cash Expense/Advance
Employee Internal Settlement
Employee Cash Settlement
Employee Debt Creation
Employee Debt Recovery
Supplier Invoice Liability
Supplier Payment
Supplier Advance
Reversal
Correction

لكل Posting:

- type.
- source.
- source ID.
- operation date.
- year/month عند الحاجة.
- amount.
- direction.
- creator.
- created time.
- status.
- reversal reference.

6.1 تحديد الاستحقاق.

6.2 الحركة النقدية.

6.3 المقاصة.

6.4 الذمة.

6.5 اشتقاق الرصيد.

6.6 منع Duplicate Posting.

6.7 Reversal يحافظ على الأصل.

6.8 Reconciliation بين Business Records وFinancial Postings.

6.9 إظهار أي انحراف.

6.10 عدم إنشاء P&L شامل.

6.11 Unit tests.

6.12 Transaction tests.

6.13 Reversal tests.

6.14 Idempotency tests.

══════════════════════════════════════════════════════════════
PHASE 7 — سجل المراجعة والتصحيح
══════════════════════════════════════════════════════

7.1 Actor.
7.2 Entity.
7.3 ID.
7.4 Action.
7.5 Time.
7.6 Before.
7.7 After.
7.8 Reason.
7.9 Correlation ID.
7.10 Cancellation.
7.11 Edit.
7.12 Price changes.
7.13 Restricted corrections.
7.14 Settlements.
7.15 Permission changes.
7.16 Immutable/protected audit behavior.
7.17 API audit verification.
7.18 Audit tests.

واجهة عرض Audit يمكن استكمالها في الإدارة،
لكن تسجيل Audit يجب أن يسبق وحدات الأعمال.

══════════════════════════════════════════════════════════════
PHASE 8 — أساس Flutter والهوية
══════════════════════════════════════════════════════

بعد اعتماد Flutter Target المطلوب.

8.1 إنشاء Flutter project.

8.2 Design System.

8.3 Arabic RTL.

8.4 Light Mode.

8.5 Dark Mode.

8.6 Typography.

8.7 Colors.

8.8 Components.

8.9 Responsive.

8.10 Workspace Manager.

8.11 Internal Taskbar على الأجهزة المناسبة.

8.12 Open Screen.

8.13 Activate Screen.

8.14 Close Screen.

8.15 Unsaved Changes Guard.

8.16 Screen State Preservation.

8.17 Back/Forward.

8.18 Mouse Side Buttons.

8.19 Touch alternatives.

8.20 Keyboard navigation.

8.21 Enter navigation.

8.22 Focus management.

8.23 Zoom 10%–150%.

Desktop controls:

Ctrl + Mouse Wheel
Ctrl + Plus
Ctrl + Minus

8.24 Zoom للمحتوى وليس Scale أعمى للنافذة.

8.25 التصغير يزيد كثافة المحتوى الفعلية عند ملاءمة التصميم.

8.26 لا يفقد أي مستوى Zoom وظيفة أساسية.

8.27 Minimum interactive usability.

8.28 API client.

8.29 Authentication State.

8.30 Permission Guards.

8.31 Loading.

8.32 Empty.

8.33 Error.

8.34 Retry.

8.35 Pagination foundation.

8.36 Search debouncing.

8.37 Lazy loading.

8.38 State Management.

8.39 Widget tests.

8.40 Navigation tests.

8.41 Zoom tests.

8.42 Light/Dark tests.

8.43 Screen-state tests.

══════════════════════════════════════════════════════════════
PHASE 9 — الإدارة والمستخدمون
══════════════════════════════════════════════════════

DATABASE/BACKEND:

9.1 Users.
9.2 Roles.
9.3 Permissions.
9.4 Login.
9.5 Logout.
9.6 User disable.
9.7 Session expiry.
9.8 Session revocation.
9.9 Permission changes.
9.10 Admin recovery.
9.11 Support Access.

FLUTTER:

9.12 Login Screen.
9.13 Users Screen.
9.14 Roles Screen.
9.15 Permissions Screen.
9.16 Settings Screen.
9.17 Audit Screen.

TESTS:

9.18 Admin.
9.19 Operator.
9.20 Read-only.
9.21 Direct API authorization.
9.22 Disabled user.
9.23 Session revocation.

══════════════════════════════════════════════════════════════
PHASE 10 — إعدادات النظام والمبالغ والزمن
══════════════════════════════════════════════

10.1 Workshop name.

10.2 Currency.

10.3 Decimal precision.

10.4 Timezone.

10.5 Week start.

10.6 Weekly dispatch time.

10.7 Monthly dispatch time.

10.8 Zero-statement policy.

10.9 Missed-job policy.

10.10 Report reissue policy.

10.11 Backup policy.

10.12 WhatsApp settings foundation.

10.13 Rounding rules.

قواعد لازمة:

- الكمية غير سالبة.
- Unit Price غير سالب.
- المبلغ المالي المدخل غير سالب إلا إذا العقد يعرف حركة عكس مستقلة.
- Balance الناتج يمكن أن يكون سالبًا.
- Financial Payment بمبلغ صفر لا يعتبر دفعة مالية حقيقية إلا إذا كان
هناك عقد أعمال صريح يسمح بذلك.
- Confirmed Zero في يوم الموظف حالة تأكيد وليست Payment=0.

10.14 تعريف كيفية تقريب Line Total.

10.15 تعريف كيفية تقريب Invoice Total.

10.16 عدم السماح بتغيير Currency بعد وجود حركات مالية كإعداد عادي.

10.17 تغيير Timezone بعد وجود عمليات يحتاج حماية وأثرًا واضحًا ولا يغير
المعنى التاريخي للعمليات بصمت.

══════════════════════════════════════════════════════════════
PHASE 11 — العملاء والأسعار
══════════════════════════════════════════════════════════════

BACKEND/DB:

11.1 Customer ID.
11.2 Name.
11.3 Contact.
11.4 WhatsApp.
11.5 Active/Archived.
11.6 Notes.
11.7 Messaging settings.
11.8 Search.
11.9 Month Price.
11.10 Customer+Year+Month unique.
11.11 لا توريث تلقائي.
11.12 Current month price.
11.13 Price update.
11.14 Impact Preview.
11.15 Month recalculation.
11.16 Missing Price Contract.

FLUTTER:

11.17 Customer List Screen.
11.18 Customer Search.
11.19 Customer Card.
11.20 Add Customer.
11.21 Edit Customer.
11.22 Archive Customer.
11.23 Monthly Price Screen.
11.24 Price Impact Confirmation.

TESTS:
11.25 Multiple customers.
11.26 Similar names/different IDs.
11.27 Different prices.
11.28 Month independence.

══════════════════════════════════════════════════════════════
PHASE 12 — الأكوات والدفعات
══════════════════════════════════════════════════════

يتوقف الجزء التاريخي المطلوب على OWNER-DECISION-013.

BACKEND/DB:

12.1 Coat Batch.
12.2 Customer.
12.3 Entry Date contract.
12.4 Bulk Create.
12.5 Permanent Coat ID.
12.6 Owner Name.
12.7 Page Number composite-capable.
12.8 Page Number not globally unique.
12.9 Batch count from saved coats.
12.10 Status.
12.11 Status Events.
12.12 Cancellation.
12.13 Audit.

FLUTTER:

12.14 Register Coat Batch Screen.

12.15 Dynamic multiple coat rows.

12.16 Owner names.

12.17 Page numbers.

12.18 Notes.

12.19 Validation.

12.20 Save once.

12.21 Prevent accidental duplicate save.

12.22 Coat List/Tracking Screen.

12.23 Search/filter by customer/status/date.

TESTS:

12.24 Multiple batches same day.
12.25 Composite Page Number.
12.26 Duplicate request.
12.27 Missing-price behavior.
12.28 Date contract.

══════════════════════════════════════════════════════════════
PHASE 13 — الأكوات والتسليم والتصحيح
══════════════════════════════════════════════════════

13.1 داخل المعمل.
13.2 قيد الخياطة.
13.3 مكتمل.
13.4 مسلم.
13.5 ملغى بسبب خطأ إدخال.

13.6 Partial Delivery.

13.7 Delivery Date.

13.8 Delivered By.

13.9 Delivery does not remove customer accrual.

13.10 Accrual occurs at entry.

13.11 Cancellation reduces count/value.

13.12 Cancellation history preserved.

13.13 Correction according to OWNER-DECISION-008.

FLUTTER:

13.14 Coat Tracking Screen.
13.15 Delivery Screen.
13.16 Partial Delivery selection.
13.17 Cancellation/Correction UI.
13.18 History UI.

TESTS:

13.19 Partial delivery.
13.20 Full delivery.
13.21 Cancellation.
13.22 Cancellation after message.
13.23 Historical integrity.

══════════════════════════════════════════════════════════════
PHASE 14 — سحوبات العملاء والحساب
══════════════════════════════════════════════════════

14.1 Independent withdrawal.

14.2 Multiple withdrawals same day.

14.3 Operation Number.

14.4 Operation Date.

14.5 Amount.

14.6 User/time.

14.7 Idempotency.

14.8 Work Value =
Non-cancelled coats of month × Month Price.

14.9 Remaining =
Work Value − Non-cancelled withdrawals.

14.10 Month independence.

14.11 No automatic carry-forward.

FLUTTER:

14.12 Customer Withdrawal Screen.
14.13 Withdrawal History.
14.14 Customer Monthly Statement Screen.
14.15 Multi-month view without merging months.
14.16 Customer Correction History.

TESTS:

14.17 Day 31.
14.18 February.
14.19 Year boundary.
14.20 Multiple withdrawals.
14.21 Repricing.

══════════════════════════════════════════════════════════════
PHASE 15 — الموظفون وشروط الأجر
══════════════════════════════════════════════════════

15.1 Employee ID.
15.2 Name.
15.3 Phone.
15.4 WhatsApp.
15.5 Piece Wage.
15.6 Monthly Salary.
15.7 Initial Term.
15.8 Start Date.
15.9 End Date.
15.10 Active/Stopped/Archived.
15.11 No hard delete with financial history.
15.12 Employee Month Terms.
15.13 Year+Month.
15.14 Inheritance.
15.15 Historical Rate.

قاعدة الشهر الجاري:

15.16 السعر/الراتب الموروث للشهر الجاري قابل للتعديل.

15.17 تعديل سعر قطعة الشهر الجاري يعيد حساب جميع إنجازات ذلك الشهر.

15.18 تعديل راتب الشهر الجاري يعيد حساب استحقاق الشهر وفق عقد الراتب.

15.19 قيد 24 ساعة لا ينطبق على سعر/راتب الموظف.

15.20 قيد 24 ساعة يخص Production/Cash Entry فقط.

15.21 تصحيح سعر/راتب شهر سابق عملية مختلفة تحتاج صلاحية وعقد تصحيح
وتدقيق ولا يعامل كتعديل عادي للشهر الجاري.

15.22 لا تتغير الأشهر اللاحقة بصمت.

FLUTTER:

15.23 Employee List.
15.24 Employee Card.
15.25 Add/Edit.
15.26 Archive/Stop.
15.27 Monthly Terms Screen.
15.28 Terms History.

══════════════════════════════════════════════════════════════
PHASE 16 — اليوم والإنتاج والمصروف والإجازة
══════════════════════════════════════════════════════

يطبق OWNER-DECISION-003.

16.1 Production Confirmation مستقل.

16.2 Cash Confirmation مستقل.

16.3 Cash entry لا يؤكد Production=0.

16.4 Production entry لا يؤكد Cash=0.

16.5 Missing Production.

16.6 Missing Cash.

16.7 Missing Both.

16.8 Explicit Confirmed Zero.

16.9 Leave.

16.10 Future dates not missing.

16.11 Salary Employee Production = Not Applicable.

16.12 Piece Production = count only.

16.13 No coat/customer link.

16.14 No count reconciliation with customer coats.

16.15 Multiple cash entries per day allowed.

16.16 Leave + cash allowed.

16.17 Leave does not create salary deduction.

قاعدة مهمة:

16.18 Missing value يعامل صفرًا مؤقتًا في الحساب.

16.19 Missing=0 حسابيًا لا يعني Confirmed Zero.

16.20 يبقى Missing Indicator ظاهرًا حتى التأكيد.

16.21 تغيير Leave أو Zero Confirmation الذي يؤثر في Production محفوظ سابقًا
لا يجوز استخدامه لتجاوز قيد التصحيح.

16.22 Expected days محسوبة ضمن فترة عمل الموظف المعتمدة فقط.

FLUTTER:

16.23 Employee Daily Grid Screen.
16.24 Missing indicators.
16.25 Production entry.
16.26 Cash entry.
16.27 Explicit zero confirmation.
16.28 Leave action.
16.29 Historical entry.
16.30 Clear differentiation between production and cash completion.

══════════════════════════════════════════════════════════════
PHASE 17 — مهلة 24 ساعة
══════════════════════════════════════════════════════

تخص فقط:
employee_production_entries
employee_cash_entries

17.1 first_saved_at.

17.2 24h server time.

17.3 لا تبدأ من Work Date.

17.4 لا تتجدد.

17.5 Normal correction within window.

17.6 Audit داخل window.

17.7 Restricted correction after window.

17.8 Reason required.

17.9 Before/After.

17.10 Recalculate impact.

ANTI-BYPASS:

17.11 Client clock irrelevant.
17.12 Direct API cannot bypass.
17.13 Work Date change cannot bypass.
17.14 Cancel/recreate cannot bypass.
17.15 Duplicate replacement cannot bypass.

17.16 Truly missing historical record can be first-created later.

17.17 New record cannot hide modification of existing record.

TESTS:
17.18 Exact boundary.
17.19 Before boundary.
17.20 After boundary.
17.21 Admin correction.
17.22 Anti-bypass.

══════════════════════════════════════════════════════════════
PHASE 18 — استحقاق الموظف والحساب الشهري
══════════════════════════════════════════════════════

Piece:

Entitlement =
Month Production × Month Piece Rate

Salary:

Entitlement =
Monthly Salary وفق OWNER-DECISION-004

18.1 Monthly cash.

18.2 Balance before settlement.

18.3 Positive = للموظف.

18.4 Negative = على الموظف.

مهم جدًا:

18.5 يسمح للمصروف اليومي بتجاوز استحقاق الموظف.

18.6 هذا ينتج Monthly Negative Balance.

18.7 لا يمنع النظام هذا السالب لمجرد أن السحب تجاوز المستحق.

18.8 السالب الشهري ليس Debt مستقلة تلقائيًا.

18.9 Months remain independent.

18.10 Daily cash belongs to operation month.

18.11 Old month entitlement payment is settlement, not current-month cash expense.

FLUTTER:

18.12 Employee Monthly Statement.
18.13 Production breakdown.
18.14 Cash breakdown.
18.15 Entitlement.
18.16 Balance.
18.17 Settlement section.
18.18 Debt section.

══════════════════════════════════════════════════════════════
PHASE 19 — التسويات والذمم
══════════════════════════════════════════════════════

التمييز الإلزامي:

A — Internal Month Offset.
B — Cash Payment To Employee.
C — Cash Collection From Employee.
D — Debt Creation/Recovery.

19.1 Settlement Preview.

19.2 Identify negative months.

19.3 Find available positive balances.

19.4 Oldest positive first.

19.5 Allocation.

19.6 Allocation cannot exceed available settlement balance.

19.7 Concurrency lock.

19.8 Remaining deficit after approved settlement becomes Debt.

قاعدة جوهرية:

19.9 Monthly negative balance is NOT automatically a second Debt record.

19.10 Debt تنشأ فقط خلال عقد التسوية المعتمد، وبعد تطبيق الأرصدة الموجبة
القابلة للاستخدام.

19.11 فقط العجز غير المغطى يتحول إلى Debt.

19.12 لا يحمل Monthly Open Balance وDebt المبلغ نفسه مرتين.

19.13 Original Debt.

19.14 Recovered.

19.15 Remaining.

19.16 Status.

19.17 Origin.

FLUTTER:

19.18 Settlement Screen.
19.19 Preview allocations.
19.20 Approval Screen.
19.21 Debt Screen.
19.22 Debt History.
19.23 Recovery History.

══════════════════════════════════════════════════════════════
PHASE 20 — الاسترداد التلقائي
══════════════════════════════════════════════════════

20.1 يعمل فقط على Open Debt المعتمدة.

20.2 لا يعمل على كل Monthly Negative Balance تلقائيًا.

20.3 عند توفر Positive Balance بحسب العقد، تقيم الذمة قبل السماح باستهلاك
الرصيد نفسه مرتين.

20.4 Debt ordering حسب OWNER-DECISION-010.

20.5 Partial Recovery.

20.6 Full Recovery.

20.7 Recovery not Cash Expense.

20.8 Idempotency.

20.9 Concurrency.

20.10 لا يخصص/يسترد الرصيد نفسه أكثر من مرة.

20.11 المصروف اليومي يبقى مسموحًا له بتكوين رصيد شهري سالب وفق العقد.

20.12 المقاصة والاسترداد لا يستهلكان مبلغًا أكبر من الرصيد القابل لهما.

══════════════════════════════════════════════════════════════
PHASE 21 — التصحيح التاريخي ومصفوفة الأثر
══════════════════════════════════════════════════════

الملف الرسمي:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_CORRECTION_IMPACT_MATRIX.md

لكل تصحيح حدد أثره على:

- Original record.
- Entitlement.
- Monthly Balance.
- Financial Postings.
- Settlement.
- Debt.
- Recovery.
- Cash Payment.
- Report Version.
- Messages.

21.1 Production correction.

21.2 Cash correction.

21.3 Piece Rate correction.

21.4 Salary correction.

21.5 Late production addition.

21.6 Late cash addition.

حالة إلزامية:

إضافة مصروف لم يكن مسجلًا لشهر سبق:
- تسويته،
أو
- إصدار كشفه،
أو
- إنشاء ذمة منه،
أو
- دفع جزء منه.

يجب:

21.7 Recalculate.

21.8 Re-evaluate balance.

21.9 Re-evaluate settlement/debt.

21.10 Preserve actual cash payment.

21.11 لا تمحو دفعة نقدية حقيقية.

21.12 إنشاء فرق أو تصحيح قابل للتدقيق.

21.13 Report re-versioning.

21.14 لا حذف للتاريخ.

21.15 No duplicate recovery.

══════════════════════════════════════════════════════════════
PHASE 22 — إصدارات الكشوف
══════════════════════════════════════════════════════

لا يوجد Month Lock يمنع إضافة سجل مفقود.

يفصل بين:

DATA PERIOD
REPORT VERSION
SETTLEMENT STATE

22.1 Late missing operations allowed per contract.

22.2 Recalculate.

22.3 Old report preserved.

22.4 New version.

22.5 Issue time.

22.6 Issued by.

22.7 Reason when needed.

22.8 Resend according to OWNER-DECISION-007/014.

══════════════════════════════════════════════════════════════
PHASE 23 — الموردون والمواد
══════════════════════════════════════════════════════

BACKEND/DB:

23.1 Supplier ID.
23.2 Name.
23.3 WhatsApp.
23.4 Contact.
23.5 Notes.
23.6 Active/Archived.

23.7 Material ID.
23.8 Name.
23.9 Default Unit.
23.10 Units configurable.

23.11 لا Inventory Quantity في المرحلة الأولى.

FLUTTER:

23.12 Supplier List.
23.13 Supplier Card.
23.14 Add/Edit/Archive.
23.15 Materials Screen.
23.16 Units Screen.

══════════════════════════════════════════════════════════════
PHASE 24 — فواتير المورد
══════════════════════════════════════════════════════

24.1 Internal Invoice Number.
24.2 Supplier Invoice Number.
24.3 Supplier.
24.4 Date.
24.5 Lines.
24.6 Material.
24.7 Unit.
24.8 Quantity.
24.9 Unit Price.
24.10 Line Total.
24.11 Invoice Total.
24.12 Attachment.
24.13 Notes.

24.14 Initial Paid creates real Supplier Payment.

24.15 Paid is not independent truth outside payment records.

24.16 Duplicate invoice policy.

FLUTTER:

24.17 Create Invoice Screen.
24.18 Dynamic Lines.
24.19 Material selector.
24.20 Unit.
24.21 Quantity.
24.22 Price.
24.23 Line totals.
24.24 Invoice total.
24.25 Initial payment.
24.26 Attachment.
24.27 Validation.

══════════════════════════════════════════════════════════════
PHASE 25 — دفعات المورد وتخصيصها
══════════════════════════════════════════════════════

25.1 Payment Number.
25.2 Supplier.
25.3 Payment Date.
25.4 Amount.
25.5 Notes.
25.6 Creator/time.
25.7 Initial Invoice Payment uses official payment entity.
25.8 One invoice allocation.
25.9 Multi-invoice allocation.
25.10 Allocation <= Payment.
25.11 Allocation rules for invoice remaining.
25.12 Unallocated amount according to OWNER-DECISION-009.
25.13 Correction unallocates with history.
25.14 Reversal.

Supplier Balance =
Non-cancelled invoices − Non-cancelled payments.

25.15 Positive = عليكم للمورد.
25.16 Negative = لكم لدى المورد.
25.17 Zero = متوازن.

FLUTTER:

25.18 Supplier Payment Screen.
25.19 Allocation Screen.
25.20 Allocation Preview.
25.21 Supplier Statement.
25.22 "لكم/عليكم" explicit display.

CONCURRENCY:
25.23 Concurrent allocation cannot reuse same available amount.

══════════════════════════════════════════════════════════════
PHASE 26 — ترقيم المستندات
══════════════════════════════════════════════════════

Contracts for:

26.1 Coat Batch.
26.2 Customer Withdrawal.
26.3 Supplier Internal Invoice.
26.4 Supplier Payment.
26.5 Employee Settlement.
26.6 Debt/Recovery where needed.
26.7 Report Dispatch.

Each defines:

- Prefix.
- Sequence.
- Uniqueness scope.
- Year behavior if applicable.
- Do not reuse cancelled number.

Supplier Invoice External Number != Internal Number.

Page Number != Coat ID.

Document Number != Primary Key.

══════════════════════════════════════════════════════════════
PHASE 27 — المرفقات وأمنها
══════════════════════════════════════════════════════

27.1 Allowed file types.

27.2 Maximum size.

27.3 Validate content/type safely.

27.4 Safe generated storage names.

27.5 Prevent Path Traversal.

27.6 No user-controlled arbitrary filesystem path.

27.7 Entity linkage.

27.8 Upload permission.

27.9 Download permission.

27.10 Delete/cancel policy.

27.11 Logging without leaking sensitive paths/data.

27.12 Backup inclusion.

27.13 Restore test.

══════════════════════════════════════════════════════════════
PHASE 28 — محرك الرسائل
══════════════════════════════════════════════════════

Business operation + required Outbox event must be persisted atomically where
the contract requires both.

28.1 Templates.
28.2 Outbox.
28.3 Attempts.
28.4 Immutable snapshot.
28.5 Event Key.
28.6 Deduplication.
28.7 Pending.
28.8 Sending.
28.9 Provider Accepted.
28.10 Delivered when proven.
28.11 Read when proven.
28.12 Failed.
28.13 Needs Intervention.
28.14 Unknown/Unconfirmed.
28.15 Provider ID.
28.16 Webhook.
28.17 Duplicate webhook.
28.18 Late webhook.
28.19 Retry.
28.20 Backoff.

إذا تعذر إثبات النتيجة الخارجية:
لا يخترع النظام Delivered أو Failed.

28.21 Correction linked to original event.
28.22 Original message content preserved.
28.23 No false Exactly Once claim against external provider guarantees.

══════════════════════════════════════════════════════════════
PHASE 29 — رسائل العملاء
══════════════════════════════════════════════════════

29.1 Batch message.
29.2 Customer.
29.3 Date.
29.4 This Batch Count.
29.5 Names.
29.6 Page Numbers.
29.7 Operation Reference.

29.8 Withdrawal message.
29.9 Date.
29.10 Operation Amount.
29.11 Operation Number.
29.12 Optional Daily Total clearly labeled.

29.13 Cancellation correction.
29.14 Origin reference.
29.15 Cancelled coats.
29.16 Account impact.

29.17 Monthly Summary.
29.18 Year/month.
29.19 Coats.
29.20 Price.
29.21 Work value.
29.22 Withdrawals.
29.23 Remaining.

لا Daily Summary للعملاء في العقد الحالي.

══════════════════════════════════════════════════════════════
PHASE 30 — رسائل الموظفين
══════════════════════════════════════════════════════

30.1 Weekly Summary.
30.2 Period.
30.3 Daily cash.
30.4 Total cash.
30.5 Piece Production.
30.6 Optional clearly-defined earnings/balance when contract permits.

30.7 Monthly Statement.
30.8 Wage Type.
30.9 Rate/Salary.
30.10 Production.
30.11 Entitlement.
30.12 Cash.
30.13 Settlements.
30.14 Debt Recoveries.
30.15 Final Balance.
30.16 Remaining Debt.

لا automatic message لكل مصروف موظف.

Schedule activation depends on configured operational settings.

══════════════════════════════════════════════════════════════
PHASE 31 — رسائل الموردين
══════════════════════════════════════════════════════

Invoice message:
31.1 Number.
31.2 Date.
31.3 Total.
31.4 Paid.
31.5 Remaining.
31.6 Supplier Balance.

Payment message:
31.7 Number.
31.8 Payment Date.
31.9 Amount.
31.10 Balance.
31.11 لكم/عليكم.

31.12 Initial payment messaging must not imply two payments.

══════════════════════════════════════════════════════════════
PHASE 32 — التقارير القابلة للتسليم
══════════════════════════════════════════════════════

After OWNER-DECISION-007:

32.1 Customer Monthly Statement.

32.2 Employee Monthly Statement.

32.3 Employee Multi-Month Statement with months remaining independently detailed.

32.4 Supplier Statement.

Each report as applicable:
- Entity.
- Period.
- Issue time.
- Version.
- Operations.
- Totals.
- Balance direction.

If PDF/Print:
- Arabic.
- RTL.
- Page numbering.
- No clipped columns.
- Branding.
- Print/download verification.

══════════════════════════════════════════════════════════════
PHASE 33 — المهام الخلفية
══════════════════════════════════════════════════════

تشغيل الجدولة الفعلية يتطلب إعداد:

- Currency where relevant.
- Timezone.
- Week Start.
- Weekly Time.
- Monthly Time.
- Zero Statement Policy.
- Missed Jobs Policy.
- Reissue Policy.

33.1 Month Term generation.
33.2 Missing indicators.
33.3 Weekly reports.
33.4 Monthly reports.
33.5 Message retry.
33.6 Backups.
33.7 Monitoring.
33.8 Prevent duplicate job.
33.9 Persistent job identity.
33.10 Catch-up behavior.
33.11 Prevent same report-version dispatch twice.
33.12 Queue system is not sole durable business truth.

══════════════════════════════════════════════════════════════
PHASE 34 — جاهزية WhatsApp
══════════════════════════════════════════════════════

34.1 Sender ownership.
34.2 Official provider integration.
34.3 Secure credentials.
34.4 Webhook.
34.5 Templates.
34.6 Template approval where required.
34.7 Recipient consent requirements.
34.8 Disable messaging per recipient.
34.9 Invalid number handling.
34.10 Isolated testing.
34.11 No real messages without owner approval.
34.12 Provider states.
34.13 Unknown state.
34.14 Retry.
34.15 Duplicate webhook.

══════════════════════════════════════════════════════════════
PHASE 35 — لوحة التحكم
══════════════════════════════════════════════════════

35.1 Today Coats.
35.2 Undelivered.
35.3 Customer Withdrawals.
35.4 Employee Production.
35.5 Employee Cash.
35.6 Missing Days.
35.7 Employee Balances.
35.8 Debts.
35.9 Supplier Balances.
35.10 Failed/Unknown Messages.
35.11 Backup Status.
35.12 Service Status.

PERFORMANCE:
35.13 Summary queries.
35.14 No all-record loading.
35.15 No unsupported P&L.

══════════════════════════════════════════════════════════════
PHASE 36 — السيرفر والعتاد والوصول
══════════════════════════════════════════════════════

نقطة بداية مقترحة:

- Modern multicore CPU.
- 16GB RAM.
- SSD 512GB or greater.
- Separate backup storage.
- Stable internet.
- UPS.

36.1 Production OS.
36.2 Runtime.
36.3 Microsoft SQL Server.
36.4 Workers.
36.5 Reverse Proxy.
36.6 HTTPS.
36.7 Firewall.
36.8 Secure Remote Access.
36.9 No public database.
36.10 Storage monitoring.
36.11 Service monitoring.
36.12 Power/UPS.
36.13 Internet monitoring.
36.14 Service failure alerts.
36.15 Automatic service startup.
36.16 Computer access.
36.17 Phone access.
36.18 Server clock synchronization.
36.19 Log rotation.
36.20 Certificate expiry monitoring/renewal strategy.

حقيقة تشغيلية:
تعطل السيرفر المحلي أو اتصال المعمل قد يوقف Remote Access.

Backup != Failover Server.

Offline First خارج المرحلة الأولى.

══════════════════════════════════════════════════════════════
PHASE 37 — الأمن
══════════════════════════════════════════════════════

37.1 Password hashing.
37.2 HTTPS.
37.3 Session expiry.
37.4 Brute-force protection.
37.5 Server-side authorization.
37.6 Secrets.
37.7 No secrets in Flutter.
37.8 No secrets in logs.
37.9 Audit protection.
37.10 Database least privilege.
37.11 Attachments permissions.
37.12 Report permissions.
37.13 Admin recovery.
37.14 Disable user/session revocation.
37.15 Permission update behavior.
37.16 Support access.
37.17 Revoke support.
37.18 PII/log masking.
37.19 Dependency review.
37.20 Dependency vulnerability/security review appropriate to deployment.
37.21 Ownership transfer.

══════════════════════════════════════════════════════════════
PHASE 38 — النسخ والتعافي
══════════════════════════════════════════════════════

After OWNER-DECISION-011:

38.1 Database backup.
38.2 Attachments.
38.3 Configuration.
38.4 Secure secret recovery.
38.5 Off-system-disk.
38.6 Off-server.
38.7 Off-site.
38.8 Encryption.
38.9 Retention.
38.10 backup_runs.
38.11 Alerts.
38.12 Integrity.
38.13 Restore drill.
38.14 Consistent DB/attachments restore.
38.15 Alternate machine recovery.

After restore:
38.16 No historical message resend.
38.17 No settlement duplication.
38.18 No payment duplication.
38.19 No completed-job duplication.

38.20 Measure restore.
38.21 Verify RPO.
38.22 Verify RTO.

══════════════════════════════════════════════════════════════
PHASE 39 — النشر والترقية والتراجع
══════════════════════════════════════════════════════

39.1 Versioning.
39.2 Staging/Test upgrade.
39.3 Pre-upgrade backup.
39.4 Migration compatibility.
39.5 Backend compatibility.
39.6 Flutter compatibility.
39.7 Worker compatibility.
39.8 Upgrade procedure.
39.9 Post-upgrade verification.
39.10 Failed upgrade handling.
39.11 Rollback.
39.12 Migration forward-fix/rollback.
39.13 Preserve Outbox/jobs.
39.14 Service definitions.
39.15 Upgrade test before production.

══════════════════════════════════════════════════════════════
PHASE 40 — اختبارات التزامن والاعتمادية
══════════════════════════════════════════════════════

40.1 Double Save.
40.2 HTTP Retry.
40.3 Network loss before response.
40.4 Two-user edit.
40.5 Version conflict.
40.6 Concurrent settlement.
40.7 Concurrent supplier allocation.
40.8 Concurrent debt recovery.
40.9 Cash vs recovery race when applicable.

الصياغة الرسمية بدل «عدم تجاوز أي رصيد»:

40.10 منع تخصيص أو استرداد الرصيد نفسه أكثر من مرة، مع السماح للمصروف
اليومي للموظف بتكوين رصيد شهري سالب وفق قاعدة الأعمال.

40.11 المقاصة لا تتجاوز المبلغ الموجب المتاح لها.

40.12 Debt Recovery لا يتجاوز الرصيد المتاح للاسترداد.

40.13 Supplier Allocation لا يتجاوز الجزء القابل للتخصيص.

40.14 Worker restart.
40.15 Redis/queue restart/failure.
40.16 Backend restart.
40.17 SQL Server restart.
40.18 Server restart.
40.19 Duplicate scheduler.
40.20 Duplicate webhook.
40.21 Late webhook.
40.22 Unknown provider outcome.

══════════════════════════════════════════════════════════════
PHASE 41 — اختبارات قبول العملاء
══════════════════════════════════════════════════════

41.1 Multiple customers.
41.2 Similar names/different IDs.
41.3 Different prices.
41.4 Multiple batches.
41.5 Multiple withdrawals.
41.6 Cancellation after message.
41.7 Repricing.
41.8 Partial delivery.
41.9 Month independence.
41.10 Missing price contract.
41.11 Day 31.
41.12 February.
41.13 Year boundary.
41.14 Corrections.
41.15 Message versions.
41.16 Actual Flutter-to-Database flow.

══════════════════════════════════════════════════════════════
PHASE 42 — اختبارات قبول الموظفين
══════════════════════════════════════════════════════

42.1 Piece Employee.
42.2 Salary Employee.
42.3 Inherited terms.
42.4 Current month term modification.
42.5 Recalculation.
42.6 Historical Production.
42.7 Historical Missing Cash Addition.
42.8 Missing Production.
42.9 Missing Cash.
42.10 Confirmed Zero.
42.11 Missing counted as temporary zero.
42.12 Leave + Cash.
42.13 Cash greater than entitlement.
42.14 Negative monthly balance.
42.15 Negative balance not automatically duplicate debt.
42.16 24h.
42.17 No timer renewal.
42.18 Anti-bypass.
42.19 Admin correction.
42.20 Multiple-month settlement.
42.21 Oldest positive.
42.22 Debt creation after settlement.
42.23 Partial recovery.
42.24 Full recovery.
42.25 Historical correction after recovery.
42.26 Already-paid cash + correction.
42.27 No history deletion.
42.28 No duplicate effect.
42.29 Actual Flutter-to-Database flow.

══════════════════════════════════════════════════════════════
PHASE 43 — اختبارات قبول الموردين
══════════════════════════════════════════════════════

43.1 Multi-line invoice.
43.2 Initial payment.
43.3 Later payment.
43.4 Allocation.
43.5 Multi-invoice allocation.
43.6 Advance.
43.7 لكم.
43.8 عليكم.
43.9 Zero.
43.10 Correction.
43.11 Reversal.
43.12 Concurrent allocation.
43.13 No duplicate payment.
43.14 Invoice + initial-payment messaging.
43.15 Rounding.
43.16 Actual Flutter-to-Database flow.

══════════════════════════════════════════════════════════════
PHASE 44 — اختبارات Flutter وتجربة الاستخدام
══════════════════════════════════════════════════════

44.1 Arabic.
44.2 RTL.
44.3 Light.
44.4 Dark.
44.5 Responsive.
44.6 Zoom 10–150%.
44.7 Usable minimum interaction.
44.8 Ctrl+Wheel.
44.9 Ctrl+Plus.
44.10 Ctrl+Minus.
44.11 Enter.
44.12 Mouse Back.
44.13 Mouse Forward.
44.14 Touch alternatives.
44.15 Taskbar.
44.16 Screen preservation.
44.17 Unsaved data.
44.18 Close.
44.19 Screen identity.
44.20 Large data.
44.21 Pagination.
44.22 Search.
44.23 Network errors.
44.24 Error/Retry.

══════════════════════════════════════════════════════════════
PHASE 45 — معايير الأداء
══════════════════════════════════════════════════════

اعتماد Performance Acceptance Profile قبل الاختبار النهائي.

يشمل حجمًا مرجعيًا لـ:
- Customers.
- Coats.
- Employee Operations.
- Invoices.
- Messages.
- Concurrent Users.
- Expected network.

تحدد أهداف قابلة للقياس لـ:

45.1 Login.
45.2 Search.
45.3 Save.
45.4 First page.
45.5 Statement.
45.6 Dashboard.
45.7 Message enqueue.
45.8 Background processing.
45.9 Memory usage with large data.
45.10 Flutter interactivity.

لا تخترع الأرقام الآن.

اعتمدها بناءً على البيئة والاستخدام المتوقع.

══════════════════════════════════════════════════════════════
PHASE 46 — الاختبار الشامل End-to-End
══════════════════════════════════════════════════════

CUSTOMER:

Customer
→ Price
→ Batch
→ Coats
→ Account
→ Withdrawal
→ Delivery
→ Correction
→ Statement
→ Message.

PIECE EMPLOYEE:

Employee
→ Month Rate
→ Production
→ Cash
→ 24h
→ Balance
→ Settlement
→ Debt
→ Recovery
→ Historical Correction
→ Statement.

SALARY EMPLOYEE:

Employee
→ Salary
→ Entitlement
→ Cash
→ Settlement
→ Debt where applicable
→ Statement.

SUPPLIER:

Supplier
→ Invoice
→ Initial Payment
→ Later Payment
→ Allocation
→ Advance
→ Correction
→ Statement
→ Messages.

SYSTEM:

Permissions
→ Audit
→ Messaging
→ Backup
→ Restore
→ Restart
→ Upgrade
→ Recovery.

══════════════════════════════════════════════════════════════
PHASE 47 — التوثيق
══════════════════════════════════════════════════════

47.1 README.
47.2 Business Requirements.
47.3 Permanent Policy.
47.4 Master Roadmap.
47.5 Task Register.
47.6 Decision Log.
47.7 Correction Impact Matrix.
47.8 Requirements Test Matrix.
47.9 Architecture Decisions.
47.10 Architecture Guide.
47.11 Database Schema.
47.12 Migration Guide.
47.13 Backend Guide.
47.14 Flutter Guide.
47.15 API Documentation.
47.16 Deployment Guide.
47.17 Upgrade Guide.
47.18 Rollback Guide.
47.19 Backup Guide.
47.20 Restore Guide.
47.21 Disaster Recovery.
47.22 Permission Matrix.
47.23 Messaging Guide.
47.24 Arabic User Guide.
47.25 Admin Guide.
47.26 Troubleshooting.

══════════════════════════════════════════════════════════════
PHASE 48 — تحقق بيئة الإنتاج الفعلية
══════════════════════════════════════════════════════

نجاح Development/Test لا يثبت Production.

يجب التحقق فعليًا من:

48.1 Production server.
48.2 Production OS.
48.3 Production SQL Server instance.
48.4 Production database identity.
48.5 Migrations applied.
48.6 Backend configuration.
48.7 Flutter production target/build.
48.8 HTTPS.
48.9 Domain/secure access.
48.10 External access.
48.11 Users.
48.12 Roles.
48.13 Permissions.
48.14 Timezone.
48.15 Currency.
48.16 Scheduling.
48.17 Backups.
48.18 Monitoring.
48.19 Workers.
48.20 Outbox.
48.21 Actual WhatsApp sender when approved.
48.22 Approved live message test only with owner permission.
48.23 First production backup.
48.24 Restore-capable verification.
48.25 Service restart behavior.
48.26 Certificate state.
48.27 No production database public exposure.

══════════════════════════════════════════════════════════════
PHASE 49 — موافقة بدء التشغيل
══════════════════════════════════════════════════════

هذه ليست Final Acceptance.

هي GO-LIVE APPROVAL GATE فقط.

قبل طلب موافقة المالك:

49.1 Required contracts resolved.
49.2 No critical blocker.
49.3 Database verified.
49.4 Backend verified.
49.5 Flutter target verified.
49.6 Permissions verified.
49.7 Concurrency verified.
49.8 Financial reconciliation verified.
49.9 Messaging readiness verified.
49.10 Backup verified.
49.11 Restore verified.
49.12 Security verified.
49.13 Performance acceptance passed.
49.14 E2E passed.
49.15 Production environment verified.
49.16 Documentation sufficient for operation.

بعد ذلك فقط:
تطلب OWNER GO-LIVE APPROVAL.

عدم موافقة المالك = لا Go-Live.

══════════════════════════════════════════════════════════════
PHASE 50 — Go-Live والتدريب والمراقبة
══════════════════════════════════════════════════════

بعد موافقة المالك فقط:

50.1 Operational master data.
50.2 User accounts.
50.3 Owner training.
50.4 User training.
50.5 Production backup.
50.6 Go-Live.
50.7 Monitor services.
50.8 Monitor logs.
50.9 Monitor database.
50.10 Monitor messages.
50.11 Monitor jobs.
50.12 Monitor backups.
50.13 Monitor performance.
50.14 Track production defects.
50.15 Fix verified critical/contract defects.
50.16 No uncontrolled scope expansion.

مدة Monitoring Period:
تحدد وفق OWNER-DECISION-015.

معيار انتهاء المراقبة:
يُعتمد مع المالك ولا يخترع مسبقًا.

══════════════════════════════════════════════════════════════
PHASE 51 — القبول والتسليم النهائي
══════════════════════════════════════════════════════

يأتي بعد:
Go-Live
+
Monitoring Period
+
حل الموانع والعيوب الحرجة المطلوبة.

51.1 Source Code.
51.2 DB Schema.
51.3 Migrations.
51.4 Backend.
51.5 Flutter source/targets.
51.6 Deployment definitions.
51.7 Service definitions.
51.8 Documentation.
51.9 Admin ownership.
51.10 Credentials delivered securely.
51.11 WhatsApp ownership.
51.12 Domain/certificate ownership.
51.13 Backup locations.
51.14 Restore material.
51.15 Test/Acceptance results.
51.16 Known limitations.
51.17 Support agreement.
51.18 Revoke support access procedure.
51.19 Data ownership confirmed.
51.20 Final owner acceptance.

لا تعتبر PHASE 49 Final Acceptance.

PHASE 49 = إذن بدء التشغيل.

PHASE 50 = التشغيل والمراقبة.

PHASE 51 = القبول النهائي بعد الواقع التشغيلي.

══════════════════════════════════════════════════════════════
BACKLOG — غير مصرح بتنفيذه حاليًا
══════════════════════════════════════════════════════

FUTURE-001 — Employee-to-Coat linkage.

FUTURE-002 — Barcode.

FUTURE-003 — QR.

FUTURE-004 — Scanner.

FUTURE-005 — Production Stage Tracking.

FUTURE-006 — Inventory.

FUTURE-007 — Material Consumption.

FUTURE-008 — Manufacturing Cost.

FUTURE-009 — Attendance.

FUTURE-010 — Absence Deduction.

FUTURE-011 — Taxes.

FUTURE-012 — Rent/Electricity/Maintenance accounting scope.

FUTURE-013 — Offline First.

STATUS:
DOCUMENTED — NOT AUTHORIZED FOR IMPLEMENTATION

══════════════════════════════════════════════════════════════
قواعد التنفيذ الدائمة للخارطة
══════════════════════════════════════════════════════

1. كل مهمة تنفذ تحت PERMANENT DEVELOPMENT POLICY.

2. لا تغير الخارطة Business Rule بنفسها.

3. لا يفترض المنفذ قرار مالك مفقود.

4. القرار المفقود يحجب الجزء المتأثر فقط عندما يمكن مواصلة أجزاء مستقلة بأمان.

5. الاختبار جزء من تنفيذ كل مرحلة.

6. لا تؤجل جميع الاختبارات للنهاية.

7. كل وحدة أعمال تنفذ من قاعدة البيانات حتى واجهة المستخدم عند انطباق الطبقات.

8. Backend يفرض القواعد الحساسة.

9. Flutter وحده لا يعتبر حماية لقواعد مالية أو صلاحيات.

10. المعرف الرسمي يستخدم بدل الاسم في العلاقات.

11. العمليات المالية والتخصيصات والتسويات تستخدم معاملات واتساقًا مناسبًا.

12. Idempotency لا يحل محل Concurrency.

13. Concurrency لا يحل محل Idempotency.

14. Audit لا يمحى لتسهيل التصحيح.

15. Reversal/Correction يحافظ على التاريخ.

16. لا تستخدم Hard Delete للحركات المالية التاريخية.

17. Missing Employee Entry يمكن أن يساوي صفرًا حسابيًا دون أن يصبح Confirmed Zero.

18. Employee Daily Cash يمكن أن ينتج Monthly Negative Balance.

19. Monthly Negative Balance ليس Debt مستقلة تلقائيًا.

20. Debt تنشأ وفق عقد التسوية فقط.

21. Recovery لا يستهلك الرصيد نفسه مرتين.

22. Supplier allocation لا يستهلك الدفعة نفسها مرتين.

23. لا تحمل الشاشات جميع البيانات مرة واحدة دون ضرورة.

24. الأداء جزء من القبول.

25. Light/Dark/RTL/Zoom/Enter/Taskbar/navigation متطلبات إلزامية وفق السياسة.

26. الهاتف يحصل على بدائل مناسبة للتفاعلات الخاصة بالماوس ولوحة المفاتيح.

27. لا تستخدم Production Data في اختبارات مدمرة.

28. لا ترسل رسالة WhatsApp حقيقية دون موافقة المالك.

29. لا تستخدم Scripts واسعة أو خطرة لتسريع العمل.

30. لا تغير الجهاز أو النظام خارج النطاق.

══════════════════════════════════════════════════════════════
قواعد الحكم والإغلاق
══════════════════════════════════════════════════════════════

ممنوع فرض حكم نجاح مسبقًا.

الحكم نتيجة للدليل.

النتائج المحتملة تشمل:

VERIFIED
CLOSED
BLOCKED
PARTIALLY VERIFIED
NOT READY
REOPENED

PRODUCTION READY
لا يصدر إلا بعد إثبات متطلباته.

GO-LIVE APPROVED
لا يصدر دون موافقة المالك.

FINAL ACCEPTANCE
لا يصدر قبل التشغيل والمراقبة واستيفاء شروط التسليم.

لا يجوز استخدام:
A
VERIFIED
CLOSED
PRODUCTION READY

لمجرد أن القالب طلبها.

══════════════════════════════════════════════════════════════
المطلوب من المنفذ التقني الآن فقط
══════════════════════════════════════════════════════

هذه هي المهمة التأسيسية الأولى.

لا تبدأ أي PHASE برمجية.

الاستثناء المصرح به الآن هو إدارة الوثائق التالية فقط.

نفذ:

1. تحقق من وجود:

D:\YASIN_WORKSHOP

2. أنشئ أو حدّث فقط:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_MASTER_ROADMAP.md

واجعله مطابقًا لـR3 كاملة.

3. افحص وجود:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_PERMANENT_DEVELOPMENT_POLICY.md

إذا كان موجودًا:
لا تعدل السياسة بسبب هذه المهمة.
فقط سجل وجودها.

إذا لم يكن موجودًا:
سجلها MISSING_PREREQUISITE.
لا تدعِ قراءتها.

4. افحص وجود:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_BUSINESS_REQUIREMENTS.md

إذا كان موجودًا:
سجل وجوده فقط ضمن هذه المهمة ما لم يُطلب تدقيق محتواه صراحة.

إذا لم يكن موجودًا:
سجل:
MISSING_PREREQUISITE.

ولا تخترع متطلباته من الذاكرة.

5. أنشئ، إن لم يكن موجودًا، الهيكل الأولي فقط لـ:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_TASK_REGISTER.md

ويجب ألا يكتفي بوصف القالب.

استخرج البنود التنفيذية المحددة في R3 إلى سجلات مهام فعلية
بحالة أولية:

NOT STARTED

مع:
TASK_ID
ROADMAP_REF
TITLE
STATUS
DEPENDENCIES
OWNER_DECISION_REQUIRED
ACCEPTANCE_CRITERIA
VERIFICATION_EVIDENCE
BLOCKED_REASON
UNBLOCK_REQUIREMENT
LAST_UPDATED
NOTES

لا تخترع Verification Evidence لمهمة لم تنفذ.

6. أنشئ، إذا لم يكن موجودًا، الهيكل فقط لـ:

D:\YASIN_WORKSHOP\YASIN_WORKSHOP_DECISION_LOG.md

دون اختراع قرارات للمالك.

يمكن تسجيل OWNER-DECISION gates على أنها:
PENDING OWNER DECISION

ولا تسجل لها جوابًا من عندك.

7. لا تنشئ الآن:

YASIN_WORKSHOP_CORRECTION_IMPACT_MATRIX.md
أو
YASIN_WORKSHOP_REQUIREMENTS_TEST_MATRIX.md
أو
YASIN_WORKSHOP_ARCHITECTURE_DECISIONS.md

كمحتوى مفترض إذا لم تكن مرحلتها قد بدأت.

لكن تأكد أن مساراتها الرسمية موثقة في Roadmap.

8. لا تنشئ Flutter.

9. لا تنشئ Backend.

10. لا تنشئ Database.

11. لا تثبت Packages.

12. لا تنفذ Migration.

13. لا تغير إعدادات Windows.

14. لا تعدل أي مشروع آخر.

15. لا تنفذ حذفًا واسعًا.

16. لا تستخدم Recursive Search واسعًا من D:\.

17. لا تنفذ Script يمكن أن يضر ملفات الجهاز أو المشروع.

18. بعد كتابة Roadmap، اقرأ الملف فعليًا.

19. تحقق من وجود:

- Project Identity.
- Sources of Truth.
- Central Document Paths.
- Decision Log rules.
- Real Task Register requirement.
- Testing During Development rule.
- Full-stack delivery rule.
- Scope.
- OWNER-DECISION-001 إلى OWNER-DECISION-015.
- PHASE 1 إلى PHASE 51.
- Backend bootstrap phase.
- Flutter foundation.
- Business screens.
- Negative employee balance rule.
- 24-hour rule.
- Debt creation rule.
- Late cash correction.
- Supplier flow.
- Messaging.
- Attachments security.
- Server security.
- Backup/recovery.
- Deployment/rollback.
- Production verification.
- Go-Live approval.
- Monitoring.
- Final acceptance.
- BACKLOG.
- Verdict rules.

20. تحقق من أن الملف لم يُبتر.

21. نجاح إنشاء Roadmap لا يعني أن المشروع جاهز للتنفيذ إذا كان
BUSINESS REQUIREMENTS أو PERMANENT POLICY مفقودًا.

يمكن أن تكون:
ROADMAP_DOCUMENT_STATUS=VERIFIED

وفي الوقت نفسه:
PROJECT_IMPLEMENTATION_STATUS=BLOCKED_BY_MISSING_PREREQUISITE

وهذا ليس تناقضًا.

══════════════════════════════════════════════════════════════
FINAL REPORT — لهذه المهمة التوثيقية فقط
══════════════════════════════════════════════════════════════

أعد تقريرًا بالحقائق فقط:

PROJECT_PATH=

ROADMAP_PATH=
ROADMAP_CREATED_OR_UPDATED=
ROADMAP_READ_BACK=
ROADMAP_R3_COMPLETE=
CONTENT_TRUNCATED=

POLICY_PATH=
POLICY_EXISTS=
POLICY_READ_IN_THIS_TASK=

BUSINESS_REQUIREMENTS_PATH=
BUSINESS_REQUIREMENTS_EXISTS=
BUSINESS_REQUIREMENTS_READ_IN_THIS_TASK=

TASK_REGISTER_PATH=
TASK_REGISTER_CREATED_OR_UPDATED=
TASK_RECORDS_CREATED=
TASKS_INITIAL_STATUS=

DECISION_LOG_PATH=
DECISION_LOG_CREATED_OR_FOUND=
OWNER_DECISIONS_RECORDED_AS_PENDING=

CORRECTION_MATRIX_OFFICIAL_PATH=
REQUIREMENTS_TEST_MATRIX_OFFICIAL_PATH=
ARCHITECTURE_DECISIONS_OFFICIAL_PATH=

PHASES_PRESENT=
OWNER_DECISIONS_PRESENT=
BACKLOG_PRESENT=

CODE_CREATED=
FLUTTER_CREATED=
BACKEND_CREATED=
DATABASE_CREATED=
MIGRATIONS_RUN=
PACKAGES_INSTALLED=
DEVICE_SETTINGS_CHANGED=

MISSING_PREREQUISITES=
BLOCKERS=

ROADMAP_DOCUMENT_STATUS=
PROJECT_IMPLEMENTATION_STATUS=
FINAL_VERDICT=

مهم:

FINAL_VERDICT لهذه المهمة يصف فقط نجاح أو فشل تأسيس الوثائق المطلوبة.

لا يجوز أن يصف المشروع بأنه:
PRODUCTION READY
أو
IMPLEMENTATION COMPLETE

بسبب نجاح إنشاء الخارطة.

══════════════════════════════════════════════════════════════
END OF
YASIN WORKSHOP — MASTER IMPLEMENTATION ROADMAP R3
══════════════════════════════════════════════════════════════
